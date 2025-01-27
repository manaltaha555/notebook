import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

Future<void> saveNote(TextEditingController titleController, TextEditingController contentController, QueryDocumentSnapshot? doc) async {
  // Reference to Firestore collection
  final notesCollection = FirebaseFirestore.instance.collection("Notes");
  User? user = FirebaseAuth.instance.currentUser!;
if (doc == null ) {
  // Create a new document with a generated ID using set()
  DocumentReference newDoc = notesCollection.doc();  // Generate a new document reference
  await newDoc.set({
    "note_title": titleController.text,
    "note_content": contentController.text ,
    "creation_date": DateFormat('dd/MM/yyyy h:mm').format(DateTime.now()),
    "edit_date": DateFormat('dd/MM/yyyy h:mm').format(DateTime.now()),
    'userId': user.uid,
    "pinned": false
  });
} else {
  // Update existing document using set() with merge: true
  await notesCollection.doc(doc.id).set({
    "note_title":  titleController.text,
    "note_content":  (contentController.text == "") ? "No Content" :contentController.text ,
    "edit_date": DateFormat('dd/MM/yyyy h:mm').format(DateTime.now()),  // Preserve original creation date
  }, SetOptions(merge: true));
}  // Navigate back after saving
  Get.back();
}
