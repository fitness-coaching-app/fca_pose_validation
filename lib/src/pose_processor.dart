import 'package:fca_pose_validation/src/angle_calculator.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'dart:math';
import 'package:vector_math/vector_math.dart';
import 'dart:developer' as dev;
import 'package:yaml/yaml.dart';

class PoseProcessor {
  AngleCalculator angle = AngleCalculator();
  YamlMap definition;

  PoseProcessor(this.definition);

  void setPose(Pose pose){
    angle.setPose(pose);
  }

  void yamlTest(){
    print(definition["Test"]["Hello"]);

  }
}
