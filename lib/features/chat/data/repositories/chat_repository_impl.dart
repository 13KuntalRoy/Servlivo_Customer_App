import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_data_source.dart';
import '../models/message_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remote;
  final NetworkInfo networkInfo;

  ChatRepositoryImpl({required this.remote, required this.networkInfo});

  @override
  Future<Either<Failure, List<MessageEntity>>> getHistory(String roomId) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure('No internet'));
    try {
      final list = await remote.getHistory(roomId);
      return Right(list.map(MessageModel.fromJson).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, MessageEntity>> sendMessage({
    required String roomId,
    required String content,
    required String type,
  }) async {
    // Chat messages are sent exclusively via WebSocket.
    // This path is only reached when WebSocket is disconnected.
    return const Left(ServerFailure('Not connected — reconnect to send messages'));
  }
}
