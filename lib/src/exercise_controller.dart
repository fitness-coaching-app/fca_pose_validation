import 'package:google_ml_kit/google_ml_kit.dart';
import 'pose_processor.dart';

enum ExerciseDispCriteria{
  timer,
  counter
}
enum DispState{
  preExercise,
  teach,
  exercise
}

class ExerciseState{
  DispState displayState = DispState.preExercise;
  int exerciseNumber = 0;
  String exerciseName = "";
  bool exerciseComplete = false;
  bool displayStateChanged = false;

  ExerciseDispCriteria criteria = ExerciseDispCriteria.timer;
  int remaining = 0;
  int target = 0;

  bool warning = false;
  String warningMessage = "";
  List<PoseLandmarkType> warningPoseHighlight = [];
}

class ExerciseController {
  late Pose _pose;
  PoseProcessor _poseProcessor = PoseProcessor();
  ExerciseState _currentState = ExerciseState();


  void setPose(Pose pose) {
    _pose = pose;
    _poseProcessor.setPose(_pose);
  }

  ExerciseState getCurrentState(){
    return _currentState;
  }

  ExerciseState check(){
    return _currentState;
  }

}
