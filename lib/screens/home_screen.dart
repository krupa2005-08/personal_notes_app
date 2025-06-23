import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:personal_notes_app/constants/app_constants.dart';
import 'package:personal_notes_app/models/note.dart';
import 'package:personal_notes_app/providers/note_providers.dart';
import 'package:personal_notes_app/utils/dialog_utils.dart';
import 'package:personal_notes_app/widgets/note_card.dart';

class HomeScreen extends ConsumerWidget {
  HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = ref.watch(searchQueryProvider);
    final notesBoxAsyncValue = ref.watch(notesBoxProvider);

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
            TextField(
              onChanged: (query) => ref.read(searchQueryProvider.notifier).update(query),
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
            Expanded(
              child: notesBoxAsyncValue.when(
                loading: () => Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error loading notes: $err')),
                data: (box) {
                  return ValueListenableBuilder(
                    valueListenable: box.listenable(),
                    builder: (context, Box<Note> box, _) {
                      final allNotesWithIndices =
                          box.toMap().entries.map((entry) {
                            return (index: entry.key as int, note: entry.value as Note);
                          }).toList();

                      // 2. Filter this list of records.
                      final query = searchQuery.toLowerCase();
                      final filteredNotes =
                          allNotesWithIndices.where((record) {
                            final title = record.note.title.toLowerCase();
                            final description = record.note.description.toLowerCase();
                            return title.contains(query) || description.contains(query);
                          }).toList();

                      // 3. Reverse the final list to show newest notes first.
                      final displayedNotes = filteredNotes.reversed.toList();

                      if (displayedNotes.isEmpty) {
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

                      return MasonryGridView.builder(
                        itemCount: filteredNotes.length,
                        gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        itemBuilder: (context, index) {
                          final record = displayedNotes[index];
                          final note = record.note;
                          final originalIndex = record.index;

                          return InkWell(
                            onTap: () {
                              context.push('/note/$originalIndex');
                            },
                            onLongPress: () {
                              showDeleteConfirmationDialog(context, ref, originalIndex, note);
                            },
                            child: NoteCard(note: note, color: noteColors[originalIndex % noteColors.length]),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/add');
        },
        label: Text('New Note'),
        icon: Icon(Icons.add),
      ),
    );
  }
}
