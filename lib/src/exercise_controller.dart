import 'package:google_ml_kit/google_ml_kit.dart';
import 'exercise_definition.dart';
import 'pose_processor.dart';

enum ExerciseDispCriteria { timer, counter }
enum DispState { preExercise, teach, exercise }

class ExerciseState {
  DispState displayState = DispState.preExercise;
  int currentStep = 0;
  String exerciseName = "";
  bool _exerciseCompleted = false;
  bool _stepCompleted = false;
  bool _displayStateChanged = false;

  ExerciseDispCriteria criteria = ExerciseDispCriteria.timer;
  int remaining = 0;
  int target = 0;

  bool warning = false;
  String warningMessage = "";
  List<PoseLandmarkType> warningPoseHighlight = [];

  int currentSubpose = 0;

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
}

class ExerciseController {
  late Pose? _prevPose;
  late Pose _pose;
  final PoseProcessor _poseProcessor = PoseProcessor();
  final ExerciseState _currentState = ExerciseState();
  late ExerciseDefinition definition;

  void Function(DispState displayState)? onDisplayStateChangeCallback;
  void Function()? onStepCompleteCallback;

  ExerciseController(String yamlDefinition, {void Function(DispState displayState)? onDisplayStateChange,void Function()? onStepComplete}){
    definition = ExerciseDefinition(yamlDefinition);
    onDisplayStateChangeCallback = onDisplayStateChange;
    onStepCompleteCallback = onStepComplete;
  }

  void setPose(Pose newPose) {
    _prevPose = _pose;
    _pose = newPose;
    _poseProcessor.setPose(_pose);
  }

  ExerciseState getCurrentState() {
    return _currentState;
  }

  void _subposeCheck(List<ExercisePose> subposes){

  }

  ExerciseState check() {
    if(_currentState.displayStateChanged()){
      onDisplayStateChangeCallback!(_currentState.displayState);
    }
    if(_currentState.stepCompleted()){
      onStepCompleteCallback!();
    }

    final ExerciseStep currentStep = definition.steps[_currentState.currentStep];

    _subposeCheck(currentStep.poses);





    return _currentState;
  }

}
