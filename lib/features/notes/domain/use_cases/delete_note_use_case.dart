import '../../../../mini_notes.dart';

class DeleteNoteUseCase {
  final NoteRepository _repository;

  DeleteNoteUseCase(this._repository);

  Future<void> call(String id) async {
    return _repository.deleteNote(id);
  }
}
