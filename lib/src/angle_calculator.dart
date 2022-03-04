import 'package:google_ml_kit/google_ml_kit.dart';
import 'dart:math';
import 'package:vector_math/vector_math.dart';
import 'dart:developer' as dev;

class AngleCalculator{
  late Pose _pose;

  void setPose(Pose pose){
    _pose = pose;
  }

  Vector2 _getVectorFromLandmarks(
      PoseLandmarkType landmarkA, PoseLandmarkType landmarkB) {
    return Vector2(
        _pose.landmarks[landmarkB]!.x - _pose.landmarks[landmarkA]!.x,
        _pose.landmarks[landmarkB]!.y - _pose.landmarks[landmarkA]!.y);
  }

  double _vectorMagnitude(Vector2 vector) {
    return sqrt(
        (vector.x * vector.x) + (vector.y * vector.y));
  }

  double getAngle(PoseLandmarkType landmarkA, PoseLandmarkType landmarkB,
      PoseLandmarkType landmarkC) {
    List<Vector2> vector = [
      _getVectorFromLandmarks(landmarkA, landmarkB),
      _getVectorFromLandmarks(landmarkA, landmarkC)
    ];
    dev.log("LANDMARK A: ${_pose.landmarks[landmarkA]!.x} | ${_pose.landmarks[landmarkA]!.y} | ${_pose.landmarks[landmarkA]!.z}");
    dev.log("LANDMARK B: ${_pose.landmarks[landmarkB]!.x} | ${_pose.landmarks[landmarkB]!.y} | ${_pose.landmarks[landmarkB]!.z}");
    dev.log("LANDMARK C: ${_pose.landmarks[landmarkC]!.x} | ${_pose.landmarks[landmarkC]!.y} | ${_pose.landmarks[landmarkC]!.z}");
    return acos(dot2(vector[0], vector[1]) /
        (_vectorMagnitude(vector[0]) * _vectorMagnitude(vector[1]))) * 180 / pi;
  }
}