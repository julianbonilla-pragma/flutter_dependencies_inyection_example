import '../models/note_model.dart';

abstract class NoteRepository {
  List<NoteModel> listNotes();
  Future<void> addNote(NoteModel note);
  Future<void> deleteNote(String id);
}
