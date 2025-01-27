import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:newnotebook/controller/selectionController.dart';
import 'package:newnotebook/view/components/note_card_with_id.dart';

Widget buildNotesStream(double screenWidth, double screenHeight, String currentSort, Function(String) updateSorting) {
    User? user = FirebaseAuth.instance.currentUser!;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("Notes")
          .where('userId', isEqualTo: user.uid)
          .where('pinned', isEqualTo: false)
          .orderBy(currentSort,
              descending:
                  currentSort == "creation_date" || currentSort == "edit_date")
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Error loading your data",
              style: GoogleFonts.roboto(
                color: Colors.white,
                fontSize: screenWidth * 0.028,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }
        final notes = snapshot.data!.docs;

        if (notes.isEmpty) {
          return SizedBox();
        }

        return Column(
          children: [
            buildSortMenu(screenWidth, screenHeight, currentSort,updateSorting),
            SizedBox(height: screenHeight * 0.008),
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
  PopupMenuItem<String> buildSortMenuItem(
      String value, String text, double screenWidth) {
    return PopupMenuItem(
      value: value,
      child: Text(
        text,
        style: GoogleFonts.roboto(fontSize: screenWidth * 0.025),
      ),
    );
  }

  Widget buildSortMenu(double screenWidth, double screenHeight, String currentSort, Function(String) updateSorting) {
    String sort;
    switch (currentSort) {
      case "edit_date":
        {
          sort = "last edit date";
          break;
        }
      case "creation_date":
        {
          sort = "creation date";
          break;
        }
      case "note_title":
        {
          sort = "title";
          break;
        }
      case "note_content":
        {
          sort = "content";
          break;
        }
      default:
        {
          sort = "creation date";
          break;
        }
    }
    return Row(
      children: [
        PopupMenuButton<String>(
          onSelected: updateSorting,
          icon: SvgPicture.asset(
            "assets/icons/sort2.svg",
            width: screenWidth * 0.04,
            height: screenHeight * 0.04,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          itemBuilder: (context) => [
            buildSortMenuItem("edit_date", "Sort by Edit Date", screenWidth),
            buildSortMenuItem(
                "creation_date", "Sort by Create Date", screenWidth),
            buildSortMenuItem("note_title", "Sort by Title", screenWidth),
            buildSortMenuItem("note_content", "Sort by Content", screenWidth),
          ],
        ),
        SizedBox(width: screenWidth * 0.01),
        Text(
          "Sort By ${sort}",
          style: GoogleFonts.roboto(
            color: const Color.fromRGBO(255, 255, 255, 1),
            fontSize: screenWidth * 0.04,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

