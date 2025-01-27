import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppStyle {
  static Color bgColor = Color(0XFFE2E2FF);
  static Color mainColor = Color(0XFF000633);
  static Color accentColor = Color(0XFF0065FF);

  static List<Color> cardsColor = [
    Colors.white,
    Colors.red.shade100,
    Colors.pink.shade100,
    Colors.orange.shade100,
    Colors.yellow.shade100,
    Colors.green.shade100,
    Colors.blue.shade100,
    Colors.blueGrey.shade100
  ];

static TextStyle mainTitle = GoogleFonts.roboto(fontSize: 19, fontWeight: FontWeight.w600);
static TextStyle mainContent = GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.normal);
static TextStyle dateTitle = GoogleFonts.roboto(fontSize: 13, fontWeight: FontWeight.w600);



}
