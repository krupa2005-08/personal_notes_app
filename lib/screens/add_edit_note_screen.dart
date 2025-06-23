// lib/screens/add_edit_note_screen.dart

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
  final _formKey = GlobalKey<FormState>();
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
    if (_formKey.currentState!.validate()) {
      final notesBox = Hive.box<Note>('notes');
      final String title = _titleController.text;
      final String description = _descriptionController.text;

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Note' : 'Add Note'),
        actions: [IconButton(icon: Icon(Icons.save), onPressed: _saveNote, tooltip: 'Save Note')],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                maxLines: 10, // Multiline
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
