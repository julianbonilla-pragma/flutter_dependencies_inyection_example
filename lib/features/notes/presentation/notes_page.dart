import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../mini_notes.dart';

class NotesPage extends StatefulWidget {
  final SharedPreferences preferences;

  const NotesPage({super.key, required this.preferences});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  late final NotesPresenter _presenter;

  @override
  void initState() {
    super.initState();
    _presenter = NotesPresenter(widget.preferences);
    _presenter.loadNotes();
  }

  Future<void> _saveNote() async {
    if (_presenter.isLoading || !_formKey.currentState!.validate()) {
      return;
    }

    final NoteModel note = NoteModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      text: _textController.text.trim(),
    );
    final bool saved = await _presenter.addNote(note);
    if (mounted && saved) {
      _textController.clear();
    }
  }

  @override
  void dispose() {
    _presenter.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MiniNotas')),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _presenter,
          builder: (context, child) {
            final notes = _presenter.notes;
            final isLoading = _presenter.isLoading;
            final errorMessage = _presenter.errorMessage;

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _textController,
                          enabled: !isLoading,
                          decoration: const InputDecoration(
                            labelText: 'Escribe una nota',
                            border: OutlineInputBorder(),
                          ),
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _saveNote(),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Escribe una nota antes de guardar.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        FilledButton(
                          onPressed: isLoading ? null : _saveNote,
                          child: const Text('Guardar'),
                        ),
                      ],
                    ),
                  ),
                  if (isLoading) const LinearProgressIndicator(),
                  if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            errorMessage,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                          TextButton(
                            onPressed: isLoading ? null : _presenter.loadNotes,
                            child: const Text('Reintentar carga'),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: notes.isEmpty
                        ? Center(
                            child: Text(
                              errorMessage != null
                                  ? 'No se pudieron cargar las notas.'
                                  : isLoading
                                  ? 'Cargando notas...'
                                  : 'No hay notas. Agrega la primera.',
                            ),
                          )
                        : ListView.builder(
                            itemCount: notes.length,
                            itemBuilder: (context, index) {
                              final note = notes[index];
                              return ListTile(
                                key: ValueKey(note.id),
                                title: Text(note.text),
                                trailing: IconButton(
                                  tooltip: 'Eliminar nota',
                                  onPressed: isLoading
                                      ? null
                                      : () => _presenter.deleteNote(note.id),
                                  icon: const Icon(Icons.delete_outline),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
