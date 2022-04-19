import 'package:google_ml_kit/google_ml_kit.dart';
import '../exercise_definition.dart';
import 'angle_calculator.dart';
import 'touch_checker.dart';

enum PoseCalculatorType { angle, touch }

class PoseCalculator {
  static List<double> computeFromDefinition(List<ExercisePose> subposes, Pose pose) {
    // Call getAngle and getTouch according to the definition.
    final subposeDef = subposes[0]; // Use only first subpose for calculation
    List<double> result = [];
    for (var i in subposeDef.definitions) {
      if (i.angle != null) {
        result += [
          AngleCalculator.computeAngle(
              i.angle!.vertex, i.angle!.landmarks[0], i.angle!.landmarks[1], pose)
        ];
      } else if (i.touch != null) {
        result += [
          TouchChecker.check(i.touch!.landmarks[0], i.touch!.landmarks[1], pose)
        ];
      }
    }
    return result;
  }
}
