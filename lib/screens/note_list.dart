import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_app_note_keeper/models/note.dart';
import 'package:flutter_app_note_keeper/utils/database_helper.dart';
import 'package:flutter_app_note_keeper/screens/note_detail.dart';
import 'package:sqflite/sqflite.dart';

class NoteList extends StatefulWidget {
  const NoteList({Key? key}) : super(key: key);

  @override
  State<NoteList> createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {

  DatabaseHelper databaseHelper = DatabaseHelper(); //створюємо екземпляр DatabaseHelper
  late List<Note> noteList; // список всіх вузлів для представлення в апп
  int count = 0;

  @override
  Widget build(BuildContext context) {

    noteList = <Note>[];
    updateListView();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Note'),
      ),

      body: getNoteListView(),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          debugPrint('FAB clicked');
          navigateToDetail(Note('', '', 2, ''), 'Add Note');
        },

        tooltip: 'Add Note',

        child: const Icon(Icons.add),
      ),
    );
  }

  ListView getNoteListView() {

    TextStyle? titleStyle = Theme.of(context).textTheme.titleMedium;

    return ListView.builder(
        itemCount: count,
        itemBuilder: (BuildContext context, int position) {
          return Card(
            color: Colors.white,
            elevation: 2.0,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: getPriorityColor(noteList[position].priority),
                child: getPriorityIcon(noteList[position].priority),
              ),
              title: Text(noteList[position].title, style: titleStyle,),

              subtitle: Text(noteList[position].date),

              trailing: GestureDetector(
                  child: const Icon(Icons.delete, color: Colors.grey,),
                onTap: () {
                    _delete(context, noteList[position]);
                },
              ),

              onTap: () {
                debugPrint('ListTile Tapped');
                navigateToDetail(noteList[position], 'Edit Note');
              },
            ),
          );
        },

    );
  }

  // Returns the priority color
  Color getPriorityColor (int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.yellow;
        default:
          return Colors.yellow;
    }
  }

  // Returns the priority icon
  Icon getPriorityIcon (int priority) {
    switch (priority) {
      case 1:
        return const Icon(Icons.play_arrow);
      case 2:
        return const Icon(Icons.keyboard_arrow_right);
      default:
        return const Icon(Icons.keyboard_arrow_right);
    }
  }

  // delete note
  void _delete(BuildContext context, Note note) async {

    // final scaffold = Scaffold.of(context);

    int result = await databaseHelper.deleteNote(note.id);

    if (result !=0) {
      _showSnackBar(Scaffold as BuildContext, 'Note Deleted Successfully');
    // update the list view
      updateListView();
    }
  }

  //
  void _showSnackBar(BuildContext context, String message) {

    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void navigateToDetail(Note note, String title) async {
    bool result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return NoteDetail(appBarTitle: title, note: note);
    }));

    if (result == true) {
      updateListView();
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {

      Future<List<Note>> noteListFuture = databaseHelper.getNoteList();
      noteListFuture.then((noteList) {
        setState(() {
          this.noteList = noteList;
          count = noteList.length;
        });
      });
    });
  }

}
