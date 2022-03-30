import 'package:google_ml_kit/google_ml_kit.dart';
import 'exercise_definition.dart';

class PoseCheckerResult{
  Definition definition;
  bool warning;
  double actualValue;

  PoseCheckerResult(this.definition, this.warning, this.actualValue);
}

class PoseChecker{
  static List<PoseLandmarkType>? check(List<double> computeResults, List<ExercisePose> subposes) {
    final subposeDef = subposes[0];
    List<PoseLandmarkType> poseWarningPoint = [];
    List<int> angleDef = [];
    List<double> touchDef = [];
    int computeCnt = 0;
    int angleCnt = 0;
    //loop for collect poses angle
    for (var i in subposeDef.definitions) {
      if (i.angle != null) {
        angleDef += (i.angle!.range);
      } else if (i.touch != null) {}
    }
    //loop for check computeResults's angle is in the range of angleDefinition
    for (var i in subposeDef.definitions) {
      if (i.angle != null) {
        if (computeResults[computeCnt] >= angleDef[angleCnt] &&
            computeResults[computeCnt] <= angleDef[angleCnt + 1]) {
        } else {
          poseWarningPoint += [i.angle!.vertex] +
              [i.angle!.landmarks[0]] +
              [i.angle!.landmarks[0]];
        }
      } else if (i.touch != null) {
        //if not touch
        if (computeResults[computeCnt] == 0) {
          poseWarningPoint += [i.touch!.landmarks[0]] + [i.touch!.landmarks[1]];
        }
      }
      computeCnt++;
      angleCnt += 2;
    }
    return poseWarningPoint;
  }
}

