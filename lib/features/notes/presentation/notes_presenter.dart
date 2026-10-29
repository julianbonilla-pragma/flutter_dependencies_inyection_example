import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/models/note_model.dart';
import '../domain/use_cases/add_note_use_case.dart';
import '../domain/use_cases/delete_note_use_case.dart';
import '../domain/use_cases/list_notes_use_case.dart';

class NotesPresenter extends ChangeNotifier {
  final ListNotesUseCase _listNotes;
  final AddNoteUseCase _addNote;
  final DeleteNoteUseCase _deleteNote;

  List<NoteModel> _notes = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _isDisposed = false;

  NotesPresenter(SharedPreferences preferences)
    : _listNotes = ListNotesUseCase(preferences),
      _addNote = AddNoteUseCase(preferences),
      _deleteNote = DeleteNoteUseCase(preferences);

  List<NoteModel> get notes => List.unmodifiable(_notes);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> loadNotes() {
    return _run(() {
      _notes = _listNotes();
    });
  }

  Future<bool> addNote(NoteModel note) {
    return _run(() async {
      await _addNote(note);
      _notes = _listNotes();
    });
  }

  Future<bool> deleteNote(String id) {
    return _run(() async {
      await _deleteNote(id);
      _notes = _listNotes();
    });
  }

  Future<bool> _run(FutureOr<void> Function() action) async {
    if (_isDisposed) {
      throw StateError('El presenter ya fue liberado.');
    }
    if (_isLoading) {
      throw StateError('Ya hay una operación en curso.');
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await action();
      return true;
    } on Exception catch (error) {
      _errorMessage = error.toString();
      return false;
    } on StateError catch (error) {
      _errorMessage = error.toString();
      return false;
    } finally {
      _isLoading = false;
      if (!_isDisposed) {
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
