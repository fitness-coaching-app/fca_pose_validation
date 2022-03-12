import 'dart:ffi';

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

  List<double> _getPointsFromLandmarks(
      PoseLandmarkType landmarkA, PoseLandmarkType landmarkB) {
    return [
      _pose.landmarks[landmarkA]!.x,
      _pose.landmarks[landmarkB]!.x,
      _pose.landmarks[landmarkA]!.y,
      _pose.landmarks[landmarkB]!.y
    ];
  }

  String? touchChecker(PoseLandmarkType landmarkA, PoseLandmarkType landmarkB) {
    List<double> points = _getPointsFromLandmarks(landmarkA, landmarkB);
    if (kDebugMode) {
      print(points);
    }
    if ((points[0] - points[1] <= 15 ||
            points[0] - points[1] >= 0 ||
            points[1] - points[0] <= 15) &&
        (points[2] - points[3] <= 15 ||
            points[2] - points[3] >= 0 ||
            points[3] - points[2] <= 15)) {
      return "Touch!";
    } else {
      return "Not touch";
    }
  }
}
