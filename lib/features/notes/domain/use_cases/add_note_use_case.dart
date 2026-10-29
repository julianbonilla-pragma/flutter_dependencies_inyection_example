import '../../../../mini_notes.dart';

class AddNoteUseCase {
  final NoteRepository _repository;

  AddNoteUseCase(this._repository);

  Future<void> call(NoteModel note) async {
    return _repository.addNote(note);
  }
}
