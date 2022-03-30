import 'package:google_ml_kit/google_ml_kit.dart';
import 'exercise_definition.dart';
import 'pose_processor.dart';
import 'pose_checker.dart';
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

class PoseSuggestionResult{
  bool warning;
  String? warningMessage;

  PoseSuggestionResult(this.warning, {this.warningMessage});
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
    List<double> computeResults = _computeDefinitions(subposes);

    // TODO: call poseChecker + poseSuggestion
    PoseChecker.check(computeResults, subposes);

    // TODO This is just a mock up
    return PoseProcessorResult();
  }

  List<double> _computeDefinitions(List<ExercisePose> subposes) {
    // Call getAngle and getTouch according to the definition.
    final subposeDef = subposes[0]; // Use only first subpose for calculation
    List<double> result = [];
    for (var i in subposeDef.definitions) {
      if (i.angle != null) {
        result += [
          _poseProcessor.angle.getAngle(
              i.angle!.vertex, i.angle!.landmarks[0], i.angle!.landmarks[1])
        ];
      } else if (i.touch != null) {
        result += [
          _poseProcessor.touch
              .touchChecker(i.touch!.landmarks[0], i.touch!.landmarks[1])
        ];
      }
    }

    print(result);
    return result;
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
