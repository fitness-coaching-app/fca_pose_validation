import 'package:google_ml_kit/google_ml_kit.dart';
import 'dart:math';
import 'package:vector_math/vector_math.dart';
import 'dart:developer' as dev;

class AngleCalculator{
  static Vector2 _getVectorFromLandmarks(
      PoseLandmarkType landmarkA, PoseLandmarkType landmarkB, Pose pose) {
    return Vector2(
        pose.landmarks[landmarkB]!.x - pose.landmarks[landmarkA]!.x,
        pose.landmarks[landmarkB]!.y - pose.landmarks[landmarkA]!.y);
  }

  static double _vectorMagnitude(Vector2 vector) {
    return sqrt(
        (vector.x * vector.x) + (vector.y * vector.y));
  }

  static double computeAngle(PoseLandmarkType landmarkA, PoseLandmarkType landmarkB,
      PoseLandmarkType landmarkC, Pose pose) {
    List<Vector2> vector = [
      _getVectorFromLandmarks(landmarkA, landmarkB, pose),
      _getVectorFromLandmarks(landmarkA, landmarkC, pose)
    ];
    return acos(dot2(vector[0], vector[1]) /
        (_vectorMagnitude(vector[0]) * _vectorMagnitude(vector[1]))) * 180 / pi;
  }
}