import 'package:shared_preferences/shared_preferences.dart';

import '../../data/data_sources/notes_local_data_source.dart';
import '../../data/repositories/note_repository_impl.dart';
import '../models/note_model.dart';
import '../repositories/note_repository.dart';

class AddNoteUseCase {
  final NoteRepository _repository;

  AddNoteUseCase(SharedPreferences preferences)
    : _repository = NoteRepositoryImpl(NotesLocalDataSource(preferences));

  Future<void> call(NoteModel note) async {
    return _repository.addNote(note);
  }
}
