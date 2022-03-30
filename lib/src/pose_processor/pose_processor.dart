import 'package:google_ml_kit/google_ml_kit.dart';
import '../exercise_definition.dart';
import 'angle_calculator.dart';
import 'touch_checker.dart';

enum PoseProcessorType { angle, touch }

class PoseProcessor {
  AngleCalculator angle = AngleCalculator();
  TouchChecker touch = TouchChecker();

  void setPose(Pose pose) {
    angle.setPose(pose);
    touch.setPose(pose);
  }

  List<double> computeFromDefinition(List<ExercisePose> subposes) {
    // Call getAngle and getTouch according to the definition.
    final subposeDef = subposes[0]; // Use only first subpose for calculation
    List<double> result = [];
    for (var i in subposeDef.definitions) {
      if (i.angle != null) {
        result += [
          angle.getAngle(
              i.angle!.vertex, i.angle!.landmarks[0], i.angle!.landmarks[1])
        ];
      } else if (i.touch != null) {
        result += [
          touch.touchChecker(i.touch!.landmarks[0], i.touch!.landmarks[1])
        ];
      }
    }

    print(result);
    return result;
  }
}
