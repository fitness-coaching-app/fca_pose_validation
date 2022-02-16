import 'package:google_ml_kit/google_ml_kit.dart';
import 'dart:math';
import 'package:vector_math/vector_math.dart';
import  'dart:developer' as dev;

class PoseProcessor {
  Pose pose;

  PoseProcessor(this.pose);

  Vector2 _getVectorFromLandmarks(
      PoseLandmarkType landmarkA, PoseLandmarkType landmarkB) {
    return Vector2(
        pose.landmarks[landmarkB]!.x - pose.landmarks[landmarkA]!.x,
        pose.landmarks[landmarkB]!.y - pose.landmarks[landmarkA]!.y);
  }

  double vectorMagnitude(Vector2 vector) {
    return sqrt(
        (vector.x * vector.x) + (vector.y * vector.y));
  }

  double getAngle(PoseLandmarkType landmarkA, PoseLandmarkType landmarkB,
      PoseLandmarkType landmarkC) {
    List<Vector2> vector = [
      _getVectorFromLandmarks(landmarkA, landmarkB),
      _getVectorFromLandmarks(landmarkA, landmarkC)
    ];
    dev.log("LANDMARK A: ${pose.landmarks[landmarkA]!.x} | ${pose.landmarks[landmarkA]!.y} | ${pose.landmarks[landmarkA]!.z}");
    dev.log("LANDMARK B: ${pose.landmarks[landmarkB]!.x} | ${pose.landmarks[landmarkB]!.y} | ${pose.landmarks[landmarkB]!.z}");
    dev.log("LANDMARK C: ${pose.landmarks[landmarkC]!.x} | ${pose.landmarks[landmarkC]!.y} | ${pose.landmarks[landmarkC]!.z}");
    return acos(dot2(vector[0], vector[1]) /
        (vectorMagnitude(vector[0]) * vectorMagnitude(vector[1]))) * 180 / pi;
  }
}
