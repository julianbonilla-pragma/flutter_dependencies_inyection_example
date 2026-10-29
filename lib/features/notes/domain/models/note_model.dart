import '../entities/note.dart';

class NoteModel {
  final String id;
  final String text;

  NoteModel({required this.id, required this.text});

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(id: json['id'] as String, text: json['text'] as String);
  }

  Map<String, dynamic> toJson() => {'id': id, 'text': text};

  factory NoteModel.fromEntity(Note note) {
    return NoteModel(id: note.id, text: note.text);
  }

  Note toEntity() => Note(id: id, text: text);
}
