import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:yaml/yaml.dart';

class Timer {
  int durationSecond;

  Timer(this.durationSecond);
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
        timer = Timer(criteria['timer']['durationSecond']);
        break;
      case "counter":
        counter = Counter(
            criteria['counter']['repeat'], criteria['counter']['countOnId']);
        break;
    }
  }
}

class Range {
  int from = 0;
  int to = 0;

  Range(this.from, this.to);
  Range.loadFromYaml(YamlMap range){
    from = range['from'];
    to = range['to'];
  }
}

class AngleDefinition {
  List<PoseLandmarkType> landmarks = [];
  late PoseLandmarkType vertex;
  Range range = Range(0,0);

  AngleDefinition(this.landmarks, this.vertex, this.range);
  AngleDefinition.loadFromYaml(YamlMap angle){
    for(String landmark in angle['landmarks']){
      landmarks.add(PoseLandmarkType.values.firstWhere((e) => e.toString() == 'PoseLandmarkType.' + landmark));
    }

    vertex = PoseLandmarkType.values.firstWhere((e) => e.toString() == 'PoseLandmarkType.' + angle['vertex']);
    range = Range.loadFromYaml(angle['range']);
  }
}

class TouchDefinition {
  List<PoseLandmarkType> landmarks;

  TouchDefinition(this.landmarks);
}

class Definition {
  AngleDefinition? angle;
  TouchDefinition? touch;

  Definition(this.angle, this.touch);

  Definition.loadFromYaml(YamlMap definition) {
    switch (definition.keys.first) {
      case "angle":
        angle = AngleDefinition.loadFromYaml(definition['angle']);
        break;
      case "touch":
        List<PoseLandmarkType> landmarks = [];
        for (String landmark in definition['touch']['landmarks']) {
          landmarks.add(PoseLandmarkType.values.firstWhere(
              (e) => e.toString() == 'PoseLandmarkType.' + landmark));
        }
        touch = TouchDefinition(landmarks);
        break;
    }
  }
}

class ExercisePose {
  String? id;
  List<Definition> definitions = [];

  ExercisePose(this.id, this.definitions);

  ExercisePose.loadFromYaml(YamlMap pose) {
    id = pose['id'];

    for (YamlMap def in pose['definitions']) {
      definitions.add(Definition.loadFromYaml(def));
    }
  }
}

class ExerciseStep {
  String name = "";
  String mediaDir = "";
  bool bounce = false;
  Criteria criteria = Criteria(null, null);
  List<ExercisePose> poses = []; // Only have 2 stages

  ExerciseStep(
      this.name, this.mediaDir, this.bounce, this.criteria, this.poses);

  ExerciseStep.loadFromYaml(YamlMap step) {
    name = step['name'];
    mediaDir = step['mediaDir'];
    bounce = step['bounce'];
    criteria = Criteria.loadFromYaml(step['criteria']);

    for (YamlMap pose in step['poses']) {
      poses.add(ExercisePose.loadFromYaml(pose));
    }
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
