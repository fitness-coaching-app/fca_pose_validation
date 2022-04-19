import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'package:google_ml_kit/google_ml_kit.dart';
import 'exercise_definition.dart';
import 'pose_calculator/pose_calculator.dart';
import 'pose_checker.dart';
import 'pose_logger.dart';
import 'pose_suggestion.dart';
import 'exercise_state.dart';

class ExerciseController {
  late Pose _pose;
  PoseLogger _poseLogger = PoseLogger('testUserID', 'testCourseID');
  final ExerciseState _currentState = ExerciseState();
  DateTime lastLog = DateTime.now();
  final PoseCalculator _poseCalculator = PoseCalculator();
  final PoseChecker _poseChecker = PoseChecker();
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
    _poseCalculator.setPose(newPose);
  }

  ExerciseState getCurrentState() {
    return _currentState;
  }

  ExerciseState update() {
    if(_currentState.exerciseCompleted()){
      return _currentState;
    }

    final ExerciseStep currentStep =
        definition.steps[_currentState.currentStep];

    if (currentStep.criteria.counter != null) {
      _currentState.criteria = ExerciseDisplayCriteria.counter;
    } else if (currentStep.criteria.timer != null) {
      _currentState.criteria = ExerciseDisplayCriteria.timer;
    }

    // process the returned value from _processPoses
    _processPoses(currentStep);

    _currentState.update(); // Update the state according to the parameters

    // callback
    _eventHandler();

    return _currentState;
  }

  void _processPoses(ExerciseStep currentStep) {
    List<double> computeResults =
        _poseCalculator.computeFromDefinition(currentStep.poses);

    PoseCheckerResult poseCheckerResult =
        _poseChecker.check(currentStep, _currentState, computeResults);

    // Log the pose
    if (DateTime.now().difference(lastLog).inMilliseconds >= 500) {
      _poseLogger.log(_pose, computeResults, _currentState.currentSubpose);
      lastLog = DateTime.now();
    }

    if (currentStep.criteria.counter != null) {
      _currentState.allSubpose += poseCheckerResult.incrementAllSubpose;
      print("${_currentState.currentSubpose} -> ${_currentState.expectedNextSubpose}");
      print("Count: ${_currentState.repeatCount}");
      if (poseCheckerResult.nextSubpose) {
        _currentState.currentSubpose = _currentState.expectedNextSubpose;
        _currentState.expectedNextSubpose =
            (_currentState.expectedNextSubpose + 1) % 2;
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
      print("State: ${_currentState.wrongPoseTimer.elapsedMilliseconds} | ${_currentState.actualTimerDuration.elapsedMilliseconds}");
      if(_currentState.currentStep + 1 < definition.steps.length){
        _currentState.loadNewStep(definition.steps[++_currentState.currentStep]);
      }
      else {
        // exerciseCompleted
        _currentState.setExerciseCompleted();
        if(_onExerciseCompleteCallback != null) {
          _onExerciseCompleteCallback!();
        }
      }
      if(_onStepCompleteCallback != null){
        _onStepCompleteCallback!();
        _currentState.setDisplayState(DisplayState.teach);
      }
    }

    if (_currentState.displayStateChanged()) {
      if(_onDisplayStateChangeCallback != null){
        _onDisplayStateChangeCallback!(_currentState.getDisplayState());
      }
    }
  }

  void preExerciseCompleted(){
    if(_currentState.getDisplayState() == DisplayState.preExercise){
      _currentState.setDisplayState(DisplayState.teach);
    }
  }
  void teachCompleted(){
    if(_currentState.getDisplayState() == DisplayState.teach){
      _currentState.setDisplayState(DisplayState.exercise);
    }
  }

  void dumpLogToFile(String filename) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/$filename.json');
    print("Saved to ${directory.path}/$filename.json");

    file.writeAsStringSync(_poseLogger.toJSON());
  }

  void clearLog(){
    _poseLogger = PoseLogger('testUserID', 'testCourseID');
  }
}
