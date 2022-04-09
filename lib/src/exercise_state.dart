import 'package:google_ml_kit/google_ml_kit.dart';

enum ExerciseDisplayCriteria { timer, counter }
enum DisplayState { preExercise, teach, exercise }

class ExerciseState {
  DisplayState _displayState = DisplayState.preExercise;
  int currentStep = 0;

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
  int targetTimeMillisec = 0;

  bool _warning = false;
  String _warningMessage = "";
  List<PoseLandmarkType> _warningPoseHighlight = [];

  int currentSubpose = -1; // -1 = N/A
  int expectedNextSubpose = 0;

  int correctSubpose = 0;
  int allSubpose = 0;

  void loadNewStep() {
    clearStateForNewStep();
  }

  DisplayState getDisplayState() => _displayState;

  void setDisplayState(DisplayState value) {
    _displayState = value;
    _displayStateChanged = true;
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
    bool temp = _exerciseCompleted;
    _exerciseCompleted = false;
    return temp;
  }
}