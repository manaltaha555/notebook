import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:newnotebook/controller/selectionController.dart';
import 'package:newnotebook/view/components/app_style.dart';
import 'package:newnotebook/view/components/note_card.dart';
import 'package:newnotebook/view/pages/note_screen.dart';

Widget buildNoteCard(QueryDocumentSnapshot note, int index,BuildContext context,
      double screenWidth, double screenHeight) {
    final id = note.id;
    final SelectionController controller = Get.put(SelectionController());


    return noteCard(
        screenWidth: screenWidth,
        screenHeight: screenHeight,
        isSelected: controller.selectedNotes.contains(id),
        colorCard: AppStyle.cardsColor[index % AppStyle.cardsColor.length],
        doc: note,
        context: context,
        onLongPress: () {
          controller.enterSelectionMode();
          controller.toggleSelection(id);
        },
        onTap: () {
          if (controller.isSelectionMode == true &&
              controller.selectedNotes.isNotEmpty) {
            // Toggle selection if in selection mode and there are selected notes
            controller.toggleSelection(id);
          } else if (controller.selectedNotes.isEmpty) {
            // Exit selection mode if no selected notes
            controller.exitSelectionMode();
            // Proceed to the note screen if no selection mode is active
            Get.to(() => NoteScreen(doc: note));
          } else {
            // Enter selection mode when tapping on a note while not in selection mode
            controller.enterSelectionMode();
            controller.toggleSelection(id);
          }
        });
  }
