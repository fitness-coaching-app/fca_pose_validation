import 'package:google_ml_kit/google_ml_kit.dart';
import 'dart:convert';

class PoseStep{
  final List<Pose> poses = [];
  final List<DateTime> poseTimestamp = [];
  final List<Map<String, double>> computedDefinition = [];
  final List<int> currentSubpose = [];
  int length = 0;

  PoseStep();
  void addEntry(Pose pose, Map<String, double> computedDefinition, int currentSubpose){
    poses.add(pose);
    poseTimestamp.add(DateTime.now());
    this.computedDefinition.add(computedDefinition);
    this.currentSubpose.add(currentSubpose);
    ++length;
  }
}

class PoseLogger{
  String _userId;
  String _courseId;
  DateTime? _startTime;
  List<PoseStep> _steps = [];
  int _currentStep = -1;

  PoseLogger(this._userId, this._courseId);

  void startNewStep(){
    ++_currentStep;
    _steps.add(PoseStep());
  }

  void log(Pose pose, Map<String, double> computedDefinition,int currentSubpose){
    if(_currentStep < 0) return;

    _startTime ??= DateTime.now();
    _steps[_currentStep].addEntry(pose, computedDefinition, currentSubpose);
  }

  String toJSON(){
    Map<String, dynamic> data = {
      'userId': _userId,
      'courseId': _courseId,
      'startTimeUTC': _startTime!.toUtc().toIso8601String(),
      'steps': []
    };
    for(int i = 0;i < _steps.length;++i){
      data["steps"].add({
          'recordedData': []
        });
      for(int j = 0;j < _steps[i].length;++j){
        final int timeElapsed = _steps[i].poseTimestamp[j].difference(_startTime!).inMilliseconds;
        final int currentSubpose = _steps[i].currentSubpose[j];
        final List<Map<String, dynamic>> rawPoseData = [];
        final Map<String, double> rawComputedDefinition = _steps[i].computedDefinition[j];

        _steps[i].poses[j].landmarks.forEach((PoseLandmarkType key, PoseLandmark value) {
          rawPoseData.add({
            'landmark': key.toString(),
            'coordinate': [value.x, value.y, value.z],
            'likelihood': value.likelihood
          });
        });


        data["steps"][i]["recordedData"].add({
          'timeElapsed': timeElapsed,
          'currentSubpose': currentSubpose,
          'rawPoseData': rawPoseData,
          'rawComputedDefinition': rawComputedDefinition
        });
      }
    }

    return jsonEncode(data);
  }
}