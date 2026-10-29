import 'package:shared_preferences/shared_preferences.dart';

import '../../../../mini_notes.dart';

class DeleteNoteUseCase {
  final NoteRepository _repository;

  DeleteNoteUseCase(SharedPreferences preferences)
    : _repository = NoteRepositoryImpl(NotesLocalDataSource(preferences));

  Future<void> call(String id) async {
    return _repository.deleteNote(id);
  }
}
