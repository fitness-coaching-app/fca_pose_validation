import 'package:google_ml_kit/google_ml_kit.dart';
import 'exercise_definition.dart';
import 'pose_calculator/pose_calculator.dart';
import 'pose_checker.dart';
import 'pose_logger.dart';
import 'pose_suggestion.dart';

enum ExerciseDisplayCriteria { timer, counter }
enum DisplayState { preExercise, teach, exercise }

class ExerciseState {
  DisplayState _displayState = DisplayState.preExercise;
  int currentStep = 0;
  String exerciseName = "";
  bool _exerciseCompleted = false;
  bool _stepCompleted = false;
  bool _displayStateChanged = false;

  ExerciseDisplayCriteria criteria = ExerciseDisplayCriteria.timer;
  int remaining = 0;
  int target = 0;

  bool _warning = false;
  String _warningMessage = "";
  List<PoseLandmarkType> _warningPoseHighlight = [];

  int currentSubpose = 0;

  void loadNewStep() {}

  DisplayState getDisplayState() => _displayState;

  void setDisplayState(DisplayState value) {
    _displayState = value;
    _displayStateChanged = true;
  }

  void clearWarning() {
    _warning = false;
    _warningMessage = "";
    _warningPoseHighlight = [];
  }

  void clearState() {
    _displayState = DisplayState.preExercise;
    currentStep = 0;
    exerciseName = "";
    _exerciseCompleted = false;
    _stepCompleted = false;
    _displayStateChanged = false;

    criteria = ExerciseDisplayCriteria.timer;
    remaining = 0;
    target = 0;

    clearWarning();
  }

  Map<String, dynamic> getWarning() {
    return {
      "warning": _warning,
      "warningMessage": _warningMessage,
      "warningPoseHighlight": _warningPoseHighlight
    };
  }

  void setWarning(
      String warningMessage, List<PoseLandmarkType> warningPoseHighlight) {
    _warning = true;
    _warningMessage = warningMessage;
    _warningPoseHighlight = warningPoseHighlight;
  }

  bool displayStateChanged() {
    bool temp = _displayStateChanged;
    _displayStateChanged = false;
    return temp;
  }

  bool stepCompleted() {
    bool temp = _stepCompleted;
    _stepCompleted = false;
    return temp;
  }

  bool exerciseCompleted() {
    bool temp = _exerciseCompleted;
    _exerciseCompleted = false;
    return temp;
  }
}

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
  PoseLogger _poseLogger = PoseLogger('testUserID', 'testCourseID');
  DateTime lastLog = DateTime.now();
  DateTime exportTime = DateTime.now();
  final PoseCalculator _poseProcessor = PoseCalculator();
  final ExerciseState _currentState = ExerciseState();
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
    _poseProcessor.setPose(newPose);
  }

  ExerciseState getCurrentState() {
    return _currentState;
  }

  ExerciseState update() {
    final ExerciseStep currentStep =
        definition.steps[_currentState.currentStep];

    // Log the pose
    if(DateTime.now().difference(lastLog).inSeconds >= 2){
      _poseLogger.log(_pose, [0,0,0,0,0], 0);
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
    List<double> computeResults = _poseProcessor.computeFromDefinition(currentStep.poses);

    // TODO: เปลี่ยน return type เป็น PoseCheckerResult
    List<PoseLandmarkType>? poseCheckerResult = PoseChecker.check(computeResults, currentStep.poses);

    // TODO: call poseSuggestion

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
