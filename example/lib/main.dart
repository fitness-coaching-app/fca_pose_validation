import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'pose_detector_view.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
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

  Future<void> exerciseControllerLogicTest() async {
    final data = await rootBundle.loadString('assets/jumping-jacks.yaml');

  }

  Widget PoseDetectorApplication(){
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Pose Processor Test'),
          centerTitle: true,
          elevation: 0,
        ),
        body: SafeArea(
          child: Center(
            child:
              PoseDetectorView()
              // TextField()
            ),
          ),
        )
      );
  }

  Widget ExerciseControllerTestingApp(){
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Exercise Controller Test"),
          elevation: 0
        ),
        body: SafeArea(
          child: Center(
            child: TextButton(
              child: Text("Test..."),
              onPressed: exerciseControllerLogicTest
            )
          )
        )

      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return PoseDetectorApplication();
  }

}

class CustomCard extends StatelessWidget {
  final String _label;
  final Widget _viewPage;
  final bool featureCompleted;

  const CustomCard(this._label, this._viewPage,
      {this.featureCompleted = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.only(bottom: 10),
      child: ListTile(
        tileColor: Theme.of(context).primaryColor,
        title: Text(
          _label,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onTap: () {
          if (Platform.isIOS && !featureCompleted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text(
                    'This feature has not been implemented for iOS yet')));
          } else
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => _viewPage));
        },
      ),
    );
  }
}
