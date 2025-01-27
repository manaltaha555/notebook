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
import 'package:newnotebook/view/components/note_card.dart';
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
    var orientation = MediaQuery.of(context).orientation;
    var screenWidth;
    var screenHeight;
    if (orientation == Orientation.portrait) {
      screenWidth = MediaQuery.of(context).size.height;
      screenHeight = MediaQuery.of(context).size.width;
    } else {
      screenWidth = MediaQuery.of(context).size.width;
      screenHeight = MediaQuery.of(context).size.height;
    }
    return Scaffold(
      backgroundColor: AppStyle.mainColor,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        shape: CircleBorder(),
        onPressed: () {
          Get.to(() => NoteScreen(doc: null));
        },
        child: Icon(Icons.add,
            size: screenHeight * 0.08, color: AppStyle.mainColor),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
              top: screenHeight * 0.08,
              left: screenWidth * 0.02,
              right: screenWidth * 0.02),
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
                  child: SizedBox(height: screenHeight * 0.03),
                ),
                SliverToBoxAdapter(
                  child: buildPinnedNotes(screenWidth, screenHeight),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(height: screenHeight * 0.03),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return buildNotesStream(
                          screenWidth, screenHeight); // Regular notes section
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
                  horizontal: screenWidth * 0.025,
                  vertical: screenHeight * 0.03),
              child: Row(
                children: [
                  Icon(Icons.search, color: AppStyle.mainColor),
                  SizedBox(width: screenWidth * 0.01),
                  Text(
                    "Search",
                    style: GoogleFonts.roboto(
                        fontSize: screenWidth * 0.025,
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
            size: screenHeight * 0.08,
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
                      size: screenHeight * 0.08,
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
          width: screenWidth * 0.08,
          height: screenHeight * 0.08),
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
            fontSize: screenWidth * 0.03,
          ),
          desc: controller.selectedNotes.length == 1
              ? "Are You Sure You Want To Delete This Note?"
              : "Are You Sure You Want to Delete These Notes?",
          descTextStyle: GoogleFonts.nunito(
            color: Color(0xff9B9B9B),
            fontWeight: FontWeight.w700,
            fontSize: screenWidth * 0.029,
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
              fontSize: screenWidth * 0.027,
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
        size: screenHeight * 0.08,
      ),
    );
  }

  Widget buildSortMenu(double screenWidth, double screenHeight) {
    String sort;
    switch (currentSort) {
      case "edit_date":
        {
          sort = "last edit date";
        }
      case "creation_date":
        {
          sort = "creation date";
        }
      case "note_title":
        {
          sort = "title";
        }
      case "note_content":
        {
          sort = "content";
        }
      default:
        {
          sort = "creation date";
        }
    }
    return Row(
      children: [
        PopupMenuButton<String>(
          onSelected: updateSorting,
          icon: SvgPicture.asset(
            "assets/icons/sort2.svg",
            width: screenWidth * 0.08,
            height: screenHeight * 0.08,
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
            fontSize: screenWidth * 0.025,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  PopupMenuItem<String> buildSortMenuItem(
      String value, String text, double screenWidth) {
    return PopupMenuItem(
      value: value,
      child: Text(
        text,
        style: GoogleFonts.roboto(fontSize: screenWidth * 0.022),
      ),
    );
  }

  Widget buildPinnedNotesSection(double screenWidth, double screenHeight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SvgPicture.asset("assets/icons/pin.svg",
                color: Colors.white,
                width: screenWidth * 0.08,
                height: screenHeight * 0.08),
            SizedBox(width: screenWidth * 0.01),
            Text(
              "Pinned",
              style: GoogleFonts.roboto(
                color: Colors.white,
                fontSize: screenWidth * 0.025,
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
                      notes[index], index, screenWidth, screenHeight);
                });
              },
            ),
          ],
        );
      },
    );
  }

  Widget buildNotesStream(double screenWidth, double screenHeight) {
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
            buildSortMenu(screenWidth, screenHeight),
            SizedBox(height: screenHeight * 0.025),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                return GetX<SelectionController>(builder: (controller) {
                  return buildNoteCard(
                      notes[index], index, screenWidth, screenHeight);
                });
              },
            ),
          ],
        );
      },
    );
  }

  Widget buildNoteCard(QueryDocumentSnapshot note, int index,
      double screenWidth, double screenHeight) {
    final id = note.id;

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
