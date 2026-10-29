import 'package:flutter/material.dart';
import 'package:flutter_dependencies_inyection_example/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('validates, saves trimmed notes and deletes them', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('No hay notas. Agrega la primera.'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), '   ');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    expect(find.text('Escribe una nota antes de guardar.'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), '  Comprar café  ');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(find.text('Comprar café'), findsOneWidget);
    expect(
      tester.widget<TextFormField>(find.byType(TextFormField)).controller!.text,
      isEmpty,
    );

    await tester.tap(find.byTooltip('Eliminar nota'));
    await tester.pumpAndSettle();
    expect(find.text('No hay notas. Agrega la primera.'), findsOneWidget);
  });

  testWidgets('restores persisted notes when opening the app', (tester) async {
    SharedPreferences.setMockInitialValues({
      'mini_notes': '[{"id":"1","text":"Preparar demo"}]',
    });

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Preparar demo'), findsOneWidget);
  });

  testWidgets('shows errors and preserves input when saving fails', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('mini_notes', 'invalid json');

    await tester.enterText(find.byType(TextFormField), 'Mi nota');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(find.textContaining('FormatException'), findsOneWidget);
    expect(
      tester.widget<TextFormField>(find.byType(TextFormField)).controller!.text,
      'Mi nota',
    );

    await preferences.remove('mini_notes');
    await tester.tap(find.text('Reintentar carga'));
    await tester.pumpAndSettle();

    expect(find.textContaining('FormatException'), findsNothing);
    expect(find.text('No hay notas. Agrega la primera.'), findsOneWidget);
  });
}
