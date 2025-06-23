import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:personal_notes_app/models/note.dart';

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
          Text(DateFormat('MMM d, yyyy').format(note.createdAt), style: TextStyle(fontSize: 12, color: Colors.black45)),
        ],
      ),
    );
  }
}
