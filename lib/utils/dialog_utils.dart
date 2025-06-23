import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:personal_notes_app/models/note.dart';
import 'package:personal_notes_app/providers/note_providers.dart';

void showDeleteConfirmationDialog(BuildContext context, WidgetRef ref, int index, Note note) {
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
              // Use the repository from the provider to delete
              ref.read(notesRepositoryProvider).deleteNote(index);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${note.title} deleted")));
            },
          ),
        ],
      );
    },
  );
}
