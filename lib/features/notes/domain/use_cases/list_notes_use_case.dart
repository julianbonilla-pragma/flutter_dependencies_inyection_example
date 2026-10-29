import 'package:shared_preferences/shared_preferences.dart';

import '../../../../mini_notes.dart';

class ListNotesUseCase {
  final NoteRepository _repository;

  ListNotesUseCase(SharedPreferences preferences)
    : _repository = NoteRepositoryImpl(NotesLocalDataSource(preferences));

  List<NoteModel> call() => _repository.listNotes();
}
