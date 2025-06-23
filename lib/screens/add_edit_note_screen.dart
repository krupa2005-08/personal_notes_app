import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../models/note.dart';

class AddEditNoteScreen extends StatefulWidget {
  final Note? note;
  final int? noteIndex;

  const AddEditNoteScreen({super.key, this.note, this.noteIndex});

  @override
  State<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late bool _isEditMode;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.note != null;
    _titleController = TextEditingController(text: _isEditMode ? widget.note!.title : '');
    _descriptionController = TextEditingController(text: _isEditMode ? widget.note!.description : '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveNote() {
    // Basic validation
    final title = _titleController.text;
    final description = _descriptionController.text;

    if (title.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Title and description cannot be empty.'), backgroundColor: Colors.red));
      return; // Stop the function if validation fails
    }

    final notesBox = Hive.box<Note>('notes');

    if (_isEditMode) {
      // Update existing note
      final updatedNote = Note(
        title: title,
        description: description,
        createdAt: widget.note!.createdAt, // Keep original creation date
      );
      notesBox.putAt(widget.noteIndex!, updatedNote);
    } else {
      // Add new note
      final newNote = Note(title: title, description: description, createdAt: DateTime.now());
      notesBox.add(newNote);
    }
    Navigator.pop(context); // Go back to the home screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Note' : 'Add Note'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [IconButton(icon: Icon(Icons.save_outlined), onPressed: _saveNote, tooltip: 'Save Note')],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          children: [
            // --- Improved Title TextField ---
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Title',
                hintStyle: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.grey.withOpacity(0.7)),
              ),
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              maxLines: null, // Allows title to wrap if it's very long
            ),
            SizedBox(height: 10),
            // --- Improved Description TextField ---
            Expanded(
              child: TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Start typing your note here...',
                  hintStyle: TextStyle(fontSize: 18),
                ),
                style: TextStyle(
                  fontSize: 18,
                  height: 1.5, // Improves line spacing for readability
                ),
                maxLines: null, // Fills the available space
                expands: true, // Ensures it takes up all vertical space
                keyboardType: TextInputType.multiline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
