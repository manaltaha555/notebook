import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:newnotebook/view/components/app_style.dart';
import 'package:newnotebook/view/components/note_card.dart';
import 'package:newnotebook/view/components/screenSize.dart';
import 'package:newnotebook/view/pages/note_screen.dart';

class CustomSearch extends SearchDelegate {
  @override
  ThemeData appBarTheme(BuildContext context) {
   final screenSize = getScreenSize(context);
  final screenWidth = screenSize.screenWidth;
    return ThemeData(
      appBarTheme: AppBarTheme(
        backgroundColor:
            AppStyle.mainColor, // Background color of the search bar
        elevation: 0,
        iconTheme:
            IconThemeData(color: Colors.white), // Icons (back, close) color
      ),
      textTheme: TextTheme(
        titleLarge: TextStyle(
          color: Colors.white, // Color of the text typed in the search bar
          fontSize: screenWidth * 0.04,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: GoogleFonts.nunito(color: Colors.grey[400]), // Hint text style
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white), // Border when focused
        ),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    final screenSize = getScreenSize(context);
  final screenHeight = screenSize.screenHeight;
    return [
      IconButton(
        icon: Icon(Icons.close, color: Colors.white, size: screenHeight * 0.04),
        onPressed: () {
          query = ""; // Clear the search query
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    final screenSize = getScreenSize(context);
  final screenHeight = screenSize.screenHeight;
    return IconButton(
      icon: Icon(Icons.arrow_back, color: Colors.white, size: screenHeight * 0.04),
      onPressed: () {
        close(context, null); // Close the search
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
        User? user = FirebaseAuth.instance.currentUser!;
    final screenSize = getScreenSize(context);
  final screenWidth = screenSize.screenWidth;
  final screenHeight = screenSize.screenHeight;
    Stream<QuerySnapshot> stream = FirebaseFirestore.instance
        .collection("Notes")
        .where('userId', isEqualTo: user.uid)
        .where("note_title", isGreaterThanOrEqualTo: query)
        .where("note_title", isLessThanOrEqualTo: query + '\uf8ff')
        .snapshots();
    // Search Firestore using the user's query
    return Container(
      color: AppStyle.mainColor,
      child: StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "No matching notes found",
                style: GoogleFonts.roboto(color: Colors.white, fontSize: screenWidth * 0.03),
              ),
            );
          } else {
            final searchResults = snapshot.data!.docs;
            return Padding(
               padding: EdgeInsets.only(
                  top: screenHeight * 0.08,
                  left: screenWidth * 0.02,
                  right: screenWidth * 0.02),
              child: ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  return noteCard(
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                    colorCard:
                        AppStyle.cardsColor[index % AppStyle.cardsColor.length],
                    doc: searchResults[index],
                    context: context,
                    onTap: () {
                      Get.to(() => NoteScreen(doc: searchResults[index]));
                    },
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
        User? user = FirebaseAuth.instance.currentUser!;
    final screenSize = getScreenSize(context);
  final screenWidth = screenSize.screenWidth;
  final screenHeight = screenSize.screenHeight;
    Stream<QuerySnapshot> stream = FirebaseFirestore.instance
        .collection("Notes")
        .where('userId', isEqualTo: user.uid)
        .where("note_title", isGreaterThanOrEqualTo: query)
        .where("note_title", isLessThanOrEqualTo: query + '\uf8ff')
        .snapshots();
    // Provide suggestions while the user types (same logic as buildResults)
    return Container(
      height: double.infinity,
      color: AppStyle.mainColor,
      child: StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "No suggestions",
                style: GoogleFonts.roboto(color: Colors.white, fontSize: screenWidth * 0.03),
              ),
            );
          } else {
            final suggestions = snapshot.data!.docs;
            return Padding(
              padding: EdgeInsets.only(
                  top: screenHeight * 0.08,
                  left: screenWidth * 0.02,
                  right: screenWidth * 0.02),
              child: ListView.builder(
                itemCount: suggestions.length,
                itemBuilder: (context, index) {
                  return noteCard(
                    context: context,
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                    onTap: () {
                      query = suggestions[index]['note_title'];
                      showResults(
                          context); // Show results when a suggestion is tapped
                    },
                    doc: suggestions[index],
                    colorCard:
                        AppStyle.cardsColor[index % AppStyle.cardsColor.length],
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}
