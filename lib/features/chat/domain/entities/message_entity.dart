import 'package:equatable/equatable.dart';

class MessageEntity extends Equatable {
  final String id;
  final String roomId;
  final String senderId;
  final String senderRole; // customer, vendor
  final String content;
  final String type; // text, image
  final DateTime sentAt;

  const MessageEntity({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.senderRole,
    required this.content,
    required this.type,
    required this.sentAt,
  });

  bool get isFromCustomer => senderRole == 'customer';

  @override
  List<Object> get props => [id, roomId, senderId, content, sentAt];
}
