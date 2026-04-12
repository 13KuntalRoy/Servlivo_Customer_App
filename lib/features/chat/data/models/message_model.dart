import '../../domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    required super.roomId,
    required super.senderId,
    required super.senderRole,
    required super.content,
    required super.type,
    required super.sentAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
        id: json['id'] as String,
        roomId: json['room_id'] as String,
        senderId: json['sender_id'] as String,
        senderRole: json['sender_role'] as String? ?? 'customer',
        content: json['content'] as String,
        type: json['type'] as String? ?? 'text',
        sentAt: DateTime.parse(json['sent_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'room_id': roomId,
        'sender_id': senderId,
        'sender_role': senderRole,
        'content': content,
        'type': type,
        'sent_at': sentAt.toIso8601String(),
      };
}
