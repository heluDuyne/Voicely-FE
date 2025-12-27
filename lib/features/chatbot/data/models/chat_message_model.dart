import '../../domain/entities/chat_message.dart';
import '../../domain/entities/audio_reference.dart';
import '../../domain/entities/note_reference.dart';
import 'audio_reference_model.dart';
import 'note_reference_model.dart';

class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    required super.messageId,
    required super.role,
    required super.content,
    super.intent,
    super.audioReferences,
    super.noteReferences,
    super.suggestedQuestions,
    required super.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    final audioReferences = _parseAudioReferences(json['audio_references']);
    final noteReferences = _parseNoteReferences(json['note_references']);
    final suggestions = _parseSuggestions(json['suggested_questions']);

    final roleValue = json['role']?.toString();

    return ChatMessageModel(
      messageId: json['message_id']?.toString() ?? '',
      role: roleValue?.toLowerCase() ?? 'assistant',
      content: json['content']?.toString() ?? '',
      intent: json['intent']?.toString(),
      audioReferences: audioReferences,
      noteReferences: noteReferences,
      suggestedQuestions: suggestions,
      createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
    );
  }

  factory ChatMessageModel.fromJobResult(Map<String, dynamic> result) {
    return ChatMessageModel(
      messageId: result['message_id']?.toString() ?? '',
      role: 'assistant',
      content: result['response']?.toString() ?? '',
      intent: result['intent']?.toString(),
      audioReferences: _parseAudioReferences(result['audio_references']),
      noteReferences: _parseNoteReferences(result['note_references']),
      suggestedQuestions: _parseSuggestions(result['suggested_questions']),
      createdAt: DateTime.now(),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is String) {
      return DateTime.tryParse(value);
    }
    if (value is DateTime) {
      return value;
    }
    return null;
  }

  static List<AudioReference>? _parseAudioReferences(dynamic value) {
    if (value is! List) {
      return null;
    }
    return value
        .map(
          (item) =>
              AudioReferenceModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  static List<NoteReference>? _parseNoteReferences(dynamic value) {
    if (value is! List) {
      return null;
    }
    return value
        .map(
          (item) => NoteReferenceModel.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  static List<String>? _parseSuggestions(dynamic value) {
    if (value is! List) {
      return null;
    }
    return value.map((item) => item.toString()).toList();
  }
}
