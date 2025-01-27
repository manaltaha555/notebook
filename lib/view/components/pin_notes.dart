import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:newnotebook/controller/selectionController.dart';
import 'package:newnotebook/view/components/note_card_with_id.dart';

Widget buildPinnedNotesSection(double screenWidth, double screenHeight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SvgPicture.asset("assets/icons/pin.svg",
                color: Colors.white,
                width: screenWidth * 0.04,
                height: screenHeight * 0.04),
            SizedBox(width: screenWidth * 0.01),
            Text(
              "Pinned",
              style: GoogleFonts.roboto(
                color: Colors.white,
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildPinnedNotes(double screenWidth, double screenHeight) {
    User? user = FirebaseAuth.instance.currentUser!;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("Notes")
          .where('userId', isEqualTo: user.uid)
          .where('pinned', isEqualTo: true) // Filter by pinned notes
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        final notes = snapshot.data!.docs;

        if (notes.isEmpty) {
          return SizedBox();
        }

        return Column(
          children: [
            buildPinnedNotesSection(screenWidth, screenHeight),
            SizedBox(height: screenHeight * 0.025),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                return GetX<SelectionController>(builder: (controller) {
                  return buildNoteCard(
                      notes[index], index, context, screenWidth, screenHeight);
                });
              },
            ),
          ],
        );
      },
    );
  }
