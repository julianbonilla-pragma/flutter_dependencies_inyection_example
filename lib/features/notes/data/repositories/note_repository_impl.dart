import '../../../../mini_notes.dart';

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
