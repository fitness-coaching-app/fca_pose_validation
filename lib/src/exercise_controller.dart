import 'package:google_ml_kit/google_ml_kit.dart';
import 'pose_processor.dart';

class ExerciseController {
  late Pose pose;
  PoseProcessor poseProcessor = PoseProcessor();

  void setPose(Pose pose) {
    this.pose = pose;
  }
}
