import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/note.dart';
import '../repositories/notes_repository.dart';

part 'note_providers.g.dart';

// 1. Provider for the Hive Box
@riverpod
Future<Box<Note>> notesBox(NotesBoxRef ref) async {
  return await Hive.openBox<Note>('notes');
}

// 2. Provider for the NotesRepository
@riverpod
NotesRepository notesRepository(NotesRepositoryRef ref) {
  final box = ref.watch(notesBoxProvider).value!;
  return NotesRepository(box);
}

// 3. A StateProvider for the search query
@riverpod
class SearchQuery extends _$SearchQuery {
  @override
  String build() => '';

  void update(String query) {
    state = query;
  }
}
