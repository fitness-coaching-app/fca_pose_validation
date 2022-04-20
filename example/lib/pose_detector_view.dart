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
  PoseDetector poseDetector = GoogleMlKit.vision.poseDetector(
      poseDetectorOptions: PoseDetectorOptions(
          model: PoseDetectionModel.base, mode: PoseDetectionMode.streamImage));
  bool isBusy = false;
  CustomPaint? customPaint;
  late String data;
  late ExerciseController controller;
  late ExerciseState currentState;

  String stepName = "";
  String criteria = "";
  String criteriaValue = "0";

  String poseSuggestionString = "";
  int fps = 0;

  @override
  void dispose() async {
    super.dispose();
    await poseDetector.close();
  }

  _asyncMethod() async {
    data = await rootBundle.loadString('assets/jumping-jacks-timer.yaml');
    controller = await ExerciseController(data);
    currentState = controller.getCurrentState();
    stepName = currentState.stepName;

    if (currentState.criteria == ExerciseDisplayCriteria.counter) {
      criteria = "Count";
    } else {
      criteria = "Timer";
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _asyncMethod();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      CameraView(
        title: 'Pose Detector',
        customPaint: customPaint,
        onImage: (inputImage) {
          processImage(inputImage);
        },
      ),
      Positioned(
          bottom: 30,
          left: 20,
          child: Row(children: <Widget>[
            TextButton(
                style: TextButton.styleFrom(
                  primary: Colors.blue,
                  backgroundColor: Colors.white,
                ),
                onPressed: () {
                  controller.dumpLogToFile("squats-10_${DateTime.now().toUtc().toString()}");
                },
                child: Text("Save to Log")),
            SizedBox(width: 25),
            TextButton(
                style: TextButton.styleFrom(
                  primary: Colors.white,
                  backgroundColor: Colors.red,
                ),
                onPressed: () {
                  // controller.dumpLogToFile('test');
                },
                child: Text("Clear Log"))
          ])),
      Positioned(
        top: 10,
        left: 20,
        child: Column(children: <Widget>[
          Text("$stepName\n$criteria: $criteriaValue\nSuggestion: $poseSuggestionString",
              style: TextStyle(
                backgroundColor: Colors.black,
                color: Colors.white,
              ))
        ]),
      ),
      Positioned(
        top: 10,
        right: 20,
        child: Text("$fps fps",
              style: TextStyle(
                backgroundColor: Colors.black,
                color: Colors.white,
              ))
      )
    ]);
  }

  Future<void> poseProcessorTest(Pose pose) async {
    controller.setPose(pose);
    controller.update();
    setState(() {
      poseSuggestionString = controller.getCurrentState().getWarning()["warningMessage"];
      if (controller.getCurrentState().criteria ==
          ExerciseDisplayCriteria.counter) {
        criteria = "Count";
        criteriaValue = controller.getCurrentState().repeatCount.toString();
      } else {
        criteria = "Timer";
        criteriaValue =
            controller.getCurrentState().timer.elapsedMilliseconds.toString() +
                " ms";
      }
    });
  }

  Future<void> processImage(InputImage inputImage) async {
    final DateTime time = DateTime.now();
    if (isBusy) return;
    isBusy = true;
    final poses = await poseDetector.processImage(inputImage);
    final DateTime detectionTime = DateTime.now();
    // print('Found ${poses.length} poses');
    if (poses.isNotEmpty) poseProcessorTest(poses[0]);
    final DateTime poseProcessorTime = DateTime.now();
    if (inputImage.inputImageData?.size != null &&
        inputImage.inputImageData?.imageRotation != null) {
      final painter = PosePainter(poses, inputImage.inputImageData!.size,
          inputImage.inputImageData!.imageRotation);
      customPaint = CustomPaint(painter: painter);
    } else {
      customPaint = null;
    }
    isBusy = false;
    if (mounted) {
      setState(() {});
    }
    final DateTime stopTime = DateTime.now();
    setState((){
      fps = ((1 / stopTime.difference(time).inMilliseconds) * 1000).toInt();
    });
    // print(
    //     "Process time: ${stopTime.difference(time).inMilliseconds} ms | ${detectionTime.difference(time).inMicroseconds} us | ${poseProcessorTime.difference(detectionTime).inMicroseconds} us");
  }
}
