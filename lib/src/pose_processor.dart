import 'package:google_ml_kit/google_ml_kit.dart';
import 'dart:math';
import 'package:vector_math/vector_math.dart';

class PoseProcessor {
  Pose pose;

  PoseProcessor(this.pose);

  Vector3 _getVectorFromLandmarks(
      PoseLandmarkType landmarkA, PoseLandmarkType landmarkB) {
    return Vector3(
        pose.landmarks[landmarkB]!.x - pose.landmarks[landmarkA]!.x,
        pose.landmarks[landmarkB]!.y - pose.landmarks[landmarkA]!.y,
        pose.landmarks[landmarkB]!.z - pose.landmarks[landmarkA]!.z);
  }

  double vectorMagnitude(Vector3 vector) {
    return sqrt(
        vector.x * vector.x + vector.y * vector.y + vector.z * vector.z);
  }

  double getAngle(PoseLandmarkType landmarkA, PoseLandmarkType landmarkB,
      PoseLandmarkType landmarkC) {
    List<Vector3> vector = [
      _getVectorFromLandmarks(landmarkA, landmarkB),
      _getVectorFromLandmarks(landmarkA, landmarkC)
    ];
    print(vector);
    return acos(dot3(vector[0], vector[1]) /
        (vectorMagnitude(vector[0]) * vectorMagnitude(vector[1])));
  }
}
