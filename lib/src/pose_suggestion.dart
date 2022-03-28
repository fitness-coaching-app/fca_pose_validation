import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:collection/collection.dart';

enum Side{
  left,
  right
}

enum Direction{
  positive,
  negative
}

final List<String> sentenceFormat = [
  "#DIRECTION your #SIDE #PART #AUX",
  "Put your #SIDE #PART #DIRECTION #AUX",
  "Put your #SIDE #PART #DIRECTION your body #AUX",
  "#DIRECTION your #PART #AUX"
];
final List<List<String>> directionPair = [
  ["lift", "put down"],
  ["stretch", "fold"],
  ["toward", "against"],
  ["forward", "backward"],
  ["higher", "lower"]
];

class SuggestionSentence{
  List<PoseLandmarkType> landmarks = [];
  late PoseLandmarkType vertex;

  String format;
  Side side;
  List<String> directionString;
  String part;

  SuggestionSentence(this.landmarks, this.vertex, this.side, this.format, this.directionString, this.part);

  String generate(Direction direction, {String aux = ""}){
    return format
        .replaceFirst("#DIRECTION", directionString[direction.index])
        .replaceFirst("#SIDE", side == Side.left? "left": "right")
        .replaceFirst("#PART", part)
        .replaceFirst("#AUX", aux);
  }

  bool compareLandmarks(List<PoseLandmarkType> landmarks,PoseLandmarkType vertex){
    return (const ListEquality().equals(this.landmarks,landmarks)) && (this.vertex == vertex);
  }
}

class SuggestionSentenceList{
  // *** STAND / FRONT ***
  static final List<SuggestionSentence> _standFrontList = [
    // forearm
    SuggestionSentence([PoseLandmarkType.leftWrist, PoseLandmarkType.leftShoulder], PoseLandmarkType.leftElbow, Side.left, sentenceFormat[0], directionPair[0], "forearm"),
    SuggestionSentence([PoseLandmarkType.rightWrist, PoseLandmarkType.rightShoulder], PoseLandmarkType.rightElbow, Side.right, sentenceFormat[0], directionPair[0], "forearm"),
    // arm
    SuggestionSentence([PoseLandmarkType.leftElbow, PoseLandmarkType.leftHip], PoseLandmarkType.leftShoulder, Side.left, sentenceFormat[0], directionPair[0], "arm"),
    SuggestionSentence([PoseLandmarkType.rightElbow, PoseLandmarkType.rightHip], PoseLandmarkType.rightShoulder, Side.right, sentenceFormat[0], directionPair[0], "arm"),
    // leg
    SuggestionSentence([PoseLandmarkType.leftKnee, PoseLandmarkType.rightHip], PoseLandmarkType.leftHip, Side.left, sentenceFormat[0], directionPair[1], "leg"),
    SuggestionSentence([PoseLandmarkType.rightKnee, PoseLandmarkType.leftHip], PoseLandmarkType.rightHip, Side.right, sentenceFormat[0], directionPair[1], "leg"),
    // knee
    SuggestionSentence([PoseLandmarkType.leftHip, PoseLandmarkType.leftAnkle], PoseLandmarkType.leftKnee, Side.left, sentenceFormat[0], directionPair[1], "knee"),
    SuggestionSentence([PoseLandmarkType.rightHip, PoseLandmarkType.rightAnkle], PoseLandmarkType.rightKnee, Side.right, sentenceFormat[0], directionPair[1], "knee"),
  ];

  // *** STAND / SIDE ***
  static final List<SuggestionSentence> _standSideList = [
    // forearm
    SuggestionSentence([PoseLandmarkType.leftWrist, PoseLandmarkType.leftShoulder], PoseLandmarkType.leftElbow, Side.left, sentenceFormat[0], directionPair[0], "forearm"),
    SuggestionSentence([PoseLandmarkType.rightWrist, PoseLandmarkType.rightShoulder], PoseLandmarkType.rightElbow, Side.right, sentenceFormat[0], directionPair[0], "forearm"),
    // arm
    SuggestionSentence([PoseLandmarkType.leftElbow, PoseLandmarkType.leftHip], PoseLandmarkType.leftShoulder, Side.left, sentenceFormat[0], directionPair[0], "arm"),
    SuggestionSentence([PoseLandmarkType.rightElbow, PoseLandmarkType.rightHip], PoseLandmarkType.rightShoulder, Side.right, sentenceFormat[0], directionPair[0], "arm"),
    // leg
    SuggestionSentence([PoseLandmarkType.leftKnee, PoseLandmarkType.rightHip], PoseLandmarkType.leftHip, Side.left, sentenceFormat[0], directionPair[0], "leg"),
    SuggestionSentence([PoseLandmarkType.rightKnee, PoseLandmarkType.leftHip], PoseLandmarkType.rightHip, Side.right, sentenceFormat[0], directionPair[0], "leg"),
    // foot
    SuggestionSentence([PoseLandmarkType.leftHip, PoseLandmarkType.leftAnkle], PoseLandmarkType.leftKnee, Side.left, sentenceFormat[0], directionPair[0], "foot"),
    SuggestionSentence([PoseLandmarkType.rightHip, PoseLandmarkType.rightAnkle], PoseLandmarkType.rightKnee, Side.right, sentenceFormat[0], directionPair[0], "foot"),
  ];

  // *** LIE DOWN / FACE DOWN / FRONT ***
  static final List<SuggestionSentence> _lieDownFaceDownFrontList = [
    // forearm
    SuggestionSentence([PoseLandmarkType.leftWrist, PoseLandmarkType.leftShoulder], PoseLandmarkType.leftElbow, Side.left, sentenceFormat[3], directionPair[4], "body"),
    SuggestionSentence([PoseLandmarkType.rightWrist, PoseLandmarkType.rightShoulder], PoseLandmarkType.rightElbow, Side.right, sentenceFormat[3], directionPair[4], "body"),
    // arm
    SuggestionSentence([PoseLandmarkType.leftElbow, PoseLandmarkType.leftHip], PoseLandmarkType.leftShoulder, Side.left, sentenceFormat[3], directionPair[4], "body"),
    SuggestionSentence([PoseLandmarkType.rightElbow, PoseLandmarkType.rightHip], PoseLandmarkType.rightShoulder, Side.right, sentenceFormat[3], directionPair[4], "body"),
  ];

  // *** LIE DOWN / FACE DOWN / SIDE ***
  static final List<SuggestionSentence> _lieDownFaceDownSideList = [
    // forearm
    SuggestionSentence([PoseLandmarkType.leftWrist, PoseLandmarkType.leftShoulder], PoseLandmarkType.leftElbow, Side.left, sentenceFormat[3], directionPair[4], "body"),
    SuggestionSentence([PoseLandmarkType.rightWrist, PoseLandmarkType.rightShoulder], PoseLandmarkType.rightElbow, Side.right, sentenceFormat[3], directionPair[4], "body"),
    // arm
    SuggestionSentence([PoseLandmarkType.leftElbow, PoseLandmarkType.leftHip], PoseLandmarkType.leftShoulder, Side.left, sentenceFormat[3], directionPair[4], "body"),
    SuggestionSentence([PoseLandmarkType.rightElbow, PoseLandmarkType.rightHip], PoseLandmarkType.rightShoulder, Side.right, sentenceFormat[3], directionPair[4], "body"),
    // hip
    SuggestionSentence([PoseLandmarkType.leftKnee, PoseLandmarkType.rightHip], PoseLandmarkType.leftHip, Side.left, sentenceFormat[3], directionPair[4], "hip"),
    SuggestionSentence([PoseLandmarkType.rightKnee, PoseLandmarkType.leftHip], PoseLandmarkType.rightHip, Side.right, sentenceFormat[3], directionPair[4], "hip"),
    // knee
    SuggestionSentence([PoseLandmarkType.leftHip, PoseLandmarkType.leftAnkle], PoseLandmarkType.leftKnee, Side.left, sentenceFormat[3], directionPair[4], "knee"),
    SuggestionSentence([PoseLandmarkType.rightHip, PoseLandmarkType.rightAnkle], PoseLandmarkType.rightKnee, Side.right, sentenceFormat[3], directionPair[4], "knee"),
  ];

  // *** LIE DOWN / FACE UP / FRONT ***
  static final List<SuggestionSentence> _lieDownFaceUpFrontList = [
    // forearm
    SuggestionSentence([PoseLandmarkType.leftWrist, PoseLandmarkType.leftShoulder], PoseLandmarkType.leftElbow, Side.left, sentenceFormat[0], directionPair[4], "forearm"),
    SuggestionSentence([PoseLandmarkType.rightWrist, PoseLandmarkType.rightShoulder], PoseLandmarkType.rightElbow, Side.right, sentenceFormat[0], directionPair[4], "forearm"),
    // arm
    SuggestionSentence([PoseLandmarkType.leftElbow, PoseLandmarkType.leftHip], PoseLandmarkType.leftShoulder, Side.left, sentenceFormat[0], directionPair[4], "arm"),
    SuggestionSentence([PoseLandmarkType.rightElbow, PoseLandmarkType.rightHip], PoseLandmarkType.rightShoulder, Side.right, sentenceFormat[0], directionPair[4], "arm"),
  ];

  // *** LIE DOWN / FACE UP / SIDE ***
  static final List<SuggestionSentence> _lieDownFaceUpSideList = [
    // forearm
    SuggestionSentence([PoseLandmarkType.leftWrist, PoseLandmarkType.leftShoulder], PoseLandmarkType.leftElbow, Side.left, sentenceFormat[2], directionPair[2], "body"),
    SuggestionSentence([PoseLandmarkType.rightWrist, PoseLandmarkType.rightShoulder], PoseLandmarkType.rightElbow, Side.right, sentenceFormat[2], directionPair[2], "body"),
    // arm
    SuggestionSentence([PoseLandmarkType.leftElbow, PoseLandmarkType.leftHip], PoseLandmarkType.leftShoulder, Side.left, sentenceFormat[2], directionPair[2], "body"),
    SuggestionSentence([PoseLandmarkType.rightElbow, PoseLandmarkType.rightHip], PoseLandmarkType.rightShoulder, Side.right, sentenceFormat[2], directionPair[2], "body"),
    // hip
    SuggestionSentence([PoseLandmarkType.leftKnee, PoseLandmarkType.rightHip], PoseLandmarkType.leftHip, Side.left, sentenceFormat[2], directionPair[2], "hip"),
    SuggestionSentence([PoseLandmarkType.rightKnee, PoseLandmarkType.leftHip], PoseLandmarkType.rightHip, Side.right, sentenceFormat[2], directionPair[2], "hip"),
    // leg
    SuggestionSentence([PoseLandmarkType.leftHip, PoseLandmarkType.leftAnkle], PoseLandmarkType.leftKnee, Side.left, sentenceFormat[3], directionPair[1], "leg"),
    SuggestionSentence([PoseLandmarkType.rightHip, PoseLandmarkType.rightAnkle], PoseLandmarkType.rightKnee, Side.right, sentenceFormat[3], directionPair[1], "leg"),
  ];

  static final _sentenceListAngle = {
    'stand': {
      'up':{
        'front': _standFrontList,
        'side': _standSideList
      }
    },
    'lieDown':{
      'front':{
        'up': _lieDownFaceUpFrontList,
        'down': _lieDownFaceDownFrontList
      },
      'side':{
        'up': _lieDownFaceUpSideList,
        'down': _lieDownFaceDownSideList
      }
    }
  };

  static String? getSentenceAngle(List<PoseLandmarkType> landmarks, PoseLandmarkType vertex, String posturePosition, String cameraAngle, Direction direction,
      {String facing = "up", String aux = ""}){
    List<SuggestionSentence> sentenceList = _sentenceListAngle[posturePosition]![facing]![cameraAngle] as List<SuggestionSentence>;
    String? resultSentence;
    for(SuggestionSentence i in sentenceList){
      if(i.compareLandmarks(landmarks, vertex)){
        resultSentence = i.generate(direction, aux: aux);
        break;
      }
    }
    return resultSentence;
  }

  static String? getSentenceTouch(List<PoseLandmarkType> landmarks){
    String result = "";

  }
}