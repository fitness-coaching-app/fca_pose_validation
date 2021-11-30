import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:fca_pose_validation/fca_pose_validation.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  void poseValidationTest() {
    Map<PoseLandmarkType, PoseLandmark> landmarks = {
      PoseLandmarkType.nose: PoseLandmark(
          PoseLandmarkType.nose,
          137.77960205078125,
          168.6473846435547,
          -298.82867431640625,
          0.9996742010116577),
      PoseLandmarkType.leftEyeInner: PoseLandmark(
          PoseLandmarkType.leftEyeInner,
          127.76939392089844,
          159.41427612304688,
          -272.462158203125,
          0.9995092153549194),
      PoseLandmarkType.leftEye: PoseLandmark(
          PoseLandmarkType.leftEye,
          128.631591796875,
          154.23739624023438,
          -272.5497741699219,
          0.9994767308235168),
      PoseLandmarkType.leftEyeOuter: PoseLandmark(
          PoseLandmarkType.leftEyeOuter,
          129.4815673828125,
          150.1455841064453,
          -272.2936096191406,
          0.9994046688079834),
      PoseLandmarkType.rightEyeInner: PoseLandmark(
          PoseLandmarkType.rightEyeInner,
          127.40452575683594,
          175.3235626220703,
          -273.15478515625,
          0.9994392991065979),
      PoseLandmarkType.rightEye: PoseLandmark(
          PoseLandmarkType.rightEye,
          127.85047912597656,
          180.70535278320312,
          -273.01922607421875,
          0.9993366599082947),
      PoseLandmarkType.rightEyeOuter: PoseLandmark(
          PoseLandmarkType.rightEyeOuter,
          128.31884765625,
          185.8217010498047,
          -272.9780578613281,
          0.9991889595985413),
      PoseLandmarkType.leftEar: PoseLandmark(
          PoseLandmarkType.leftEar,
          140.62533569335938,
          143.58541870117188,
          -124.15364837646484,
          0.9994063377380371),
      PoseLandmarkType.rightEar: PoseLandmark(
          PoseLandmarkType.rightEar,
          138.31326293945312,
          190.94125366210938,
          -130.16273498535156,
          0.9991651773452759),
      PoseLandmarkType.leftMouth: PoseLandmark(
          PoseLandmarkType.leftMouth,
          154.1791229248047,
          157.98094177246094,
          -243.30616760253906,
          0.9995601773262024),
      PoseLandmarkType.rightMouth: PoseLandmark(
          PoseLandmarkType.rightMouth,
          153.378173828125,
          178.78018188476562,
          -245.00038146972656,
          0.9994082450866699),
      PoseLandmarkType.leftShoulder: PoseLandmark(
          PoseLandmarkType.leftShoulder,
          215.15438842773438,
          114.90283966064453,
          -60.729209899902344,
          0.9820612668991089),
      PoseLandmarkType.rightShoulder: PoseLandmark(
          PoseLandmarkType.rightShoulder,
          212.10508728027344,
          231.65138244628906,
          -68.13395690917969,
          0.9684975743293762),
      PoseLandmarkType.leftElbow: PoseLandmark(
          PoseLandmarkType.leftElbow,
          291.6418151855469,
          78.87791442871094,
          -199.66519165039062,
          0.03387020155787468),
      PoseLandmarkType.rightElbow: PoseLandmark(
          PoseLandmarkType.rightElbow,
          290.2918701171875,
          259.891357421875,
          -154.8437957763672,
          0.024935871362686157),
      PoseLandmarkType.leftWrist: PoseLandmark(
          PoseLandmarkType.leftWrist,
          244.60287475585938,
          116.45191192626953,
          -420.33251953125,
          0.16253061592578888),
      PoseLandmarkType.rightWrist: PoseLandmark(
          PoseLandmarkType.rightWrist,
          315.45953369140625,
          247.59568786621094,
          -309.486328125,
          0.01975572668015957),
      PoseLandmarkType.leftPinky: PoseLandmark(
          PoseLandmarkType.leftPinky,
          239.92832946777344,
          125.60249328613281,
          -476.9287414550781,
          0.2380308210849762),
      PoseLandmarkType.rightPinky: PoseLandmark(
          PoseLandmarkType.rightPinky,
          326.2382507324219,
          250.49893188476562,
          -352.00250244140625,
          0.028100289404392242),
      PoseLandmarkType.leftIndex: PoseLandmark(
          PoseLandmarkType.leftIndex,
          228.88333129882812,
          134.4859161376953,
          -465.8786315917969,
          0.3426986038684845),
      PoseLandmarkType.rightIndex: PoseLandmark(
          PoseLandmarkType.rightIndex,
          322.3062438964844,
          242.4811553955078,
          -361.1141357421875,
          0.04540532827377319),
      PoseLandmarkType.leftThumb: PoseLandmark(
          PoseLandmarkType.leftThumb,
          237.06228637695312,
          136.34536743164062,
          -426.23260498046875,
          0.28703561425209045),
      PoseLandmarkType.rightThumb: PoseLandmark(
          PoseLandmarkType.rightThumb,
          319.63067626953125,
          239.07516479492188,
          -320.3394470214844,
          0.03576979041099548),
      PoseLandmarkType.leftHip: PoseLandmark(
          PoseLandmarkType.leftHip,
          374.2626953125,
          142.31980895996094,
          22.15593719482422,
          0.00017183595628011972),
      PoseLandmarkType.rightHip: PoseLandmark(
          PoseLandmarkType.rightHip,
          370.2230224609375,
          219.91302490234375,
          -20.98729705810547,
          0.0001436005550203845),
      PoseLandmarkType.leftKnee: PoseLandmark(
          PoseLandmarkType.leftKnee,
          504.1680908203125,
          141.91717529296875,
          -4.916294574737549,
          0.0001044698292389512),
      PoseLandmarkType.rightKnee: PoseLandmark(
          PoseLandmarkType.rightKnee,
          507.9433288574219,
          219.3130340576172,
          -40.48859405517578,
          0.00006974701682338491),
      PoseLandmarkType.leftAnkle: PoseLandmark(
          PoseLandmarkType.leftAnkle,
          629.7486572265625,
          151.01425170898438,
          178.0216064453125,
          0.00009829043119680136),
      PoseLandmarkType.rightAnkle: PoseLandmark(
          PoseLandmarkType.rightAnkle,
          626.1982421875,
          224.6453857421875,
          91.09834289550781,
          0.00006669622962363064),
      PoseLandmarkType.leftHeel: PoseLandmark(
          PoseLandmarkType.leftHeel,
          648.718994140625,
          151.97305297851562,
          193.791748046875,
          0.00010485457460163161),
      PoseLandmarkType.rightHeel: PoseLandmark(
          PoseLandmarkType.rightHeel,
          643.83349609375,
          227.78024291992188,
          101.39225769042969,
          0.00007615757931489497),
      PoseLandmarkType.leftFootIndex: PoseLandmark(
          PoseLandmarkType.leftFootIndex,
          668.1708374023438,
          157.65695190429688,
          86.92578887939453,
          0.0002131743385689333),
      PoseLandmarkType.rightFootIndex: PoseLandmark(
          PoseLandmarkType.rightFootIndex,
          664.636962890625,
          213.18954467773438,
          -22.101964950561523,
          0.0001709966454654932)
    };

    Pose inputPose = Pose(landmarks);
    PoseValidator poseValidator = PoseValidator(inputPose);
    print(poseValidator.getAngle(PoseLandmarkType.leftElbow,
        PoseLandmarkType.leftShoulder, PoseLandmarkType.leftWrist));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
            child: Column(children: [
          const Text('fca_pose_validation test'),
          TextButton(
            child: const Text('TEST', style: TextStyle(fontSize: 20.0)),
            onPressed: poseValidationTest,
          )
        ])),
      ),
    );
  }
}
