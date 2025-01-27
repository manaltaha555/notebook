import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:newnotebook/controller/delete_note.dart';
import 'package:newnotebook/controller/save_note.dart';
import 'package:newnotebook/view/components/app_style.dart';
import 'package:newnotebook/view/pages/home.dart';

class NoteScreen extends StatefulWidget {
  QueryDocumentSnapshot? doc;
  NoteScreen({this.doc, super.key});

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  late TextEditingController titleController;
  late TextEditingController contentController;
  
  bool isDarkMode = false;

  Future<bool> onPop(double screenWidth, double screenHeight) async {
    // Using a Future to capture the result of the dialog
    bool shouldPop = false;
    if (contentController.text == "") {
      shouldPop = true;
    } else {
      await AwesomeDialog(
        context: context,
        closeIcon: Icon(Icons.close),
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
        dialogType: DialogType.noHeader,
        dismissOnBackKeyPress: true,
        animType: AnimType.rightSlide,
        title: "Unsaved Changes",
        titleTextStyle: GoogleFonts.nunito(
          color: Color(0xff212E54),
          fontWeight: FontWeight.w700,
          fontSize: screenWidth * 0.03,
        ),
        desc: "Are You Sure You Want To Leave without Save?",
        descTextStyle: GoogleFonts.nunito(
          color: Color(0xff9B9B9B),
          fontWeight: FontWeight.w700,
          fontSize: screenWidth * 0.029,
        ),
        btnOkOnPress: () async {
          // Save the note and allow popping the screen
          await saveNote(titleController, contentController, widget.doc);
          shouldPop = true; // This will allow the user to leave the page
        },
        buttonsTextStyle: GoogleFonts.nunito(fontSize: screenWidth * 0.027,color: Colors.white, fontWeight: FontWeight.bold),
        btnOkText: "Save",
        btnOkColor: Color(0xFF212E54),
        btnCancelOnPress: () {
          shouldPop = true; // Allow the user to leave the page without saving
          Get.offAll(() => Home());
        },
        btnCancelText: "Cancel",
        btnCancelColor: Color(0xff9B9B9B),
      ).show();
    }

    return shouldPop;
  }

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(
      text: widget.doc != null ? widget.doc!["note_title"] : "",
    );
    contentController = TextEditingController(
      text: widget.doc != null ? widget.doc!["note_content"] : "",
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var orientation = MediaQuery.of(context).orientation;
                var screenWidth;
                var screenHeight;
                if(orientation == Orientation.portrait){
                   screenWidth = MediaQuery.of(context).size.height;
                  screenHeight = MediaQuery.of(context).size.width;
                }else{
                  screenWidth = MediaQuery.of(context).size.width;
                  screenHeight = MediaQuery.of(context).size.height;
                }
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) {
          return;
        }
        final bool shouldPop = await onPop(screenWidth, screenHeight);
        if (context.mounted && shouldPop) {
          Get.back();
        }
      },
      child: Scaffold(
        backgroundColor: isDarkMode ? AppStyle.mainColor : Colors.white,
        appBar: AppBar(
          backgroundColor: isDarkMode ? AppStyle.mainColor : Colors.white,
          elevation: 0.0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_sharp,
              size: screenHeight * 0.08,
              color: isDarkMode ? Colors.white : AppStyle.mainColor,
              
            ),
            onPressed: () async {
              if (await onPop(screenWidth, screenHeight)) {
                Get.back();
              }
            },
          ),
          actions: [
                
                IconButton(
                  icon: SvgPicture.asset("assets/icons/night.svg",
                      colorFilter: ColorFilter.mode(
                          isDarkMode
                              ? Color(0xffFEC838)
                              : AppStyle.mainColor,
                          BlendMode.srcIn),
                      width: screenWidth * 0.08,
                      height: screenHeight * 0.08),
                  onPressed: () {
                    setState(() {
                      isDarkMode = !isDarkMode;
                    });
                  },
                ),
                IconButton(
                    onPressed: () {
                      AwesomeDialog(
                        context: context,
                        closeIcon: Icon(Icons.close),
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.02, vertical: screenHeight * 0.025),
                        dialogType: DialogType.noHeader,
                        dismissOnBackKeyPress: true,
                        animType: AnimType.rightSlide,
                        title: "Delete Note",
                        titleTextStyle: GoogleFonts.nunito(
                          color: Color(0xff212E54),
                          fontWeight: FontWeight.w700,
                          fontSize: screenWidth * 0.03,
                        ),
                        desc: "Are You Sure You Want To Delete This Note?",
                        descTextStyle: GoogleFonts.nunito(
                          color: Color(0xff9B9B9B),
                          fontWeight: FontWeight.w700,
                          fontSize: screenWidth * 0.029,
                        ),
                        btnOkOnPress: () async {
                          deleteNote(widget.doc!);
                          Get.back();
                        },
                        btnOkText: "Delete",
                        buttonsTextStyle: GoogleFonts.nunito(fontSize: screenWidth * 0.027,color: Colors.white, fontWeight: FontWeight.bold),
                        btnOkColor: Color(0xFF212E54),
                        btnCancelOnPress: () {
                          Get.back();
                        },
                        btnCancelText: "Cancel",
                        btnCancelColor: Color(0xff9B9B9B),
                      ).show();
                    },
                    icon: Icon(Icons.delete_outline,
                        size: screenHeight * 0.08,
                        color:
                            isDarkMode ? Colors.white : AppStyle.mainColor))
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
            child: ListView(
              children: [
                TextField(
                  maxLines: 1,
                  controller: titleController,
                  decoration: InputDecoration(
                    hintText: "Title",
                    hintStyle: GoogleFonts.roboto(
                      fontSize: screenHeight * 0.07,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : Color(0xffbdbdbd),
                    ),
                    border: InputBorder.none,
                  ),
                  style: GoogleFonts.nunito(
                    fontSize: screenHeight * 0.07,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode
                        ? Colors.white
                        : (titleController.text == "No Title")
                            ? Color(0xffbdbdbd)
                            : AppStyle.mainColor,
                  ),
                ),
                SizedBox(height: screenHeight * 0.001),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    widget.doc != null
                        ? Text(
                            "Last Edit: ${widget.doc!["edit_date"]}",
                            style: GoogleFonts.nunito(
                              fontSize: screenHeight * 0.04,
                              fontWeight: FontWeight.normal,
                              color:
                                  isDarkMode ? Colors.white : Color(0xff9B9B9B),
                            ),
                            overflow: TextOverflow.ellipsis,
                          )
                        : SizedBox()
                  ],
                ),
                SizedBox(height: screenHeight * 0.002),
                // Use a fixed height to avoid infinite size issues
                TextFormField(
                  controller: contentController,
                  maxLines: null, // Allows for multi-line input
                  decoration: InputDecoration(
                    hintText: "What's in Your Thought",
                    hintStyle: GoogleFonts.nunito(
                        fontSize: screenWidth * 0.035,
                        fontWeight: FontWeight.normal,
                        color: isDarkMode ? Colors.white : Color(0xff9B9B9B)),
                    border: InputBorder.none,
                  ),
                  style: GoogleFonts.nunito(
                    fontSize: screenWidth * 0.035,
                    fontWeight: FontWeight.w400,
                    color: isDarkMode ? Colors.white : AppStyle.mainColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
