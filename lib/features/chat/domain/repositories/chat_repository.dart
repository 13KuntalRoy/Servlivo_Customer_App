import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/message_entity.dart';

abstract class ChatRepository {
  Future<Either<Failure, List<MessageEntity>>> getHistory(String roomId);
  Future<Either<Failure, MessageEntity>> sendMessage({
    required String roomId,
    required String content,
    required String type,
  });
}
