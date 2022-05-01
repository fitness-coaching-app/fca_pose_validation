import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'package:google_ml_kit/google_ml_kit.dart';
import 'exercise_definition.dart';
import 'pose_calculator/pose_calculator.dart';
import 'pose_checker.dart';
import 'pose_logger.dart';
import 'pose_suggestion.dart';
import 'exercise_state.dart';
class ExerciseSummary{
  final int exerciseDuration;
  final int score;

  ExerciseSummary({required this.exerciseDuration, required this.score});
}

class ExerciseController {
  late Pose _pose;
  PoseLogger _poseLogger = PoseLogger('testUserID', 'testCourseID');
  final ExerciseState _currentState = ExerciseState();
  DateTime lastLog = DateTime.now();
  PoseChecker _poseChecker = PoseChecker();
  late ExerciseDefinition definition;

  void Function(DisplayState displayState)? _onDisplayStateChangeCallback;
  void Function()? _onStepCompleteCallback;
  void Function()? _onExerciseCompleteCallback;

  ExerciseController(String yamlDefinition,
      {void Function(DisplayState displayState)? onDisplayStateChange,
      void Function()? onStepComplete,
      void Function()? onExerciseComplete}) {
    definition = ExerciseDefinition(yamlDefinition);
    _onDisplayStateChangeCallback = onDisplayStateChange;
    _onStepCompleteCallback = onStepComplete;
    _onExerciseCompleteCallback = onExerciseComplete;
    _poseLogger.startNewStep();
    lastLog = DateTime.now();
    _currentState.loadNewStep(definition.steps[++_currentState.currentStep]);
  }

  void setPose(Pose newPose) {
    _pose = newPose;
  }

  ExerciseState getCurrentState() {
    return _currentState;
  }

  ExerciseState update() {
    if (_currentState.exerciseCompleted()) {
      return _currentState;
    }
    if(_currentState.getDisplayState() == DisplayState.exercise){
      _currentState.globalTimer.start();
      final ExerciseStep currentStep =
      definition.steps[_currentState.currentStep];

      // process the returned value from _processPoses
      _processPoses(currentStep);
    }
    else{
      _currentState.globalTimer.stop();
    }

    _currentState.update(); // Update the state according to the parameters
    // callback
    _eventHandler();

    return _currentState;
  }

  void _processPoses(ExerciseStep currentStep) {
    Map<String, double> computeResults = PoseCalculator.computeFromDefinition(
        subposes: currentStep.poses,
        pose: _pose,
        calculators: currentStep.calculators);

    PoseCheckerResult poseCheckerResult = _poseChecker.check(
        currentStep: currentStep,
        currentState: _currentState,
        computeResults: computeResults,
        calculators: currentStep.calculators);

    // Log the pose
    if (DateTime.now().difference(lastLog).inMilliseconds >= 500) {
      _poseLogger.log(_pose, computeResults, _currentState.currentSubpose);
      lastLog = DateTime.now();
    }

    if (currentStep.criteria.counter != null) {
      _currentState.allSubpose += poseCheckerResult.incrementAllSubpose;
      print(
          "${_currentState.currentSubpose} -> ${_currentState.expectedNextSubpose}");
      print("Count: ${_currentState.repeatCount}");
      if (poseCheckerResult.nextSubpose) {
        _currentState.correctSubpose++;
        _currentState.currentSubpose = _currentState.expectedNextSubpose;
        _currentState.expectedNextSubpose =
            (_currentState.expectedNextSubpose + 1) %
                2; // TODO: Make it more dynamic to support more subpose
      }
      if (poseCheckerResult.count) {
        _currentState.repeatCount++;
      }
    } else if (currentStep.criteria.timer != null) {
      if (poseCheckerResult.warning) {
        _currentState.timer.stop();
        _currentState.wrongPoseTimer.start();
      } else {
        _currentState.timer.start();
        _currentState.actualTimerDuration.start();
        _currentState.wrongPoseTimer.stop();
      }
      print("Time Elapsed: ${_currentState.timer.elapsedMilliseconds}");
    }

    PoseSuggestionResult poseSuggestionResult =
        PoseSuggestion.getSuggestion(poseCheckerResult, currentStep);

    if (poseSuggestionResult.warning) {
      _currentState.setWarning(poseSuggestionResult.warningMessage!, []);
    } else {
      _currentState.clearWarning();
    }
  }

  void _eventHandler() {
    if (_currentState.stepCompleted()) {
      _currentState.actualTimerDuration.stop();
      _currentState.timer.stop();
      print(
          "State: ${_currentState.wrongPoseTimer.elapsedMilliseconds} | ${_currentState.actualTimerDuration.elapsedMilliseconds}");
      if (_currentState.currentStep + 1 < definition.steps.length) {
        _currentState
            .loadNewStep(definition.steps[++_currentState.currentStep]);
        _poseChecker = PoseChecker();
        if (definition.steps[_currentState.currentStep].criteria.counter !=
            null) {
          _currentState.criteria = ExerciseDisplayCriteria.counter;
        } else if (definition.steps[_currentState.currentStep].criteria.timer !=
            null) {
          _currentState.criteria = ExerciseDisplayCriteria.timer;
        }
      } else {
        // exerciseCompleted
        _currentState.setExerciseCompleted();
        if (_onExerciseCompleteCallback != null) {
          _onExerciseCompleteCallback!();
        }
      }
      if (_onStepCompleteCallback != null) {
        _onStepCompleteCallback!();
        _currentState.setDisplayState(DisplayState.teach);
      }
    }

    if (_currentState.displayStateChanged()) {
      if (_onDisplayStateChangeCallback != null) {
        _onDisplayStateChangeCallback!(_currentState.getDisplayState());
      }
    }
  }

  ExerciseSummary getExerciseSummary(){
    bool countCriteria = false;
    bool timerCriteria = false;
    var scoreCount = (_currentState.correctSubpose / _currentState.allSubpose) * 100;
    var scoreTimer = ((_currentState.actualTimerDuration.elapsedMilliseconds - _currentState.wrongPoseTimer.elapsedMilliseconds) / _currentState.actualTimerDuration.elapsedMilliseconds) * 100;
    print("scoreCount ${_currentState.correctSubpose} / ${_currentState.allSubpose}");
    print("scoreTimer $scoreTimer");
    for(var i in definition.steps){
      if(i.criteria.counter != null) {
        countCriteria = true;
      } else if(i.criteria.timer != null) {
        timerCriteria = true;
      }
    }
    if(countCriteria && timerCriteria){
      return ExerciseSummary(exerciseDuration: _currentState.globalTimer.elapsed.inSeconds, score: (scoreCount + scoreTimer) ~/ 2);
    }
    else if(countCriteria){
      return ExerciseSummary(exerciseDuration: _currentState.globalTimer.elapsed.inSeconds, score: scoreCount.toInt());
    }
    else{
      return ExerciseSummary(exerciseDuration: _currentState.globalTimer.elapsed.inSeconds, score: scoreTimer.toInt());
    }
  }

  void preExerciseCompleted() {
    if (_currentState.getDisplayState() == DisplayState.preExercise) {
      _currentState.setDisplayState(DisplayState.teach);
      _eventHandler();
    }
  }

  void teachCompleted() {
    if (_currentState.getDisplayState() == DisplayState.teach) {
      _currentState.setDisplayState(DisplayState.exercise);
      _eventHandler();
    }
  }

  void dumpLogToFile(String filename) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/$filename.json');
    print("Saved to ${directory.path}/$filename.json");

    file.writeAsStringSync(_poseLogger.toJSON());
  }

  void clearLog() {
    _poseLogger = PoseLogger('testUserID', 'testCourseID');
  }
}
