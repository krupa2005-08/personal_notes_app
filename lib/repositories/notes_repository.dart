import 'package:hive/hive.dart';
import '../models/note.dart';

class NotesRepository {
  final Box<Note> _notesBox;

  NotesRepository(this._notesBox);

  Future<void> addNote(Note note) async {
    await _notesBox.add(note);
  }

  Future<void> updateNote(int index, Note note) async {
    await _notesBox.putAt(index, note);
  }

  Future<void> deleteNote(int index) async {
    await _notesBox.deleteAt(index);
  }

  Future<void> clearNotes() async {
    await _notesBox.clear();
  }
}
