import 'package:get/get.dart';

class SelectionController  extends GetxController{
var selectedNotes = <String>[].obs;
var isSelectionMode = false.obs;

void toggleSelection(String noteId) {
  if (selectedNotes.contains(noteId)) {
    selectedNotes.remove(noteId);
  } else {
    selectedNotes.add(noteId);
  }
}

void exitSelectionMode() {
  isSelectionMode.value = false;
  selectedNotes.clear();
}
void enterSelectionMode() {
    isSelectionMode.value = true;
  }
}
