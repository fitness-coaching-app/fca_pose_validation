import 'package:google_ml_kit/google_ml_kit.dart';
import 'exercise_definition.dart';
import 'pose_calculator/pose_calculator.dart';
import 'pose_checker.dart';
import 'pose_logger.dart';
import 'pose_suggestion.dart';
import 'exercise_state.dart';

class PoseProcessorResult {
  int? predictedCurrentSubpose;
  int? expectedCurrentSubpose;
  int? predictedNextSubpose;

  bool warning = false;
  String warningMessage = "";
  List<PoseLandmarkType> warningPoseHighlight = [];
}

class ExerciseController {
  late Pose? _prevPose;
  late Pose _pose;
  final PoseLogger _poseLogger = PoseLogger('testUserID', 'testCourseID');
  final ExerciseState _currentState = ExerciseState();
  DateTime lastLog = DateTime.now();
  DateTime exportTime = DateTime.now();
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
  }

  void setPose(Pose newPose) {
    _prevPose = newPose;
    _pose = newPose;
    _poseCalculator.setPose(newPose);
  }

  ExerciseState getCurrentState() {
    return _currentState;
  }

  ExerciseState update() {
    final ExerciseStep currentStep =
        definition.steps[_currentState.currentStep];

    // Log the pose
    if (DateTime.now().difference(lastLog).inSeconds >= 2) {
      _poseLogger.log(_pose, [0, 0, 0, 0, 0], 0);
      // print(_poseLogger.toJSON());
      lastLog = DateTime.now();
    }

    // process the returned value from _processPoses
    PoseProcessorResult result = _processPoses(currentStep);

    // callback
    _eventHandler();

    return _currentState;
  }

  PoseProcessorResult _processPoses(ExerciseStep currentStep) {
    List<double> computeResults =
        _poseCalculator.computeFromDefinition(currentStep.poses);

    // PoseCheckerResult poseCheckerResult =
    //     _poseChecker.check(currentStep, _currentState,computeResults);


    // print(poseCheckerResult.warning);
    // print(poseCheckerResult.warningDefinition?.angle?.vertex);
    // TODO: call poseSuggestion
    // print("TEST");
    // print(PoseSuggestion.getSuggestion(poseCheckerResult, currentStep).warningMessage);
    // TODO This is just a mock up
    return PoseProcessorResult();
  }

  void _eventHandler() {
    if (_currentState.displayStateChanged()) {
      _onDisplayStateChangeCallback!(_currentState.getDisplayState());
    }

    if (_currentState.exerciseCompleted()) {
      _onExerciseCompleteCallback!();
    } else if (_currentState.stepCompleted()) {
      _onStepCompleteCallback!();
    }
  }
}
