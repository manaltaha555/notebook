import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget noteCard({
  required BuildContext context,
  required VoidCallback onTap,
  required QueryDocumentSnapshot doc,
  required Color colorCard,
  VoidCallback? onLongPress,
  bool isSelected = false,
  required double screenWidth,
  required double screenHeight,
}) {
  return GestureDetector(
    onTap: onTap,
    onLongPress: onLongPress,
    child: Container(
      height: screenHeight * 0.54,
      padding: EdgeInsets.all(screenWidth * 0.01),
      margin: EdgeInsets.all(screenWidth * 0.0085),
      decoration: BoxDecoration(
          color: colorCard,
          borderRadius: BorderRadius.all(Radius.circular(15)),
          border: Border.all(
              color: isSelected
                  ? Color(0xffFEC838)
                  : Colors.transparent, // Change the border color conditionally
              width: screenWidth * 0.008)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            doc["note_title"] == "" ? "No Title" : doc["note_title"],
            style:
                GoogleFonts.roboto(fontSize: screenWidth * 0.029, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 5),
          Text(
            doc["note_content"],
            style: GoogleFonts.nunito(fontSize: screenWidth * 0.027, fontWeight: FontWeight.normal),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          )
        ],
      ),
    ),
  );
}
