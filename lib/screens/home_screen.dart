import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/note.dart';
import 'add_edit_note_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Controller for the search bar
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Notes'),
        // Simple Search Bar
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search notes by title...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                filled: true,
              ),
            ),
          ),
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Note>('notes').listenable(),
        builder: (context, Box<Note> box, _) {
          // Filter notes based on search query
          final filteredNotes =
              box.values
                  .where((note) {
                    final title = note.title.toLowerCase();
                    final query = _searchQuery.toLowerCase();
                    return title.contains(query);
                  })
                  .toList()
                  .reversed
                  .toList(); // show newest first

          if (filteredNotes.isEmpty) {
            return Center(child: Text("No notes yet.\nTap the '+' button to add one!", textAlign: TextAlign.center));
          }

          return ListView.builder(
            itemCount: filteredNotes.length,
            itemBuilder: (context, index) {
              final note = filteredNotes[index];
              return Dismissible(
                key: Key(note.createdAt.toString()), // Unique key for each item
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  // Find the original index in the box before filtering
                  final originalIndex = box.values.toList().indexOf(note);
                  box.deleteAt(originalIndex);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("${note.title} deleted"),
                      action: SnackBarAction(
                        label: 'UNDO',
                        onPressed: () {
                          // To undo, we add it back. Hive boxes don't have an "insert"
                          // so this will add it to the end.
                          box.add(note);
                        },
                      ),
                    ),
                  );
                },
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Icon(Icons.delete, color: Colors.white),
                ),
                child: Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(note.title, style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(note.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                    onTap: () {
                      // Find the original index in the box before filtering
                      final originalIndex = box.values.toList().indexOf(note);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddEditNoteScreen(note: note, noteIndex: originalIndex),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => AddEditNoteScreen()));
        },
        child: Icon(Icons.add),
        tooltip: 'Add Note',
      ),
    );
  }
}
