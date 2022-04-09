import 'package:fca_pose_validation/fca_pose_processor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

import 'camera_view.dart';
import 'painters/pose_painter.dart';

class PoseDetectorView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PoseDetectorViewState();
}

class _PoseDetectorViewState extends State<PoseDetectorView> {
  PoseDetector poseDetector = GoogleMlKit.vision.poseDetector(poseDetectorOptions: PoseDetectorOptions(model: PoseDetectionModel.base,mode: PoseDetectionMode.streamImage));
  bool isBusy = false;
  CustomPaint? customPaint;
  late String data;
  late ExerciseController controller;

  @override
  void dispose() async {
    super.dispose();
    await poseDetector.close();
  }

  _asyncMethod() async {
    data = await rootBundle.loadString('assets/jumping-jacks-timer.yaml');
    controller = ExerciseController(data);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_){
            _asyncMethod();
    });
  }

  @override
  Widget build(BuildContext context) {
    return CameraView(
      title: 'Pose Detector',
      customPaint: customPaint,
      onImage: (inputImage) {
        processImage(inputImage);
      },
    );
  }

  Future<void> poseProcessorTest(Pose pose) async {
    controller.setPose(pose);
    controller.update();
  }

  Future<void> processImage(InputImage inputImage) async {
    final DateTime time = DateTime.now();
    if (isBusy) return;
    isBusy = true;
    final poses = await poseDetector.processImage(inputImage);
    final DateTime detectionTime = DateTime.now();
    // print('Found ${poses.length} poses');
    if(poses.isNotEmpty) poseProcessorTest(poses[0]);
    final DateTime poseProcessorTime = DateTime.now();
    if (inputImage.inputImageData?.size != null &&
        inputImage.inputImageData?.imageRotation != null) {
      final painter = PosePainter(poses, inputImage.inputImageData!.size,
          inputImage.inputImageData!.imageRotation);
      customPaint = CustomPaint(painter: painter);
      // customPaint = null;
    } else {
      customPaint = null;
    }
    isBusy = false;
    if (mounted) {
      setState(() {});
    }
    final DateTime stopTime = DateTime.now();
    print("Process time: ${stopTime.difference(time).inMilliseconds} ms | ${detectionTime.difference(time).inMicroseconds} us | ${poseProcessorTime.difference(detectionTime).inMicroseconds} us");
  }
}
