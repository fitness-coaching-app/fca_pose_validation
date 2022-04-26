import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:yaml/yaml.dart';

class Timer {
  int duration;

  Timer(this.duration);
}

class Counter {
  int repeat;
  String countOnId;

  Counter(this.repeat, this.countOnId);
}

class Criteria {
  Timer? timer;
  Counter? counter;

  Criteria(this.timer, this.counter);

  Criteria.loadFromYaml(YamlMap criteria) {
    switch (criteria.keys.first) {
      case "timer":
        timer = Timer(criteria['timer']['duration']);
        break;
      case "counter":
        counter = Counter(
            criteria['counter']['repeat'], criteria['counter']['countOnId']);
        break;
    }
  }
}

class AngleDefinition {
  List<PoseLandmarkType> landmarks = [];
  late PoseLandmarkType vertex;

  AngleDefinition({required this.landmarks, required this.vertex});

  AngleDefinition.loadFromYaml(YamlMap angle) {
    for (String landmark in angle['landmarks']) {
      landmarks.add(PoseLandmarkType.values
          .firstWhere((e) => e.toString() == 'PoseLandmarkType.' + landmark));
    }

    vertex = PoseLandmarkType.values.firstWhere(
        (e) => e.toString() == 'PoseLandmarkType.' + angle['vertex']);
    // range = List<int>.from(angle['range'].toList());
  }
}

class TouchDefinition {
  // bool touch;
  List<PoseLandmarkType> landmarks = [];

  TouchDefinition({required this.landmarks});

  TouchDefinition.loadFromYaml(YamlMap touch) {
    for (String landmark in touch['landmarks']) {
      landmarks.add(PoseLandmarkType.values
          .firstWhere((e) => e.toString() == 'PoseLandmarkType.' + landmark));
    }

    // range = List<int>.from(angle['range'].toList());
  }
}

class Definition {
  String calculator = "";
  Map<String, dynamic>? withParams = {};
  bool count = false;

  Definition(
      {required this.calculator, this.withParams, this.count = false});

  Definition.loadFromYaml(YamlMap definition) {
    calculator = definition["calculator"]!;
    withParams = {};
    for(String i in definition["with"].keys){
      if(i == "range"){
        List<int> temp = [];
        for(var a in definition["with"][i]){
          temp.add(a);
        }
        withParams![i] = temp;
      }
      else{
        withParams![i] = definition["with"][i];
      }


      print(withParams);
    }
    print("TEST");
    print(withParams);
    // count = definition["count"];
  }
}

class WarningPose {
  List<Definition> definitions = [];
  String? warningMessage = "";

  WarningPose(this.definitions, this.warningMessage);

  WarningPose.loadFromYaml(YamlMap warningPose) {
    for (YamlMap def in warningPose['definitions']) {
      definitions.add(Definition.loadFromYaml(def));
    }

    warningMessage = warningPose['warningMessage'];
  }
}

class ExercisePose {
  String? id;
  Map<String, Definition> definitions = {};

  ExercisePose(this.id, this.definitions);

  ExercisePose.loadFromYaml(YamlMap pose) {
    id = pose['id'];
    for (YamlMap def in pose['definitions']) {
      print(def);
      definitions[def["calculator"]] = Definition.loadFromYaml(def);
    }
  }
}

class CalculatorDefinition {
  String name = "";
  AngleDefinition? angle;
  TouchDefinition? touch;

  CalculatorDefinition(this.angle, this.touch);

  CalculatorDefinition.loadFromYaml(YamlMap calculator) {
    name = calculator["name"];
    if (calculator["angle"] != null) {
      angle = AngleDefinition.loadFromYaml(calculator['angle']);
    } else if (calculator["touch"] != null) {
      touch = TouchDefinition.loadFromYaml(calculator['touch']);
    }
  }
}

class ExerciseStep {
  String name = "";
  String mediaDir = "";
  bool bounce = false;
  Criteria criteria = Criteria(null, null);
  String posturePosition = "";
  String cameraAngle = "";
  String facing = "";
  Map<String,CalculatorDefinition> calculators = {};
  List<ExercisePose> poses = []; // Only have 2 stages
  List<WarningPose> warningPoses = [];

  ExerciseStep(
      {required this.name,
      required this.mediaDir,
      required this.bounce,
      required this.criteria,
      required this.posturePosition,
      required this.cameraAngle,
      required this.facing,
      required this.calculators,
      required this.poses});

  ExerciseStep.loadFromYaml(YamlMap step) {
    name = step['name'];
    mediaDir = step['mediaDir'];
    bounce = step['bounce'];
    criteria = Criteria.loadFromYaml(step['criteria']);
    posturePosition = step['posturePosition'];
    cameraAngle = step['cameraAngle'];
    facing = step['facing'];

    for(YamlMap calculator in step['calculators']){
      print(calculator);
      calculators[calculator['name']] = CalculatorDefinition.loadFromYaml(calculator);
    }
    for (YamlMap pose in step['poses']) {
      print(pose);
      poses.add(ExercisePose.loadFromYaml(pose));
    }
    if (step['warningPoses'] != null) {
      for (YamlMap warningPose in step['warningPoses']) {
        poses.add(ExercisePose.loadFromYaml(warningPose));
      }
    }
    print("complete!");
  }
}

class ExerciseDefinition {
  String? id;
  String? name;
  List<ExerciseStep> steps = [];

  ExerciseDefinition(String definition) {
    YamlMap defMap = loadYaml(definition);
    final steps = defMap["steps"];
    for (YamlMap s in steps) {
      this.steps.add(ExerciseStep.loadFromYaml(s));
    }
  }
}
