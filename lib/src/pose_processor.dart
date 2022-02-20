import 'package:fca_pose_validation/src/angle_calculator.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class PoseProcessor {
  AngleCalculator angle = AngleCalculator();

  void setPose(Pose pose){
    angle.setPose(pose);
  }
}