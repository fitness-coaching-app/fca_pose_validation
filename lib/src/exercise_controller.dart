import 'package:google_ml_kit/google_ml_kit.dart';
import 'exercise_definition.dart';
import 'pose_processor.dart';

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

  void loadNewStep() {

  }

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

class PoseProcessorResult{
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
  final PoseProcessor _poseProcessor = PoseProcessor();
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

    // process the returned value from _processPoses
    PoseProcessorResult result = _processPoses(currentStep.poses);

    // callback
    _eventHandler();

    return _currentState;
  }

  PoseProcessorResult _processPoses(List<ExercisePose> subposes) {
    // call getAngle and getTouch according to the definition.
    // getAngles
    final angles = [
      subposes[0].definitions[0].angle,
      subposes[1].definitions[0].angle
    ];

    final currentAngle = _poseProcessor.angle.getAngle(
        angles[0]!.vertex, angles[0]!.landmarks[0], angles[0]!.landmarks[1]);

    // getTouch

    // TODO: call poseChecker + poseInstructor

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

  void _subposeCheck() {
    final subposes = definition.steps[_currentState.currentStep].poses;
    final angles = [
      subposes[0].definitions[0].angle,
      subposes[1].definitions[0].angle
    ];
    final currentAngle = _poseProcessor.angle.getAngle(
        angles[0]!.vertex, angles[0]!.landmarks[0], angles[0]!.landmarks[1]);
    if (angles[0]!.range.from <= currentAngle &&
        currentAngle <= angles[0]!.range.to) {
      print("CURRENT ANGLE[0] " + currentAngle.toString());
    }
    if (angles[1]!.range.from <= currentAngle &&
        currentAngle <= angles[1]!.range.to) {
      print("CURRENT ANGLE[1] " + currentAngle.toString());
    }
  }
}
