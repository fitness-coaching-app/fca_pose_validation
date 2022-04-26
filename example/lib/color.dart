import 'package:flutter/material.dart';
const Color color_dark = Color(0xFF0C2B42);
const Color color_darkBlue = Color(0xff4062bb);
const Color color_teal = Color(0xFF07EBB9);
const Color color_dimmedTeal = Color(0xff00c69a);
const Color color_red = Color(0xfff8485e);
const Color color_purple = Color(0xff6a3792);
const Color color_alertPurple = Color(0xff6a3792);
const Color color_lightPurple = Color(0xfff093ff);
const Color color_white = Color(0xfff8f8f8);
const Color color_lightGrey = Color(0xffefefef);
const Color color_subtitle = Color(0xff517086);
const Color color_placeholder = Color(0xff517086);

final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
  primary: color_teal, //change background color of button
  onPrimary: color_dark, //change text color of button
  fixedSize: Size(325, 66),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(50),
  ),
  elevation: 5.0,
);