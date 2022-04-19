import 'package:google_ml_kit/google_ml_kit.dart';
import 'exercise_definition.dart';

enum ExerciseDisplayCriteria { timer, counter }
enum DisplayState { preExercise, teach, exercise }

class ExerciseState {
  DisplayState _displayState = DisplayState.preExercise;
  int currentStep = -1; // -1 = N/A

  bool _exerciseCompleted = false;
  bool _stepCompleted = false;
  bool _displayStateChanged = false;

  String stepName = "";

  ExerciseDisplayCriteria criteria = ExerciseDisplayCriteria.counter;

  // For counter criteria
  int repeatCount = 0;
  int target = 0;

  // For timer criteria
  Stopwatch timer = Stopwatch();
  int targetTimeMilliseconds = 0;

  bool _warning = false;
  String _warningMessage = "";
  List<PoseLandmarkType> _warningPoseHighlight = [];

  int currentSubpose = -1; // -1 = N/A
  int expectedNextSubpose = 0;

  // Exercise scope parameters
  int correctSubpose = 0;
  int allSubpose = 0;

  Stopwatch wrongPoseTimer = Stopwatch();
  Stopwatch actualTimerDuration = Stopwatch();

  void loadNewStep(ExerciseStep step) {
    clearStateForNewStep();
    setDisplayState(DisplayState.teach);
    stepName = step.name;
    if(step.criteria.counter != null){
      criteria = ExerciseDisplayCriteria.counter;
      target = step.criteria.counter!.repeat;
    }
    else if(step.criteria.timer != null){
      criteria = ExerciseDisplayCriteria.timer;
      targetTimeMilliseconds = step.criteria.timer!.duration * 1000;
    }
  }

  void update(){
    if(criteria == ExerciseDisplayCriteria.counter){
      if(repeatCount >= target) {
        _stepCompleted = true;
      }
    }
    else if(criteria == ExerciseDisplayCriteria.timer){
      if(timer.elapsedMilliseconds >= targetTimeMilliseconds){
        _stepCompleted = true;
      }
    }
  }

  void clearWarning() {
    _warning = false;
    _warningMessage = "";
    _warningPoseHighlight = [];
  }

  void clearStateForNewStep() {
    stepName = "";
    _exerciseCompleted = false;
    _stepCompleted = false;
    _displayStateChanged = false;

    currentSubpose = -1;
    expectedNextSubpose = 0;

    criteria = ExerciseDisplayCriteria.timer;
    repeatCount = 0;
    target = 0;

    timer.reset();

    clearWarning();
  }


  bool isWarning(){
    return _warning;
  }
  Map<String, dynamic> getWarning() {
    return {
      "warning": _warning,
      "warningMessage": _warningMessage,
      "warningPoseHighlight": _warningPoseHighlight
    };
  }

  void setWarning(
      String warningMessage, List<PoseLandmarkType> warningPoseHighlight) {
    _warning = true;
    _warningMessage = warningMessage;
    _warningPoseHighlight = warningPoseHighlight;
  }

  DisplayState getDisplayState() => _displayState;

  void setDisplayState(DisplayState value) {
    _displayState = value;
    _displayStateChanged = true;
  }

  void setExerciseCompleted(){
    _exerciseCompleted = true;
  }

  bool displayStateChanged() {
    bool temp = _displayStateChanged;
    _displayStateChanged = false;
    return temp;
  }

  bool stepCompleted() {
    bool temp = _stepCompleted;
    _stepCompleted = false;
    return temp;
  }

  bool exerciseCompleted() {
    return _exerciseCompleted;
  }
}