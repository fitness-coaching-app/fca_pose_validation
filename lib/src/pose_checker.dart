import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'exercise_definition.dart';
import 'exercise_state.dart';

class PoseCheckerResult {
  bool warning;
  CalculatorDefinition? warningCalculator;
  Definition? warningDefinition;
  double? actualValue;
  int incrementCorrectSubpose = 0;
  int incrementAllSubpose = 0;
  bool nextSubpose = false;
  bool count = false;

  PoseCheckerResult(this.warning,
      {this.warningCalculator,
      this.warningDefinition,
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

  PoseCheckerResult check(
      {required ExerciseStep currentStep,
      required ExerciseState currentState,
      required Map<String, double> computeResults,
      required Map<String, CalculatorDefinition> calculators}) {
    Criteria subposeCriteria = currentStep.criteria;
    PoseCheckerResult result = PoseCheckerResult(false); // Mock up

    //check yaml criteria is counter and collect repeat, countOnId
    if (subposeCriteria.counter != null) {
      final Map<String, dynamic> countCheckResult = _countCheck(
          currentStep: currentStep,
          currentState: currentState,
          computeResults: computeResults,
          calculators: calculators);
      result = PoseCheckerResult(warningTriggered,
          warningCalculator: countCheckResult["warningCalculator"],
          warningDefinition: countCheckResult["warningDefinition"],
          actualValue: countCheckResult["warningActualValue"],
          incrementCorrectSubpose: countCheckResult["incrementCorrectSubpose"],
          incrementAllSubpose: countCheckResult["incrementAllSubpose"],
          nextSubpose: countCheckResult["nextSubpose"],
          count: countCheckResult["count"]);
    }

    // check yaml criteria is timer and collect duration
    if (subposeCriteria.timer != null) {
      final Map<String, dynamic> timerCheckResult = _timerCheck(
          currentStep: currentStep,
          calculators: calculators,
          computeResults: computeResults);
      result = PoseCheckerResult(warningTriggered,
          warningCalculator: timerCheckResult["warningCalculator"],
          warningDefinition: timerCheckResult["warningDefinition"],
          actualValue: timerCheckResult["warningActualValue"]);
    }

    return result;
  }

  Map<String, bool> _definitionCheck(
      {required ExercisePose subpose,
      required Map<String, CalculatorDefinition> calculators,
      required Map<String, double> computeResults}) {
    Map<String, bool> isDefinitionCorrect = {};
    // loop for check computeResults's angle is in the range of angleDefinition
    for (String key in calculators.keys) {
      Definition def = subpose.definitions[key]!;
      CalculatorDefinition calculator = calculators[key]!;
      if (calculator.angle != null) {
        if (computeResults[key]! >= def.withParams!["range"]![0] &&
            computeResults[key]! <= def.withParams!["range"]![1]) {
          isDefinitionCorrect[key] = true;
        } else {
          isDefinitionCorrect[key] = false;
        }
      }
      else if(calculator.touch != null){
        isDefinitionCorrect[key] = computeResults[key] == def.withParams!["touch"];
      }
    }

    return isDefinitionCorrect;
  }

  Map<String, dynamic> _countCheck(
      {required ExerciseStep currentStep,
      required ExerciseState currentState,
      required Map<String, CalculatorDefinition> calculators,
      required Map<String, double> computeResults}) {
    int incrementCorrectSubpose = 0;
    int incrementAllSubpose = 0;
    List<ExercisePose> subposes = currentStep.poses;
    Criteria subposeCriteria = currentStep.criteria;
    bool nextSubpose = false;

    String? countOnId = subposeCriteria.counter?.countOnId;

    bool subposeAllCorrect = true;
    ExercisePose subpose = subposes[currentState.expectedNextSubpose];

    Map<String, bool> isDefinitionCorrect = _definitionCheck(
        subpose: subpose,
        computeResults: computeResults,
        calculators: calculators);
    Definition? warningDefinition;
    CalculatorDefinition? warningCalculator;
    double? warningActualValue;

    for (var key in isDefinitionCorrect.keys) {
      if (!(isDefinitionCorrect[key]!)) {
        subposeAllCorrect = false;
        falsePoseCnt++;
        // pose warning delay after 50 frames (approx. 5 sec.)
        if (falsePoseCnt > 50) {
          incrementAllSubpose++;
          warningTriggered = true;
          falsePoseCnt = 0;
        }
        if (warningTriggered) {
          warningDefinition = subpose.definitions[key];
          warningCalculator = calculators[key];
          warningActualValue = computeResults[key];
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
      "warningCalculator": warningCalculator,
      "warningDefinition": warningDefinition,
      "warningActualValue": warningActualValue,
      "incrementCorrectSubpose": incrementCorrectSubpose,
      "incrementAllSubpose": incrementAllSubpose,
      "nextSubpose": nextSubpose,
      "count": count
    };
  }

  Map<String, dynamic> _timerCheck(
      {required ExerciseStep currentStep,
      required Map<String, CalculatorDefinition> calculators,
      required Map<String, double> computeResults}) {
    ExercisePose subpose = currentStep.poses[0];

    Map<String, bool> isDefinitionCorrect = _definitionCheck(
        subpose: subpose,
        computeResults: computeResults,
        calculators: calculators);
    bool allCorrect = true;
    Definition? warningDefinition;
    double? warningActualValue;
    CalculatorDefinition? warningCalculator;

    for (var key in isDefinitionCorrect.keys) {
      if (!(isDefinitionCorrect[key]!)) {
        allCorrect = false;
        warningBufferTimer.start();
        if (warningBufferTimer.elapsedMilliseconds > 1500) {
          warningTriggered = true;
        }
        if (warningTriggered) {
          warningCalculator = calculators[key];
          warningDefinition = subpose.definitions[key];
          warningActualValue = computeResults[key];
        }
        break;
      }
    }
    if (allCorrect) {
      warningBufferTimer.reset();
      warningTriggered = false;
    }

    return {
      "warningCalculator": warningCalculator,
      "warningDefinition": warningDefinition,
      "warningActualValue": warningActualValue
    };
  }
}
