import 'package:fca_pose_validation/fca_pose_processor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../color.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math';
import 'package:ionicons/ionicons.dart';
import 'package:recase/recase.dart';

class CurrentExerciseStateBar extends StatefulWidget {
  ExerciseState currentState;
  bool isComplete;

  CurrentExerciseStateBar(
      {Key? key, required this.currentState, required this.isComplete})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _CurrentExerciseStateBarState();
}

class _CurrentExerciseStateBarState extends State<CurrentExerciseStateBar> {
  Widget _introStateBar() {
    return Container(
      decoration: new BoxDecoration(color: color_dark),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          LinearProgressIndicator(
            minHeight: 3,
            value: 0.6,
            valueColor: AlwaysStoppedAnimation(color_dimmedTeal),
            backgroundColor: color_dark,
            semanticsLabel: 'Linear progress indicator',
          ),
          SizedBox(
            height: 25,
          ),
          Container(
            height: 80,
            child: Row(children: [
              SizedBox(
                width: 25,
              ),
              Container(
                  width: 62,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      color: Colors.white),
                  child: Padding(
                      padding: EdgeInsets.only(top: 5),
                      child: Text(
                          (widget.currentState.currentStep + 1).toString(),
                          style: const TextStyle(
                              color: color_dark,
                              fontWeight: FontWeight.w600,
                              fontFamily: "Poppins",
                              fontStyle: FontStyle.normal,
                              fontSize: 36.0),
                          textAlign: TextAlign.center))),
              SizedBox(
                width: 25,
              ),
              Flexible(
                child: Center(
                  child: Text(widget.currentState.stepName,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontFamily: "Poppins",
                          fontStyle: FontStyle.normal,
                          fontSize: 20.0),
                      textAlign: TextAlign.center),
                ),
              ),
              SizedBox(
                width: 25,
              )
            ]),
          ),
          SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }

  Widget _exercisingStateDetail(Color textColor, Color backgroundColor) {
    return Container(
      decoration: new BoxDecoration(color: backgroundColor),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(height: 25 + 3 // Padding + Indicator
              ),
          Container(
            height: 80, // Normal Height + Padding + Indicator
            child: Row(children: [
              SizedBox(
                width: 25,
              ),
              Expanded(
                child: Text(widget.currentState.stepName,
                    style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                        fontFamily: "Poppins",
                        fontStyle: FontStyle.normal,
                        fontSize: 20.0)),
              ),
              SizedBox(
                width: 10,
              ),
              Container(
                width: 120,
                child: Row(
                  children: [
                    Spacer(),
                    (() {
                      if (widget.currentState.criteria ==
                          ExerciseDisplayCriteria.timer) {
                        int min = Duration(
                                milliseconds: widget
                                    .currentState.timer.elapsedMilliseconds)
                            .inMinutes;
                        int sec = Duration(
                                milliseconds: widget
                                    .currentState.timer.elapsedMilliseconds)
                            .inSeconds
                            .remainder(60);

                        return _timerWidget(min, sec, textColor);
                      } else {
                        return _countingWidget(widget.currentState.repeatCount,
                            widget.currentState.target, textColor);
                      }
                    }())
                  ],
                ),
              ),
              SizedBox(
                width: 25,
              )
            ]),
          ),
          SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }

  Widget _countingWidget(int currentCount, int target, Color textColor) {
    return Text("$currentCount",
        style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontFamily: "Poppins",
            fontStyle: FontStyle.normal,
            fontSize: 36.0),
        textAlign: TextAlign.center);
  }

  Widget _timerWidget(int min, int sec, Color textColor) {
    return Text(
        "${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}",
        style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontFamily: "Poppins",
            fontStyle: FontStyle.normal,
            fontSize: 36.0),
        textAlign: TextAlign.center);
  }

  Widget _exercisingStateBar(double widthFactor) {
    return Stack(
      children: [
        _exercisingStateDetail(Colors.white, color_dark),
        ClipRect(
            child: Align(
                alignment: Alignment.topLeft,
                widthFactor: widthFactor,
                child: _exercisingStateDetail(color_dark, color_dimmedTeal)))
      ],
    );
  }

  Widget _completeStateBar() {
    return Container(
      decoration: new BoxDecoration(color: color_dimmedTeal),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(height: 25 + 3 // Padding + Indicator
              ),
          Container(
            height: 80, // Normal Height + Padding + Indicator
            child: Row(
              children: [
                Expanded(
                    child: Icon(
                  Ionicons.checkmark_circle,
                  size: 70,
                  color: color_dark,
                )),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }

  Widget _warningStateBar() {
    return Container(
      decoration: new BoxDecoration(color: color_purple),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            height: 25 + 3,
          ),
          Container(
            height: 80,
            child: Row(children: [
              SizedBox(
                width: 25,
              ),
              SizedBox(
                width: 25,
              ),
              Flexible(
                child: Center(
                  child: Text(widget.currentState.getWarning()["warningMessage"].toString().titleCase,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontFamily: "Poppins",
                          fontStyle: FontStyle.normal,
                          fontSize: 20.0),
                      textAlign: TextAlign.center),
                ),
              ),
              SizedBox(
                width: 25,
              )
            ]),
          ),
          Center(
              child: SvgPicture.asset(
            'assets/Icon/Detail Expand Icon.svg', // dot dot dot
          )),
          SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isComplete) {
      return _completeStateBar();
    }
    if(widget.currentState.isWarning()){
      return _warningStateBar();
    }
    if (widget.currentState.getDisplayState() == DisplayState.exercise) {
      double widthFactor =
          widget.currentState.repeatCount / widget.currentState.target;
      if (widget.currentState.criteria == ExerciseDisplayCriteria.timer) {
        widthFactor = widget.currentState.timer.elapsedMilliseconds /
            widget.currentState.targetTimeMilliseconds;
      }
      return _exercisingStateBar(widthFactor);
    }
    return _introStateBar();
  }
}
