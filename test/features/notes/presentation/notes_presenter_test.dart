import 'package:flutter_dependencies_inyection_example/features/notes/domain/models/note_model.dart';
import 'package:flutter_dependencies_inyection_example/features/notes/presentation/notes_presenter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences preferences;
  late NotesPresenter presenter;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
    presenter = NotesPresenter(preferences);
  });

  tearDown(() {
    presenter.dispose();
  });

  test('starts with an empty idle state', () {
    expect(presenter.notes, isEmpty);
    expect(presenter.isLoading, isFalse);
    expect(presenter.errorMessage, isNull);
  });

  test('loads persisted notes and notifies loading transitions', () async {
    await preferences.setString('mini_notes', '[{"id":"1","text":"Nota"}]');
    final loadingStates = <bool>[];
    presenter.addListener(() => loadingStates.add(presenter.isLoading));

    expect(await presenter.loadNotes(), isTrue);

    expect(presenter.notes.single.text, 'Nota');
    expect(loadingStates, [true, false]);
    expect(() => presenter.notes.clear(), throwsUnsupportedError);
  });

  test('refreshes notes after adding and deleting by id', () async {
    expect(await presenter.addNote(NoteModel(id: '1', text: 'Nota')), isTrue);
    expect(await presenter.addNote(NoteModel(id: '2', text: 'Nota')), isTrue);
    expect(presenter.notes.length, 2);

    expect(await presenter.deleteNote('1'), isTrue);
    expect(presenter.notes.single.id, '2');
  });

  test('exposes read errors, preserves notes and supports retry', () async {
    await presenter.addNote(NoteModel(id: '1', text: 'Nota'));
    await preferences.setString('mini_notes', 'invalid json');

    expect(await presenter.loadNotes(), isFalse);
    expect(presenter.errorMessage, isNotEmpty);
    expect(presenter.isLoading, isFalse);
    expect(presenter.notes.single.id, '1');

    await preferences.remove('mini_notes');

    expect(await presenter.loadNotes(), isTrue);
    expect(presenter.errorMessage, isNull);
    expect(presenter.notes, isEmpty);
  });

  test('exposes write-path errors without reporting success', () async {
    await preferences.setString('mini_notes', 'invalid json');

    expect(await presenter.addNote(NoteModel(id: '1', text: 'Nota')), isFalse);
    expect(presenter.errorMessage, isNotEmpty);
    expect(await presenter.deleteNote('1'), isFalse);
    expect(presenter.isLoading, isFalse);
  });

  test('rejects concurrent operations explicitly', () async {
    final first = presenter.loadNotes();

    await expectLater(presenter.deleteNote('1'), throwsStateError);
    expect(await first, isTrue);
  });

  test('does not notify after being disposed during an operation', () async {
    final temporaryPresenter = NotesPresenter(preferences);
    var notifications = 0;
    temporaryPresenter.addListener(() => notifications++);

    final operation = temporaryPresenter.loadNotes();
    temporaryPresenter.dispose();

    expect(await operation, isTrue);
    expect(notifications, 1);
    await expectLater(temporaryPresenter.loadNotes(), throwsStateError);
  });
}
