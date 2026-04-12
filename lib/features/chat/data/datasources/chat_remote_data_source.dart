import 'package:dio/dio.dart';

import '../../../../core/api/endpoints.dart';
import '../../../../core/error/exceptions.dart';

abstract class ChatRemoteDataSource {
  /// Fetches message history for a room via REST GET /chat/rooms/:id/messages
  Future<List<Map<String, dynamic>>> getHistory(String roomId);
  // Note: sending messages is done exclusively via WebSocket (ChatBloc / WsClient).
  // There is no REST POST endpoint for chat messages on the backend.
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final Dio dio;
  ChatRemoteDataSourceImpl(this.dio);

  @override
  Future<List<Map<String, dynamic>>> getHistory(String roomId) async {
    try {
      final response = await dio.get(Endpoints.chatMessages(roomId));
      final list = (response.data as List?) ?? [];
      return list.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = (data?['error']?['message'] ?? data?['message']) as String? ??
          e.message ?? 'Failed to load chat history';
      throw ServerException(message: message, statusCode: e.response?.statusCode);
    }
  }
}
