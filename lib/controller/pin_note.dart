import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> togglePin(String noteId) async {
  try {
    // Get the document from Firestore
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('Notes')
        .doc(noteId)
        .get();

    // Check if the document exists
    if (documentSnapshot.exists) {
      // Get the current 'pinned' status (default to false if it doesn't exist)
      bool currentPinStatus = documentSnapshot.get('pinned') ?? false;

      // Toggle the 'pinned' status
      await FirebaseFirestore.instance.collection('Notes').doc(noteId).update({
        'pinned': !currentPinStatus // Update with the toggled status
      });

      print("Pin status toggled successfully");
    } else {
      print("Document does not exist");
    }
  } catch (e) {
    print("Error toggling pin status: $e");
  }
}
