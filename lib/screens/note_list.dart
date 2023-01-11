// сторінка зі списком всих записів (головна сторінка апп)

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

  // створюємо допоміжний екземпляр хелпера бази даних
  DatabaseHelper databaseHelper = DatabaseHelper(); //створюємо екземпляр DatabaseHelper

  // список всіх вузлів для представлення в апп
  // на початку роботи список пустий
  List<Note> noteList = [];
  // допоміжна змінна
  int count = 0;

  @override
  Widget build(BuildContext context) {

    // створюємо екземпляр списку вузлів у методі побудови білд
    // noteList = <Note>[];

    updateListView();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Note'),
      ),

      body: getNoteListView(),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
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

    // метод білд для побудови списку записів
    return ListView.builder(
        // кількіть записів беремо зі змінної count
        itemCount: count,
        itemBuilder: (BuildContext context, int position) {
          // карточка окремого елемента списку
          return Card(
            color: Colors.white,
            elevation: 2.0,
            // карточка окремого елемента списку який складається з декількох елементів
            child: ListTile(
              // іконка яка відображає пріоритет
              leading: CircleAvatar(
                // функція виводить колір іконки в залежності від пріоритету
                // пріорітет отримуємо з noteList, тобто з кожного елемента в базі даних
                backgroundColor: getPriorityColor(noteList[position].priority),
                // функція виводить іконку в залежності від пріоритету
                child: getPriorityIcon(noteList[position].priority),
              ),

              // функція виводить в окрему строку [position] назву title
              title: Text(noteList[position].title, style: titleStyle,),

              // функція виводить в окрему строку [position] дату date
              subtitle: Text(noteList[position].date),

              // функція GestureDetector забезпечує обробник onTap при кліку на іконку видалення
              trailing: GestureDetector(

                // функція виводить іконку видалення delete сірого кольору
                  child: const Icon(Icons.delete, color: Colors.grey,),

                // обробник onTap при кліку на іконку видалення (функція видалення _delete запису [position] з бази даних)
                onTap: () {
                    _delete(context, noteList[position]);
                },
              ),

              // обробник onTap при кліку на запис [position],
              // функція переходу до вікна деталей запису, де можна внести зміни в запис або видалити його
              onTap: () {
                debugPrint('ListTile Tapped');
                // переходимо до вікна деталей запису noteList[position], де можна внести зміни в запис або видалити його
                // у вікно передаємо заголовок Edit Note
                navigateToDetail(noteList[position], 'Edit Note');
              },
            ),
          );
        },

    );
  }
  // повертаємо колір в залежності від пріоритету
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
  // повертаємо іконку в залежності від пріоритету
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
  // функція видалення запису з бази данних
  // delete note
  void _delete(BuildContext context, Note note) async {

    final scaffold = Scaffold.of(context);
    // приймає result цілочисельний результат виконання операції видалення
    // параметром передаємо note.id, з яким визивається функція
    int result = await databaseHelper.deleteNote(note.id);
    // перевіряємо результат (якщо відмінний від 0, то виводимо віконце підтвердження видалення)
    if (result != 0) {
      // _showSnackBar(scaffold as BuildContext, 'Note Deleted Successfully');
      _showSnackBar(scaffold.context, 'Note Deleted Successfully');
    //  після видалення запису визиваємо функцію оновлення виду та оновлюємо списки
    // update the list view
      updateListView();
    }
  }

  // функція для відображення повідомлення з основної програми
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
  // оновлення списку
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
