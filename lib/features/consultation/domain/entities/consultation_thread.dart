import 'package:lexcore/shared/models/legal_models.dart';

class ConsultationThread {
  const ConsultationThread({
    required this.id,
    required this.title,
    required this.messages,
  });

  final String id;
  final String title;
  final List<ChatMessage> messages;

  ConsultationThread copyWith({
    String? id,
    String? title,
    List<ChatMessage>? messages,
  }) {
    return ConsultationThread(
      id: id ?? this.id,
      title: title ?? this.title,
      messages: messages ?? this.messages,
    );
  }
}
