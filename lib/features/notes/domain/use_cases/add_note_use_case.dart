import 'package:shared_preferences/shared_preferences.dart';

import '../../../../mini_notes.dart';

class AddNoteUseCase {
  final NoteRepository _repository;

  AddNoteUseCase(SharedPreferences preferences)
    : _repository = NoteRepositoryImpl(NotesLocalDataSource(preferences));

  Future<void> call(NoteModel note) async {
    return _repository.addNote(note);
  }
}
