import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/message_entity.dart';
import '../repositories/chat_repository.dart';

class GetChatHistoryUseCase {
  final ChatRepository repository;
  GetChatHistoryUseCase(this.repository);

  Future<Either<Failure, List<MessageEntity>>> call(String roomId) =>
      repository.getHistory(roomId);
}

class SendMessageParams {
  final String roomId;
  final String content;
  final String type;

  const SendMessageParams({
    required this.roomId,
    required this.content,
    this.type = 'text',
  });
}

class SendMessageUseCase {
  final ChatRepository repository;
  SendMessageUseCase(this.repository);

  Future<Either<Failure, MessageEntity>> call(SendMessageParams params) =>
      repository.sendMessage(
        roomId: params.roomId,
        content: params.content,
        type: params.type,
      );
}
