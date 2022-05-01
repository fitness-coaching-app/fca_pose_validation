import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'dart:math';
import 'package:vector_math/vector_math.dart';
import 'dart:developer' as dev;
import 'dart:core';

class TouchChecker {
  static List<double> _getCoordinateFromLandmarks(
      PoseLandmarkType landmarkA, PoseLandmarkType landmarkB, Pose pose) {
    return [
      pose.landmarks[landmarkA]!.x,
      pose.landmarks[landmarkB]!.x,
      pose.landmarks[landmarkA]!.y,
      pose.landmarks[landmarkB]!.y
    ];
  }

  static double check(PoseLandmarkType landmarkA, PoseLandmarkType landmarkB, Pose pose) {
    List<double> coordinates =
        _getCoordinateFromLandmarks(landmarkA, landmarkB, pose);
    if (kDebugMode) {
      print(coordinates);
    }
    // dev.log("LANDMARK A: ${_pose.landmarks[landmarkA]!.x} | ${_pose.landmarks[landmarkA]!.y} | ${_pose.landmarks[landmarkA]!.z}");
    // dev.log("LANDMARK B: ${_pose.landmarks[landmarkB]!.x} | ${_pose.landmarks[landmarkB]!.y} | ${_pose.landmarks[landmarkB]!.z}");

    // set point of touch each other must not exceed 25 pixels in X and Y coordinates.
    //False = Not Toucflkih
    //True = Touch
    if (((coordinates[0] - coordinates[1]).abs() <= 25 && (coordinates[2] - coordinates[3]).abs() <= 25)) {
      return 1;
    } else {
      return 0;
    }
  }
}
