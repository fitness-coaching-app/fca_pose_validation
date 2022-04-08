import 'package:google_ml_kit/google_ml_kit.dart';
import 'exercise_definition.dart';

class PoseCheckerResult {
  Definition definition;
  bool warning;
  double actualValue;

  PoseCheckerResult(this.definition, this.warning, this.actualValue);
}

class PoseChecker {
  static List<PoseLandmarkType>? check(List<double> computeResults,
      List<ExercisePose> subposes, Criteria subposeCriteria) {
    final subposeDef = subposes[0];
    List<PoseLandmarkType> poseWarningPoint = [];
    List<int> angleDef = [];
    List<double> touchDef = [];
    int computeCnt = 0;
    int angleCnt = 0;
    int falsePoseCnt = 0;
    int falsePoseTouchCnt = 0;
    int exerciseCnt = 0;

    //check yaml criteria is counter and collect repeat, countOnId
    if (subposeCriteria.counter != null) {
      int? repeat = subposeCriteria.counter?.repeat;
      String? countOnId = subposeCriteria.counter?.countOnId;

      //loop for repeat count
      for (var i = 0; i <= repeat!; i++) {
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
              if (subposeDef.id != null) {
                if (subposeDef.id == countOnId) exerciseCnt++;
              }
            } else {
              //pose warning delay after 50 frames (approx. 5 sec.)
              falsePoseCnt++;
              if (falsePoseCnt > 50) {
                poseWarningPoint += [i.angle!.vertex] +
                    [i.angle!.landmarks[0]] +
                    [i.angle!.landmarks[1]];
                falsePoseCnt = 0;
              }
            }
          } else if (i.touch != null) {
            //if not touch
            if (computeResults[computeCnt] == 0) {
              falsePoseTouchCnt++;
              if (falsePoseTouchCnt > 50) {
                poseWarningPoint +=
                    [i.touch!.landmarks[0]] + [i.touch!.landmarks[1]];
                falsePoseTouchCnt = 0;
              }
            }
          }
          computeCnt++;
          angleCnt += 2;
        }
      }
    }

    //check yaml criteria is timer and collect duration
    if (subposeCriteria.timer != null) {
      int? duration = subposeCriteria.timer?.duration;
    }
    return poseWarningPoint;
  }
}
