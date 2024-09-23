import 'package:application_notes/services/firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Validator formkey
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();

  // Variable to get methods of firestoreservice file
  final FirestoreService firestoreService = FirestoreService();

  // Text Controller
  final TextEditingController textController = TextEditingController();

  // Open dialog box
  void openNoteBox({String? docId, String? existingNote}) {
    if (existingNote != null) {
      textController.text = existingNote;  // Fill text controller with existing note for edit
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Form(
          key: formkey,
          child: TextFormField(
            controller: textController,
            decoration: const InputDecoration(
              hintText: 'Enter your note',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please Enter A Note';  // Error if input is empty
              }
              return null;
            },
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (formkey.currentState!.validate()) {
                String newNoteText = textController.text;

                // If docId is null, we're adding a new note
                if (docId == null) {
                  firestoreService.addNote(newNoteText);
                } 
                // Update existing note only if the note has been changed
                else {
                  if (newNoteText != existingNote) {
                    firestoreService.updateNote(docId, newNoteText);
                  }
                }

                // Clear the text controller
                textController.clear();
                // Close the dialog box
                Navigator.pop(context);
              }
            },
            child: docId == null ? const Text('Add Note') : const Text('Update Note'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Notes App",
          style: TextStyle(color: Colors.white, fontSize: 30),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: openNoteBox,
        child: const Icon(
          Icons.add,
          color: Color.fromARGB(255, 255, 255, 255),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getNotesStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List noteList = snapshot.data!.docs;
            return ListView.builder(
              itemCount: noteList.length,
              itemBuilder: (context, index) {
                // Get each individual note
                DocumentSnapshot document = noteList[index];
                String docId = document.id;

                // Get note from each doc
                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;
                String noteText = data['note'];

                // Styling the ListTile with a container
                return Container(
                 
                  margin:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 170, 169, 159), // Light yellow background color
                    borderRadius: BorderRadius.circular(12), // Rounded corners
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3), // Shadow position
                      ),
                    ],
                  ),
                  child: ListTile(
                    title: Text(
                      noteText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        
                        IconButton(
                          padding: const EdgeInsets.only(left:16),
                          onPressed: () => openNoteBox(
                              docId: docId, existingNote: noteText),
                          icon: const Icon(Icons.edit),
                        ),
                        IconButton(
                           padding: const EdgeInsets.only(left:16),
                          onPressed: () => firestoreService.deleteNote(docId),
                          icon: const Icon(Icons.delete),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return const Text("No Notes Available");
          }
        },
      ),
    );
  }
}
