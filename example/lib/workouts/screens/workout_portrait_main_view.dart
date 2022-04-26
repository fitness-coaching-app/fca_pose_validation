import '../../loading_view.dart';
import '../widgets/camera_view.dart';

import '../widgets/current_exercise_state_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

import '../pose_painter.dart';
import '../widgets/teach_view.dart';

import 'package:fca_pose_validation/fca_pose_processor.dart';

import 'dart:async' as dart_async;

// แก้ชื่อไฟล์ที่จะ save และท่าที่จะโหลด
const String workoutFilePath = 'assets/squats.yaml';
const String fileName = 'side-lunges-test';

class WorkoutMainView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _WorkoutMainViewState();
}

class _WorkoutMainViewState extends State<WorkoutMainView> {
  PoseDetector poseDetector = GoogleMlKit.vision.poseDetector(
      poseDetectorOptions: PoseDetectorOptions(
          model: PoseDetectionModel.base, mode: PoseDetectionMode.streamImage));
  bool isBusy = false;
  bool isLoaded = false;
  CustomPaint? customPaint;
  late String data;
  late ExerciseController controller;
  late ExerciseState currentState;

  String stepName = "";
  String criteria = "";
  String criteriaValue = "0";

  String poseSuggestionString = "";
  int fps = 0;

  bool isStepComplete = false;
  Timer? stepCompleteTimer;

  late final Future? futureLoadData;

  Widget? bodyWidget;
  DisplayState currentDisplayState = DisplayState.preExercise;

  @override
  void dispose() async {
    super.dispose();
    await poseDetector.close();
  }

  void onDisplayStateChange(DisplayState state) {
    print(currentState.timer.elapsedMilliseconds);
    setState(() {
      currentDisplayState = state;
    });
  }

  void onStepComplete() {
    // Step completed, display correct tick for 5 seconds
    setState(() {
      isStepComplete = true;
    });
    dart_async.Timer.periodic(Duration(seconds: 5), (timer) {
      timer.cancel();
      setState(() {
        isStepComplete = false;
      });
    });
  }

  void onExerciseComplete() {
    // TODO: Change the page to exercise summary
  }

  Future<String> loadData() async {
    // TODO: Load course data from the API
    data = await rootBundle
        .loadString(workoutFilePath); // TODO: Load .yaml file here
    controller = ExerciseController(data,
        onDisplayStateChange: onDisplayStateChange,
        onStepComplete: onStepComplete,
        onExerciseComplete: onExerciseComplete);
    currentState = controller.getCurrentState();
    stepName = currentState.stepName;

    if (currentState.criteria == ExerciseDisplayCriteria.counter) {
      criteria = "Count";
    } else {
      criteria = "Timer";
    }
    controller.preExerciseCompleted();
    controller.teachCompleted();

    return "OK";
  }

  @override
  void initState() {
    super.initState();
    futureLoadData = loadData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: futureLoadData,
        builder: (BuildContext context, AsyncSnapshot snap) {
          if (!snap.hasData) {
            return const Loading();
          } else {
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
            return Material(
              child: Stack(children: [
                Column(children: <Widget>[
                  CurrentExerciseStateBar(
                      currentState: controller.getCurrentState(),
                      isComplete: isStepComplete),
                  (() {
                    if (isStepComplete) {
                      return Text("Complete");
                    }
                    if (currentDisplayState == DisplayState.teach) {
                      return TeachView(onComplete: () {
                        controller.teachCompleted();
                      });
                    }

                    return CameraView(
                      customPaint: customPaint,
                      onImage: (InputImage inputImage) =>
                          processImage(inputImage),
                    );
                  }())
                ]),
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
                            controller.dumpLogToFile(fileName);
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
              ]),
            );
          }
        });
  }

  Future<void> processImage(InputImage inputImage) async {
    if (isBusy) return;
    isBusy = true;
    final poses = await poseDetector.processImage(inputImage);
    if (poses.isNotEmpty) processPose(poses[0]);
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
  }

  Future<void> processPose(Pose pose) async {
    controller.setPose(pose);
    controller.update();
  }
}
