import 'package:google_ml_kit/google_ml_kit.dart';
import '../exercise_definition.dart';
import 'angle_calculator.dart';
import 'touch_checker.dart';

enum PoseCalculatorType { angle, touch }

class PoseCalculator {
  static Map<String, double> computeFromDefinition(
      {required List<ExercisePose> subposes,
      required Pose pose,
      required Map<String, CalculatorDefinition> calculators}) {
    // Call getAngle and getTouch according to the definition.
    Map<String, double> result = {};
    for (var i in calculators.keys) {
      if (calculators[i]!.angle != null) {
        result[i] = AngleCalculator.computeAngle(calculators[i]!.angle!.vertex, calculators[i]!.angle!.landmarks[0], calculators[i]!.angle!.landmarks[1], pose);
      } else if (calculators[i]!.touch != null) {
        result[i] = TouchChecker.check(calculators[i]!.touch!.landmarks[0], calculators[i]!.touch!.landmarks[1], pose);
      }
    }
    return result;
  }
}
