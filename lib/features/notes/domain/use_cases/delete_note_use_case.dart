import 'package:shared_preferences/shared_preferences.dart';

import '../../data/data_sources/notes_local_data_source.dart';
import '../../data/repositories/note_repository_impl.dart';
import '../repositories/note_repository.dart';

class DeleteNoteUseCase {
  final NoteRepository _repository;

  DeleteNoteUseCase(SharedPreferences preferences)
    : _repository = NoteRepositoryImpl(NotesLocalDataSource(preferences));

  Future<void> call(String id) async {
    return _repository.deleteNote(id);
  }
}
