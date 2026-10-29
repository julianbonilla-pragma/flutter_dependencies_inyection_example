import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/note_model.dart';

class NotesLocalDataSource {
  static const _storageKey = 'mini_notes';

  final SharedPreferences _preferences;

  NotesLocalDataSource(this._preferences);

  List<NoteModel> listNotes() {
    final String? storedNotes = _preferences.getString(_storageKey);
    if (storedNotes == null) {
      return [];
    }

    final dynamic decoded = jsonDecode(storedNotes);
    if (decoded is! List) {
      throw const FormatException('Las notas deben ser una lista JSON.');
    }

    return decoded.map((item) {
      if (item is! Map<String, dynamic> ||
          item['id'] is! String ||
          item['text'] is! String) {
        throw const FormatException('El formato de una nota no es válido.');
      }
      return NoteModel.fromJson(item);
    }).toList();
  }

  Future<void> addNote(NoteModel note) async {
    final List<NoteModel> notes = listNotes();
    notes.add(note);
    await _saveNotes(notes);
  }

  Future<void> deleteNote(String id) async {
    final List<NoteModel> notes = listNotes();
    notes.removeWhere((note) => note.id == id);
    await _saveNotes(notes);
  }

  Future<void> _saveNotes(List<NoteModel> notes) async {
    final String encoded = jsonEncode(
      notes.map((note) => note.toJson()).toList(),
    );
    final bool saved = await _preferences.setString(_storageKey, encoded);
    if (!saved) {
      throw StateError('No se pudieron guardar las notas.');
    }
  }
}
