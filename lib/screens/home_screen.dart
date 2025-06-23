import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../models/note.dart';
import 'add_edit_note_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  // A list of predefined colors for our note cards
  final List<Color> noteColors = [
    Colors.amber.shade200,
    Colors.lightGreen.shade200,
    Colors.lightBlue.shade200,
    Colors.orange.shade200,
    Colors.pink.shade200,
    Colors.teal.shade200,
  ];

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

  void _showDeleteConfirmationDialog(BuildContext context, Box<Note> box, int index, Note note) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Note?'),
          content: Text('Are you sure you want to delete "${note.title}"?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                box.deleteAt(index);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${note.title} deleted")));
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Notes', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            // --- Improved Search Bar ---
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search notes...',
                prefixIcon: Icon(Icons.search, size: 20),
                fillColor: Theme.of(context).cardColor,
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              ),
            ),
            SizedBox(height: 20),
            // --- Note Grid ---
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: Hive.box<Note>('notes').listenable(),
                builder: (context, Box<Note> box, _) {
                  final allNotes = box.values.toList().reversed.toList();
                  final filteredNotes =
                      allNotes.where((note) {
                        final title = note.title.toLowerCase();
                        final query = _searchQuery.toLowerCase();
                        return title.contains(query);
                      }).toList();

                  if (filteredNotes.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.note_alt_outlined, size: 80, color: Colors.grey),
                          SizedBox(height: 16),
                          Text("No notes found.", style: TextStyle(fontSize: 18, color: Colors.grey)),
                        ],
                      ),
                    );
                  }

                  // --- Using StaggeredGridView for a dynamic layout ---
                  return MasonryGridView.builder(
                    itemCount: filteredNotes.length,
                    gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    itemBuilder: (context, index) {
                      final note = filteredNotes[index];
                      // Find the original index to use for editing/deleting
                      final originalIndex = allNotes.indexOf(note);

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddEditNoteScreen(note: note, noteIndex: originalIndex),
                            ),
                          );
                        },
                        onLongPress: () {
                          // Long press to delete
                          _showDeleteConfirmationDialog(context, box, originalIndex, note);
                        },
                        child: NoteCard(note: note, color: noteColors[index % noteColors.length]),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // --- Improved Floating Action Button ---
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => AddEditNoteScreen()));
        },
        label: Text('New Note'),
        icon: Icon(Icons.add),
      ),
    );
  }
}

// --- Custom Widget for the Note Card ---
class NoteCard extends StatelessWidget {
  final Note note;
  final Color color;

  const NoteCard({required this.note, required this.color, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            note.title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 8),
          Text(
            note.description,
            style: TextStyle(fontSize: 14, color: Colors.black54),
            maxLines: 6,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 12),
          Text(
            // Using intl package to format the date
            DateFormat('MMM d, yyyy').format(note.createdAt),
            style: TextStyle(fontSize: 12, color: Colors.black45),
          ),
        ],
      ),
    );
  }
}
