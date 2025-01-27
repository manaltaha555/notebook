import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

Future<void> deleteNote(QueryDocumentSnapshot doc) async {
  // Reference to Firestore collection
  final notesCollection = FirebaseFirestore.instance.collection("Notes");

    await notesCollection.doc(doc.id).delete();

  // Navigate back after deleting
  Get.back();
}
