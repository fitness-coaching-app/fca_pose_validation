import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:yaml/yaml.dart';
import 'pose_processor.dart';

class Timer {
  int durationSecond;
  Timer(this.durationSecond);
}

class Counter {
  int repeat;
  String countOnId;

  Counter(this.repeat, this.countOnId);
}

class Criteria{
  Timer? timer;
  Counter? counter;

  Criteria(this.timer, this.counter);
  
  Criteria.loadFromYaml(YamlMap criteria){
   switch(criteria.keys.first){
      case "timer":
        timer = Timer(criteria['timer']['durationSecond']);
        break;
      case "counter":
        counter = Counter(criteria['counter']['repeat'], criteria['counter']['countOnId']);
        break;
    }
  }
}

class AngleDefinition{
  PoseLandmarkType landmarkA;
  PoseLandmarkType landmarkB;
  PoseLandmarkType vertex;
  List<String> conditions;

  AngleDefinition(this.landmarkA, this.landmarkB, this.vertex, this.conditions);
}

class TouchDefinition{
  List<PoseLandmarkType> landmarks;

  TouchDefinition(this.landmarks);
}

class Definition{
  AngleDefinition? angle;
  TouchDefinition? touch;
  
  Definition(this.angle, this.touch);
  Definition.loadFromYaml(YamlMap definition){
   switch(definition.keys.first){
      case "angle":
        String landmarkA = definition['angle']['landmarkA'];
        String landmarkB = definition['angle']['landmarkB'];
        String vertex = definition['angle']['vertex'];

        angle = AngleDefinition(PoseLandmarkType.values.firstWhere((e) => e.toString() == 'PoseLandmarkType.' + landmarkA),
            PoseLandmarkType.values.firstWhere((e) => e.toString() == 'PoseLandmarkType.' + landmarkB),
            PoseLandmarkType.values.firstWhere((e) => e.toString() == 'PoseLandmarkType.' + vertex)
            ,List<String>.from(definition['angle']['conditions']).toList());
        break;
      case "touch":
        List<PoseLandmarkType> landmarks = [];
        for(String landmark in definition['touch']['landmarks'] ){
          landmarks.add(PoseLandmarkType.values.firstWhere((e) => e.toString() == 'PoseLandmarkType.' + landmark));
        }
        touch = TouchDefinition(landmarks);
        break;
      }
  }
}

class ExercisePose{
  String? id;
  List<Definition> definitions = [];

  ExercisePose(this.id, this.definitions);

  ExercisePose.loadFromYaml(YamlMap pose){
    id = pose['id'];
    
    for(YamlMap def in pose['definitions']){
      definitions.add(Definition.loadFromYaml(def));
    }
  }
}

class ExerciseStep {
  String name = "";
  String mediaDir = "";
  bool bounce = false;
  Criteria criteria = Criteria(null, null);
  List<ExercisePose> poses = [];

  ExerciseStep(
      this.name, this.mediaDir, this.bounce, this.criteria, this.poses);
  
  ExerciseStep.loadFromYaml(YamlMap step){
    name = step['name'];
    mediaDir = step['mediaDir'];
    bounce = step['bounce'];
    criteria = Criteria.loadFromYaml(step['criteria']);

    for(YamlMap pose in step['poses']) {
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
    for(YamlMap s in steps){
      this.steps.add(ExerciseStep.loadFromYaml(s));
    }
  }
}

class ExerciseController {
  late Pose pose;
  PoseProcessor poseProcessor = PoseProcessor();

  void setPose(Pose pose) {
    this.pose = pose;
  }
}
