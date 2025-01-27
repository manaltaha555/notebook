import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:newnotebook/controller/pin_note.dart';
import 'package:newnotebook/controller/selectionController.dart';
import 'package:newnotebook/view/components/app_style.dart';
import 'package:newnotebook/view/components/note_stream.dart';
import 'package:newnotebook/view/components/pin_notes.dart';
import 'package:newnotebook/view/components/screenSize.dart';
import 'package:newnotebook/view/pages/note_screen.dart';
import 'package:newnotebook/view/pages/search.dart';
import 'package:share_plus/share_plus.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late String currentSort;
  late Stream<QuerySnapshot> stream;
  final SelectionController controller = Get.put(SelectionController());

  @override
  void initState() {
    super.initState();
    currentSort = "creation_date";
    updateStream();
  }

  Future<void> onRefresh() async {
    // Re-fetch the stream when the user pulls to refresh
    updateStream();
    await Future.delayed(
        Duration(seconds: 1)); // Optionally delay for better UX
  }

  void updateStream() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      stream = FirebaseFirestore.instance
          .collection("Notes")
          .where("userId", isEqualTo: user.uid)
          .where('pinned', isNotEqualTo: true)
          .orderBy(currentSort,
              descending:
                  currentSort == "creation_date" || currentSort == "edit_date")
          .snapshots();
    } else {
      Text("Try adding to log in");
    }
  }

  void updateSorting(String sorting) {
    if (currentSort != sorting) {
      setState(() {
        currentSort = sorting;
        updateStream();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = getScreenSize(context);
  final screenWidth = screenSize.screenWidth;
  final screenHeight = screenSize.screenHeight;
    return Scaffold(
      backgroundColor: AppStyle.mainColor,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        shape: CircleBorder(),
        onPressed: () {
          Get.to(() => NoteScreen(doc: null));
        },
        child: Icon(Icons.add,
            size: screenHeight * 0.05, color: AppStyle.mainColor),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
              top: screenHeight * 0.06,
              left: screenWidth * 0.06,
              right: screenWidth * 0.06),
          child: RefreshIndicator(
            onRefresh: () async {
              await onRefresh();
            },
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: buildSearchOrSelectionBar(screenWidth, screenHeight),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(height: screenHeight * 0.008),
                ),
                SliverToBoxAdapter(
                  child: buildPinnedNotes(screenWidth, screenHeight),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(height: screenHeight * 0.008),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return buildNotesStream(
                          screenWidth, screenHeight, currentSort, updateSorting); // Regular notes section
                    },
                    childCount: 1, // Only one stream for regular notes
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

 Widget buildSearchOrSelectionBar(double screenWidth, double screenHeight) {

  return GetX<SelectionController>(builder: (controller) {
    // This will rebuild when `controller.isSelectionMode` changes.
    return controller.isSelectionMode == false || controller.selectedNotes.isEmpty
        ? GestureDetector(
            onTap: () {
              showSearch(context: context, delegate: CustomSearch());
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.015,
                  vertical: screenHeight * 0.02),
              child: Row(
                children: [
                  Icon(Icons.search, color: AppStyle.mainColor),
                  SizedBox(width: screenWidth * 0.01),
                  Text(
                    "Search",
                    style: GoogleFonts.roboto(
                        fontSize: screenWidth * 0.04,
                        color: AppStyle.mainColor),
                  ),
                ],
              ),
            ),
          )
        : buildSelectionBar(screenWidth, screenHeight);
  });
}

Widget buildSelectionBar(double screenWidth, double screenHeight) {
  return GetX<SelectionController>(builder: (controller) {
    // Ensure the whole selection bar is rebuilt when selection state changes
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: controller.exitSelectionMode,
          icon: Icon(
            Icons.close,
            color: Colors.white,
            size: screenHeight * 0.04,
          ),
        ),
        Row(
          children: [
            controller.selectedNotes.length == 1
                ? IconButton(
                    onPressed: () => shareNote(),
                    icon: Icon(
                      Icons.share,
                      color: Colors.white,
                      size: screenHeight * 0.04,
                    ),
                  )
                : Text(
                    "${controller.selectedNotes.length}",
                    style: GoogleFonts.roboto(
                        fontSize: screenWidth * 0.028, color: Colors.white),
                  ),
            SizedBox(width: screenWidth * 0.03),
            buildPinButton(screenWidth, screenHeight),
            SizedBox(width: screenWidth * 0.03),
            buildDeleteButton(screenWidth, screenHeight),
          ],
        ),
      ],
    );
  });
}

  Widget buildPinButton(double screenWidth, double screenHeight) {
    return IconButton(
      onPressed: () {
        for (var id in controller.selectedNotes) {
          togglePin(id);
        }
        controller.exitSelectionMode();
      },
      icon: SvgPicture.asset("assets/icons/pin.svg",
          color: Colors.white,
          width: screenWidth * 0.04,
          height: screenHeight * 0.04),
    );
  }

  Widget buildDeleteButton(double screenWidth, double screenHeight) {
    return IconButton(
      onPressed: () {
        AwesomeDialog(
          context: context,
          closeIcon: const Icon(Icons.close),
          padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.02, vertical: screenHeight * 0.025),
          dialogType: DialogType.noHeader,
          dismissOnBackKeyPress: true,
          animType: AnimType.rightSlide,
          title: controller.selectedNotes.length == 1
              ? "Delete Note"
              : "Delete Notes",
          titleTextStyle: GoogleFonts.nunito(
            color: Color(0xff212E54),
            fontWeight: FontWeight.w700,
            fontSize: screenWidth * 0.04,
          ),
          desc: controller.selectedNotes.length == 1
              ? "Are You Sure You Want To Delete This Note?"
              : "Are You Sure You Want to Delete These Notes?",
          descTextStyle: GoogleFonts.nunito(
            color: Color(0xff9B9B9B),
            fontWeight: FontWeight.w700,
            fontSize: screenWidth * 0.038,
          ),
          btnOkOnPress: () async {
            for (var id in controller.selectedNotes) {
              await FirebaseFirestore.instance
                  .collection("Notes")
                  .doc(id)
                  .delete();
            }
            controller.exitSelectionMode();
          },
          buttonsTextStyle: GoogleFonts.nunito(
              fontSize: screenWidth * 0.032,
              color: Colors.white,
              fontWeight: FontWeight.bold),
          btnOkText: "Delete",
          btnOkColor: const Color(0xFF212E54),
          btnCancelOnPress: () {
            Get.back();
          },
          btnCancelText: "Cancel",
          btnCancelColor: const Color(0xff9B9B9B),
        ).show();
      },
      icon: Icon(
        Icons.delete_outline,
        color: Colors.white,
        size: screenHeight * 0.04,
      ),
    );
  }
  
  void shareNote() async {
    if (controller.selectedNotes.isNotEmpty) {
      for (var id in controller.selectedNotes) {
        var note =
            await FirebaseFirestore.instance.collection('Notes').doc(id).get();
        final noteTitle = note['note_title'];
        final noteContent = note['note_content'];
        await Share.share("Title: $noteTitle \nContent: $noteContent");
      }
      controller.exitSelectionMode();
    }
  }
}
