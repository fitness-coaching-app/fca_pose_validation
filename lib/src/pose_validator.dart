import 'package:google_ml_kit/google_ml_kit.dart';
import 'dart:math';
import 'package:vector_math/vector_math.dart';

class PoseValidator {
  Pose pose;

  PoseValidator(this.pose);

  Vector3 getPoseVectorPosition(PoseLandmarkType landmark) => Vector3(
      pose.landmarks[landmark]!.x,
      pose.landmarks[landmark]!.y,
      pose.landmarks[landmark]!.z);

  double getAngle(PoseLandmarkType landmark1, PoseLandmarkType landmark2,
      PoseLandmarkType landmark3) {
    List<Vector3> landmarkVector = [
      getPoseVectorPosition(landmark1),
      getPoseVectorPosition(landmark2),
      getPoseVectorPosition(landmark3)
    ];

    return 0.000;
  }
}
