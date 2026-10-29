import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../mini_notes.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  final preferences = await SharedPreferences.getInstance();

  getIt.registerSingleton<SharedPreferences>(preferences);
  getIt.registerLazySingleton<NotesLocalDataSource>(
    () => NotesLocalDataSource(getIt<SharedPreferences>()),
  );
  getIt.registerLazySingleton<NoteRepository>(
    () => NoteRepositoryImpl(getIt<NotesLocalDataSource>()),
  );
  getIt.registerFactory<ListNotesUseCase>(
    () => ListNotesUseCase(getIt<NoteRepository>()),
  );
  getIt.registerFactory<AddNoteUseCase>(
    () => AddNoteUseCase(getIt<NoteRepository>()),
  );
  getIt.registerFactory<DeleteNoteUseCase>(
    () => DeleteNoteUseCase(getIt<NoteRepository>()),
  );
  getIt.registerFactory<NotesPresenter>(
    () => NotesPresenter(
      getIt<ListNotesUseCase>(),
      getIt<AddNoteUseCase>(),
      getIt<DeleteNoteUseCase>(),
    ),
  );
}
