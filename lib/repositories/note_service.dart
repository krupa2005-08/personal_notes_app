import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:personal_notes_app/models/note.dart';
import 'package:personal_notes_app/providers/note_providers.dart';

void saveNote({
  required BuildContext context,
  required WidgetRef ref,
  required String title,
  required String description,
  required bool isEditMode,
  int? noteIndex,
  DateTime? createdAt,
}) {
  if (title.isEmpty || description.isEmpty) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Title and description cannot be empty.'), backgroundColor: Colors.red));
    return; // Stop the function if validation fails
  }

  final notesRepo = ref.read(notesRepositoryProvider);

  // 3. Perform the correct action (update or add)
  if (isEditMode) {
    final updatedNote = Note(title: title, description: description, createdAt: createdAt!);
    notesRepo.updateNote(noteIndex!, updatedNote);
  } else {
    final newNote = Note(title: title, description: description, createdAt: DateTime.now());
    notesRepo.addNote(newNote);
  }

  // 4. Navigate back
  Navigator.pop(context);
}
