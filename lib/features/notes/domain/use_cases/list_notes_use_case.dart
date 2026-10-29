import '../../../../mini_notes.dart';

class ListNotesUseCase {
  final NoteRepository _repository;

  ListNotesUseCase(this._repository);

  List<NoteModel> call() => _repository.listNotes();
}
