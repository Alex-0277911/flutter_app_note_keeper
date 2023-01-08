import 'package:flutter/material.dart';

class NoteList extends StatefulWidget {
  const NoteList({Key? key}) : super(key: key);

  @override
  State<NoteList> createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {

  int count = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Note'),
      ),

      body: getNoteListView(),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          debugPrint('FAB clicked');
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
              leading: const CircleAvatar(
                backgroundColor: Colors.yellow,
                child: Icon(Icons.keyboard_arrow_right),
              ),
              title: Text('Dummy Title', style: titleStyle,),

              subtitle: const Text('Dummy Date'),

              trailing: const Icon(Icons.delete, color: Colors.grey,),

              onTap: () {
                debugPrint('ListTile Tapped');
              },
            ),
          );
        },

    );
  }

}
