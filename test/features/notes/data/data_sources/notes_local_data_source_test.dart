import 'dart:convert';

import 'package:flutter_dependencies_inyection_example/features/notes/data/data_sources/notes_local_data_source.dart';
import 'package:flutter_dependencies_inyection_example/features/notes/domain/models/note_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences preferences;
  late NotesLocalDataSource dataSource;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
    dataSource = NotesLocalDataSource(preferences);
  });

  test('returns an empty list when no notes are stored', () {
    expect(dataSource.listNotes(), isEmpty);
  });

  test('adds notes and restores them from the stored JSON', () async {
    await dataSource.addNote(NoteModel(id: '1', text: 'Comprar café'));
    await dataSource.addNote(NoteModel(id: '2', text: 'Preparar demo'));

    expect(jsonDecode(preferences.getString('mini_notes')!), [
      {'id': '1', 'text': 'Comprar café'},
      {'id': '2', 'text': 'Preparar demo'},
    ]);

    final restored = NotesLocalDataSource(preferences).listNotes();
    expect(restored.map((note) => note.id), ['1', '2']);
    expect(restored.map((note) => note.text), [
      'Comprar café',
      'Preparar demo',
    ]);
  });

  test('deletes by id without deleting notes with the same text', () async {
    await dataSource.addNote(NoteModel(id: '1', text: 'Nota'));
    await dataSource.addNote(NoteModel(id: '2', text: 'Nota'));

    await dataSource.deleteNote('1');

    expect(dataSource.listNotes().single.id, '2');
  });

  test('deleting an unknown id preserves existing notes', () async {
    await dataSource.addNote(NoteModel(id: '1', text: 'Nota'));

    await dataSource.deleteNote('unknown');

    expect(dataSource.listNotes().single.id, '1');
  });

  test('rejects invalid JSON and invalid note structures', () async {
    for (final value in [
      'invalid json',
      '{}',
      '[null]',
      '[{"id": 1, "text": "Nota"}]',
      '[{"id": "1"}]',
    ]) {
      await preferences.setString('mini_notes', value);

      expect(dataSource.listNotes, throwsFormatException);
    }
  });

  test('does not overwrite corrupted data when adding or deleting', () async {
    await preferences.setString('mini_notes', 'invalid json');

    await expectLater(
      dataSource.addNote(NoteModel(id: '1', text: 'Nota')),
      throwsFormatException,
    );
    await expectLater(dataSource.deleteNote('1'), throwsFormatException);

    expect(preferences.getString('mini_notes'), 'invalid json');
  });
}
