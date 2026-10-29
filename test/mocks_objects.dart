import 'package:flutter_dependencies_inyection_example/mini_notes.dart';
import 'package:mocktail/mocktail.dart';

class MockListNotesUseCase extends Mock implements ListNotesUseCase {}

class MockAddNoteUseCase extends Mock implements AddNoteUseCase {}

class MockDeleteNoteUseCase extends Mock implements DeleteNoteUseCase {}
