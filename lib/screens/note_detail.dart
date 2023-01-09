import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_app_note_keeper/models/note.dart';
import 'package:flutter_app_note_keeper/utils/database_helper.dart';
import 'package:intl/intl.dart';

class NoteDetail extends StatefulWidget {
  const NoteDetail({
    Key? key,
    required this.appBarTitle,
    required this.note,
  }) : super(key: key);

  final String appBarTitle;
  final Note note;

  @override
  State<NoteDetail> createState() => _NoteDetailState();
}

class _NoteDetailState extends State<NoteDetail> {

  static final _priorities = ['High', 'Low'];

  DatabaseHelper helper = DatabaseHelper();

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    TextStyle? textStyle = Theme.of(context).textTheme.titleLarge;

    titleController.text = widget.note.title;
    descriptionController.text = widget.note.description;

    return WillPopScope(
      //  write code to control things, when user press BACK
      //  navigation button in device
      // onWillPop:() { moveToLastScreen();
      //   return Future(() => true); },
      onWillPop:()  {moveToLastScreen();
      return Future(() => true);},
      child: Scaffold(
        appBar: AppBar(
          // параметр передаем с другого виджета, в зависисмости
          // от того какую надпись нужно отобразить
          title: Text(widget.appBarTitle),
          leading: IconButton(icon: const Icon(
            Icons.arrow_back),
            onPressed: () {
              //  write code to control things, when user press BACK
              //  navigation button in device
              moveToLastScreen();
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
          child: ListView(
            children: [
              //  first element
              ListTile(
                title: DropdownButton(
                  items: _priorities.map((String dropDownStringItem) {
                    return DropdownMenuItem<String>(
                      value: dropDownStringItem,
                      child: Text(dropDownStringItem),
                    );
                  }).toList(),

                  style: textStyle,

                  value: getPriorityAsString(widget.note.priority),

                  onChanged: (valueSelectedByUser) {
                    setState(() {
                      debugPrint('User selected $valueSelectedByUser');
                      updatePriorityAsInt(valueSelectedByUser!);
                    });
                  },
                ),
              ),

              //  second element
              Padding(
                padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: TextField(
                  controller: titleController,
                  style: textStyle,
                  onChanged: (value) {
                    debugPrint('Something changed in Title Text Field');
                    updateTitle();
                  },
                  decoration: InputDecoration(
                    labelText: 'Title',
                    labelStyle: textStyle,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0)),
                  ),
                ),
              ),

              //  Third element
              Padding(
                padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: TextField(
                  controller: descriptionController,
                  style: textStyle,
                  onChanged: (value) {
                    debugPrint('Something changed in Description Text Field');
                    updateDescription();
                  },
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: textStyle,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0)),
                  ),
                ),
              ),

              //  Fourth Element
              Padding(
                padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColorDark,
                          foregroundColor: Theme.of(context).primaryColorLight,
                        ),
                        onPressed: () {
                          setState(
                            () {
                              debugPrint('Save button clicked');
                              _save();
                            },
                          );
                        },
                        child: const Text(
                          'Save',
                          textScaleFactor: 1.3,
                        ),
                      ),
                    ),

                    Container(width: 5.0,),

                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColorDark,
                          foregroundColor: Theme.of(context).primaryColorLight,
                        ),
                        onPressed: () {
                          setState(
                                () {
                              debugPrint('Delete button clicked');
                              _delete();
                            },
                          );
                        },
                        child: const Text(
                          'Delete',
                          textScaleFactor: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

//  Convert the String priority in the form of integer before saving it to Database
  void updatePriorityAsInt(String value) {
    switch (value) {
      case 'High':
        widget.note.priority = 1;
        break;
      case 'Low':
        widget.note.priority = 2;
        break;
    }
  }

  //  Convert int priority to String priority and display it to user in DropDown
  String getPriorityAsString(int value) {
    late String priority;
    switch (value) {
      case 1:
        priority = _priorities[0]; // 'High'
        break;
      case 2:
        priority = _priorities[1]; // 'Low'
        break;
    }
    return priority;
  }

//  Update the title of Note object
  void updateTitle() {
    widget.note.title = titleController.text;
  }

  //  Update the description of Note object
  void updateDescription() {
    widget.note.description = descriptionController.text;
  }

//  save data to database
  void _save() async {

    moveToLastScreen();

    widget.note.date = DateFormat.yMMMd().format(DateTime.now());
    int result;
    if (widget.note.id != null) { // Case 1: Update operation
      result = await helper.updateNote(widget.note);
    } else {  // Case 2: Insert Operation
      result = await helper.insertNote(widget.note);
    }

    if (result != 0) {  //Success
      _showAlertDialog('Status', 'Note Saved Successfully');
    } else {  //Failure
      _showAlertDialog('Status', 'Problem Saving Note');
    }
  }

  void _delete() async {

    moveToLastScreen();

  //  Case 1: If user is trying to delete the NEW NOTE i.e. he has come to
  //  the detail page by pressing the FAB of NoteList page.
      if (widget.note.id == null) {
        _showAlertDialog('Status', 'No Note was deleted');
      }
  //  Case 2: User is trying to delete the old note that already has a valid ID.
      int result = await helper.deleteNote(widget.note.id);
      if (result !=0) {
        _showAlertDialog('Status', 'Note Deleted Successfully');
      } else {
        _showAlertDialog('Status', 'Error Occurred while Deleting Note');
      }
  }

  void _showAlertDialog(String title, String message) {

    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(
        context: context,
        builder: (_) => alertDialog
    );
  }
}
