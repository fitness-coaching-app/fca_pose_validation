import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'exercise_definition.dart';
import 'exercise_state.dart';

class PoseCheckerResult {
  bool warning;
  Definition? warningDefinition;
  double? actualValue;
  int? incrementCorrectSubpose = 0;
  int? incrementAllSubpose = 0;
  bool? nextSubpose = false;

  PoseCheckerResult(this.warning,
      {this.warningDefinition,
      this.actualValue,
      this.incrementCorrectSubpose,
      this.incrementAllSubpose,
      this.nextSubpose});
}

class PoseChecker {
  int falsePoseCnt = 0;
  int falsePoseTouchCnt = 0;
  bool warningTriggered = false;

  int prevSubpose = -1;

  PoseCheckerResult check(ExerciseStep currentStep,
      ExerciseState currentState, List<double> computeResults) {
    List<ExercisePose> subposes = currentStep.poses;
    Criteria subposeCriteria = currentStep.criteria;
    PoseCheckerResult result = PoseCheckerResult(false); // Mock up

    //check yaml criteria is counter and collect repeat, countOnId
    if (subposeCriteria.counter != null) {
      final Map<String, dynamic> countCheckResult = _countCheck(currentStep, currentState, computeResults);
      result = PoseCheckerResult(warningTriggered,
        warningDefinition: countCheckResult["warningDefinition"],
        actualValue: countCheckResult["warningActualValue"],
        incrementCorrectSubpose: countCheckResult["incrementCorrectSubpose"],
        incrementAllSubpose: countCheckResult["incrementAllSubpose"],
        nextSubpose: countCheckResult["nextSubpose"]
      );
    }

    // TODO: For now, check only counter
    // check yaml criteria is timer and collect duration
    // if (subposeCriteria.timer != null) {
    //   int? duration = subposeCriteria.timer?.duration;
    // }

    return result;
  }

  Map<String, dynamic> _countCheck(ExerciseStep currentStep,
      ExerciseState currentState, List<double> computeResults) {
    int incrementCorrectSubpose = 0;
    int incrementAllSubpose = 0;
    List<ExercisePose> subposes = currentStep.poses;
    Criteria subposeCriteria = currentStep.criteria;
    bool nextSubpose = false;

    String? countOnId = subposeCriteria.counter?.countOnId;

    bool subposeAllCorrect = true;
    ExercisePose subpose = subposes[currentState.expectedNextSubpose];
    List<bool> isDefinitionCorrect = [];

    // loop for check computeResults's angle is in the range of angleDefinition
    for(int defIndex = 0;defIndex < subpose.definitions.length;++defIndex){
      Definition def = subpose.definitions[defIndex];
      if (def.angle != null) {
        if (computeResults[defIndex] >= def.angle!.range[0] &&
            computeResults[defIndex] <= def.angle!.range[1]) {
          isDefinitionCorrect.add(true);
        } else {
          subposeAllCorrect = false;
          isDefinitionCorrect.add(false);
        }
      } else if (def.touch != null) {
        if (computeResults[defIndex] == 1) {
          isDefinitionCorrect.add(true);
        } else {
          subposeAllCorrect = false;
          isDefinitionCorrect.add(false);
        }
      }
    }

    Definition? warningDefinition;
    double? warningActualValue;
    if (subposeAllCorrect) {
      incrementCorrectSubpose++;
      incrementAllSubpose++;
      warningTriggered = false;
      if (subpose.id != null && subpose.id == countOnId) {
        nextSubpose = true;
      }
    } else {
      if (warningTriggered) {
        for (int i = 0; i < isDefinitionCorrect.length; ++i) {
          if (!isDefinitionCorrect[i]) {
            warningDefinition = subpose.definitions[i];
            warningActualValue = computeResults[i];
            break;
          }
        }
      } else {
        falsePoseCnt++;
        // pose warning delay after 50 frames (approx. 5 sec.)
        if (falsePoseCnt > 50) {
          incrementAllSubpose++;
          warningTriggered = true;
          falsePoseCnt = 0;
        }
      }
    }

    return {
      "warningDefinition": warningDefinition,
      "warningActualValue": warningActualValue,
      "incrementCorrectSubpose": incrementCorrectSubpose,
      "incrementAllSubpose": incrementAllSubpose,
      "nextSubpose": nextSubpose
    };
  }
}
