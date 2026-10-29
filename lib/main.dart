import 'package:flutter/material.dart';

import 'di/dependencies.dart';
import 'features/notes/presentation/notes_page.dart';
import 'features/notes/presentation/notes_presenter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<NotesPresenter> _presenter;

  @override
  void initState() {
    super.initState();
    _presenter = _initializePresenter();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MiniNotas',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: FutureBuilder<NotesPresenter>(
        future: _presenter,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Scaffold(
              appBar: AppBar(title: const Text('MiniNotas')),
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'No se pudo iniciar el almacenamiento: ${snapshot.error}',
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _presenter = _initializePresenter();
                        });
                      },
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return NotesPage(presenter: snapshot.requireData);
        },
      ),
    );
  }

  Future<NotesPresenter> _initializePresenter() async {
    await configureDependencies();
    return getIt<NotesPresenter>();
  }
}
