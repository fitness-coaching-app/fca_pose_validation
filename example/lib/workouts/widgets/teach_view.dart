import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class TeachView extends StatefulWidget {
  final Function? onComplete;

  TeachView({
    this.onComplete
  });

  State<StatefulWidget> createState() => _TeachViewState();
}

class _TeachViewState extends State<TeachView> {

  @override
  void initState(){
    super.initState();

    // TODO: Remove this timer, mockup only
    Timer.periodic(const Duration(milliseconds: 2000), (timer) {
      timer.cancel();
      if(widget.onComplete != null) widget.onComplete!();
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Display Teaching Video
    // TODO: Call widget.onComplete!() when done teaching video
    return Expanded(
        child: Text("Teaching Video...")
    );
  }
}