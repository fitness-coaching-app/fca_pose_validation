import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'exercise_definition.dart';
import 'exercise_state.dart';

class PoseCheckerResult {
  bool warning;
  Definition? warningDefinition;
  double? actualValue;
  int incrementCorrectSubpose = 0;
  int incrementAllSubpose = 0;
  bool nextSubpose = false;
  bool count = false;

  PoseCheckerResult(this.warning,
      {this.warningDefinition,
      this.actualValue,
      this.incrementCorrectSubpose = 0,
      this.incrementAllSubpose = 0,
      this.nextSubpose = false,
      this.count = false});
}

class PoseChecker {
  int falsePoseCnt = 0;
  int falsePoseTouchCnt = 0;
  bool warningTriggered = false;
  Stopwatch warningBufferTimer = Stopwatch();

  PoseCheckerResult check(ExerciseStep currentStep, ExerciseState currentState,
      List<double> computeResults) {
    Criteria subposeCriteria = currentStep.criteria;
    PoseCheckerResult result = PoseCheckerResult(false); // Mock up

    //check yaml criteria is counter and collect repeat, countOnId
    if (subposeCriteria.counter != null) {
      final Map<String, dynamic> countCheckResult =
          _countCheck(currentStep, currentState, computeResults);
      result = PoseCheckerResult(warningTriggered,
          warningDefinition: countCheckResult["warningDefinition"],
          actualValue: countCheckResult["warningActualValue"],
          incrementCorrectSubpose: countCheckResult["incrementCorrectSubpose"],
          incrementAllSubpose: countCheckResult["incrementAllSubpose"],
          nextSubpose: countCheckResult["nextSubpose"],
          count: countCheckResult["count"]);
    }

    // check yaml criteria is timer and collect duration
    if (subposeCriteria.timer != null) {
      final Map<String, dynamic> timerCheckResult = _timerCheck(currentStep, computeResults);
      result = PoseCheckerResult(warningTriggered,
        warningDefinition: timerCheckResult["warningDefinition"],
        actualValue: timerCheckResult["warningActualValue"]
      );
    }

    return result;
  }

  List<bool> _definitionCheck(
      ExercisePose subpose, List<double> computeResults) {
    List<bool> isDefinitionCorrect = [];
    // loop for check computeResults's angle is in the range of angleDefinition
    for (int defIndex = 0; defIndex < subpose.definitions.length; ++defIndex) {
      Definition def = subpose.definitions[defIndex];
      if (def.angle != null) {
        if (computeResults[defIndex] >= def.angle!.range[0] &&
            computeResults[defIndex] <= def.angle!.range[1]) {
          isDefinitionCorrect.add(true);
        } else {
          isDefinitionCorrect.add(false);
        }
      } else if (def.touch != null) {
        isDefinitionCorrect.add((computeResults[defIndex] == 0? false: true) == def.touch!.touch);
      }
    }
    return isDefinitionCorrect;
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

    List<bool> isDefinitionCorrect = _definitionCheck(subpose, computeResults);
    Definition? warningDefinition;
    double? warningActualValue;

    for (int i = 0; i < isDefinitionCorrect.length; ++i) {
      if (!isDefinitionCorrect[i]) {
        subposeAllCorrect = false;
        falsePoseCnt++;
        // pose warning delay after 50 frames (approx. 5 sec.)
        if (falsePoseCnt > 50) {
          incrementAllSubpose++;
          warningTriggered = true;
          falsePoseCnt = 0;
        }
        if (warningTriggered) {
          warningDefinition = subpose.definitions[i];
          warningActualValue = computeResults[i];
        }
        break;
      }
    }

    bool count = false;

    if (subposeAllCorrect) {
      incrementCorrectSubpose++;
      incrementAllSubpose++;
      warningTriggered = false;
      nextSubpose = true;
      falsePoseCnt = 0;
      if (subpose.id != null && subpose.id == countOnId) {
        count = true;
      }
    }

    return {
      "warningDefinition": warningDefinition,
      "warningActualValue": warningActualValue,
      "incrementCorrectSubpose": incrementCorrectSubpose,
      "incrementAllSubpose": incrementAllSubpose,
      "nextSubpose": nextSubpose,
      "count": count
    };
  }

  Map<String, dynamic> _timerCheck(ExerciseStep currentStep, List<double> computeResults) {
    ExercisePose subpose = currentStep.poses[0];

    List<bool> isDefinitionCorrect = _definitionCheck(subpose, computeResults);
    bool allCorrect = true;
    Definition? warningDefinition;
    double? warningActualValue;

    for (int i = 0; i < isDefinitionCorrect.length; ++i) {
      if (!isDefinitionCorrect[i]) {
        allCorrect = false;
        warningBufferTimer.start();
        if (warningBufferTimer.elapsedMilliseconds > 1500) {
          warningTriggered = true;
        }
        if (warningTriggered) {
          warningDefinition = subpose.definitions[i];
          warningActualValue = computeResults[i];
        }
        break;
      }
    }
    if (allCorrect) {
      warningBufferTimer.reset();
      warningTriggered = false;
    }

    return {
      "warningDefinition": warningDefinition,
      "warningActualValue": warningActualValue
    };
  }
}
