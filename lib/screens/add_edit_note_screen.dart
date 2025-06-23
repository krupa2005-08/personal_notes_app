import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:personal_notes_app/models/note.dart';
import 'package:personal_notes_app/repositories/note_service.dart';

class AddEditNoteScreen extends ConsumerStatefulWidget {
  final Note? note;
  final int? noteIndex;

  const AddEditNoteScreen({super.key, this.note, this.noteIndex});

  @override
  ConsumerState<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends ConsumerState<AddEditNoteScreen> {
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

  // The bulky _saveNote method is now gone!

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Note' : 'Add Note'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(Icons.save_outlined),
            tooltip: 'Save Note',
            onPressed: () {
              saveNote(
                context: context,
                ref: ref,
                title: _titleController.text,
                description: _descriptionController.text,
                isEditMode: _isEditMode,
                noteIndex: widget.noteIndex,
                createdAt: _isEditMode ? widget.note!.createdAt : null,
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          children: [
            // Title TextField
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Title',
                hintStyle: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.grey.withOpacity(0.7)),
              ),
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              maxLines: null,
            ),
            SizedBox(height: 10),
            // Description TextField
            Expanded(
              child: TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Start typing your note here...',
                  hintStyle: TextStyle(fontSize: 18),
                ),
                style: TextStyle(fontSize: 18, height: 1.5),
                maxLines: null,
                expands: true,
                keyboardType: TextInputType.multiline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
