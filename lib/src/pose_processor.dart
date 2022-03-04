import 'package:fca_pose_validation/src/angle_calculator.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'exercise_controller.dart';

enum PoseProcessorType{
  angle,
  touch
}

class PoseProcessorError{
  final PoseLandmarkType landmark;
  final PoseProcessorType from;
  final Definition rule;
  final double actualValue;

  PoseProcessorError(this.landmark, this.from, this.rule, this.actualValue);
}


class PoseProcessor {
  AngleCalculator angle = AngleCalculator();

  void setPose(Pose pose){
    angle.setPose(pose);
  }
}