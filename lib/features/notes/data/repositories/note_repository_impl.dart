import '../../domain/models/note_model.dart';
import '../../domain/repositories/note_repository.dart';
import '../data_sources/notes_local_data_source.dart';

class NoteRepositoryImpl implements NoteRepository {
  final NotesLocalDataSource _localDataSource;

  NoteRepositoryImpl(this._localDataSource);

  @override
  List<NoteModel> listNotes() {
    return _localDataSource.listNotes();
  }

  @override
  Future<void> addNote(NoteModel note) async {
    await _localDataSource.addNote(note);
  }

  @override
  Future<void> deleteNote(String id) async {
    await _localDataSource.deleteNote(id);
  }
}
