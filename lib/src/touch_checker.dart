import 'package:flutter/foundation.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'dart:math';
import 'package:vector_math/vector_math.dart';
import 'dart:developer' as dev;

class TouchChecker {
  late Pose _pose;

  void setPose(Pose pose) {
    _pose = pose;
  }

  List<double> _getCoordinateFromLandmarks(
      PoseLandmarkType landmarkA, PoseLandmarkType landmarkB) {
    return [
      _pose.landmarks[landmarkA]!.x,
      _pose.landmarks[landmarkB]!.x,
      _pose.landmarks[landmarkA]!.y,
      _pose.landmarks[landmarkB]!.y
    ];
  }

  String? touchChecker(PoseLandmarkType landmarkA, PoseLandmarkType landmarkB) {
    List<double> coordinates =
        _getCoordinateFromLandmarks(landmarkA, landmarkB);
    if (kDebugMode) {
      print(coordinates);
    }
    // dev.log("LANDMARK A: ${_pose.landmarks[landmarkA]!.x} | ${_pose.landmarks[landmarkA]!.y} | ${_pose.landmarks[landmarkA]!.z}");
    // dev.log("LANDMARK B: ${_pose.landmarks[landmarkB]!.x} | ${_pose.landmarks[landmarkB]!.y} | ${_pose.landmarks[landmarkB]!.z}");

    // set point of touch each other must not exceed 15 pixels in X and Y coordinates.
    if ((coordinates[0] - coordinates[1] >= 15 ||
        coordinates[2] - coordinates[3] >= 5)) {
      return "Not Touch!";
    } else {
      return "Touch";
    }
  }
}
