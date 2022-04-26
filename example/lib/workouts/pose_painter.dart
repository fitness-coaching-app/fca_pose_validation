import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

import './coordinates_translator.dart';

class PosePainter extends CustomPainter {
  // PosePainter(this.poses, this.absoluteImageSize, this.rotation, this.armAngle, this.elbowAngle);
  PosePainter(this.poses, this.absoluteImageSize, this.rotation);

  final List<Pose> poses;
  final Size absoluteImageSize;
  final InputImageRotation rotation;

  @override
  void paint(Canvas canvas, Size size) {
    final leftDot = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color.fromRGBO(252, 119, 3, 1.0);
    final rightDot = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color.fromRGBO(3, 223, 252, 1);
    final dot = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.purpleAccent;

    final bodyLine = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..color = Colors.white;

    poses.forEach((pose) {
      void paintLine(
          PoseLandmarkType type1, PoseLandmarkType type2, Paint paintType) {
        PoseLandmark joint1 = pose.landmarks[type1]!;
        PoseLandmark joint2 = pose.landmarks[type2]!;
        canvas.drawLine(
            Offset(translateX(joint1.x, rotation, size, absoluteImageSize),
                translateY(joint1.y, rotation, size, absoluteImageSize)),
            Offset(translateX(joint2.x, rotation, size, absoluteImageSize),
                translateY(joint2.y, rotation, size, absoluteImageSize)),
            paintType);
      }

      //Draw arms
      paintLine(
          PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow, bodyLine);
      paintLine(
          PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist, bodyLine);
      paintLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow,
          bodyLine);
      paintLine(
          PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist, bodyLine);

      //Draw Body
      paintLine(
          PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip, bodyLine);
      paintLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip,
          bodyLine);
      paintLine(PoseLandmarkType.rightHip, PoseLandmarkType.leftHip,
          bodyLine);
      paintLine(
          PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder, bodyLine);

      //Draw legs
      paintLine(
          PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee, bodyLine);
      paintLine(
          PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee, bodyLine);

      paintLine(
          PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle, bodyLine);
      paintLine(
          PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle, bodyLine);

      pose.landmarks.forEach((landmarkType, landmark) {
        canvas.drawCircle(
            Offset(
              translateX(landmark.x, rotation, size, absoluteImageSize),
              translateY(landmark.y, rotation, size, absoluteImageSize),
            ),
            6,
            dot);
      });
    });
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return oldDelegate.absoluteImageSize != absoluteImageSize ||
        oldDelegate.poses != poses;
  }
}
