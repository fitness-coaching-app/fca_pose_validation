import 'package:google_ml_kit/google_ml_kit.dart';
import 'exercise_definition.dart';
import 'angle_calculator.dart';
import 'touch_checker.dart';

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
  TouchChecker touch = TouchChecker();

  void setPose(Pose pose){
    angle.setPose(pose);
    touch.setPose(pose);
  }
}