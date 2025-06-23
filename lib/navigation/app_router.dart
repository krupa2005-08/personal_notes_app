import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:personal_notes_app/providers/note_providers.dart';
import 'package:personal_notes_app/screens/add_edit_note_screen.dart';
import 'package:personal_notes_app/screens/home_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => HomeScreen()),

      GoRoute(
        path: '/add',
        builder: (context, state) {
          return const AddEditNoteScreen();
        },
      ),

      GoRoute(
        path: '/note/:index',
        builder: (context, state) {
          final indexString = state.pathParameters['index'];
          if (indexString == null) {
            return HomeScreen();
          }
          final noteIndex = int.parse(indexString);
          final box = ref.read(notesBoxProvider).value;
          final note = box?.getAt(noteIndex);

          if (note == null) {
            return HomeScreen();
          }

          return AddEditNoteScreen(note: note, noteIndex: noteIndex);
        },
      ),
    ],
  );
});
