import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/api/endpoints.dart';
import '../../../../core/websocket/ws_client.dart';
import '../../../../core/websocket/ws_event.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/usecases/chat_usecases.dart' show GetChatHistoryUseCase;

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final WsClient _wsClient;
  final GetChatHistoryUseCase _getHistory;
  StreamSubscription<WsEvent>? _wsSub;
  String? _currentRoomId;

  ChatBloc({
    required WsClient wsClient,
    required GetChatHistoryUseCase getHistory,
  })  : _wsClient = wsClient,
        _getHistory = getHistory,
        super(const ChatInitial()) {
    on<ChatRoomOpened>(_onRoomOpened);
    on<ChatWsEventReceived>(_onWsEvent);
    on<ChatMessageSent>(_onMessageSent);
    on<ChatRoomClosed>(_onRoomClosed);
  }

  Future<void> _onRoomOpened(ChatRoomOpened event, Emitter<ChatState> emit) async {
    _currentRoomId = event.roomId;
    emit(const ChatLoading());

    // Load history
    final result = await _getHistory(event.roomId);
    final messages = result.fold((_) => <MessageEntity>[], (msgs) => msgs);

    emit(ChatLoaded(messages: messages, isConnected: false));

    // Connect WebSocket
    final stream = _wsClient.connect(Endpoints.chatWs(event.roomId));
    _wsSub = stream.listen((wsEvent) => add(ChatWsEventReceived(wsEvent)));
  }

  void _onWsEvent(ChatWsEventReceived event, Emitter<ChatState> emit) {
    final current = state;
    switch (event.wsEvent) {
      case WsConnected():
        if (current is ChatLoaded) {
          emit(current.copyWith(isConnected: true));
        }
      case WsDisconnected():
        if (current is ChatLoaded) {
          emit(current.copyWith(isConnected: false));
        }
      case WsError(:final error):
        emit(ChatError(error.toString()));
      case WsMessage(:final data):
        if (current is ChatLoaded) {
          final msg = MessageEntity(
            id: data['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
            roomId: data['room_id'] as String? ?? _currentRoomId ?? '',
            senderId: data['sender_id'] as String? ?? '',
            senderRole: data['sender_role'] as String? ?? 'vendor',
            content: data['content'] as String? ?? '',
            type: data['type'] as String? ?? 'text',
            sentAt: data['sent_at'] != null
                ? DateTime.parse(data['sent_at'] as String)
                : DateTime.now(),
          );
          emit(current.copyWith(messages: [...current.messages, msg]));
        }
    }
  }

  Future<void> _onMessageSent(ChatMessageSent event, Emitter<ChatState> emit) async {
    if (_currentRoomId == null) return;
    final current = state;
    if (current is! ChatLoaded) return;

    // Optimistic: add immediately
    final optimistic = MessageEntity(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      roomId: _currentRoomId!,
      senderId: '',
      senderRole: 'customer',
      content: event.content,
      type: 'text',
      sentAt: DateTime.now(),
    );
    emit(current.copyWith(messages: [...current.messages, optimistic]));

    // Send via WebSocket — the only supported channel
    if (current.isConnected) {
      _wsClient.send({'type': 'message', 'content': event.content, 'room_id': _currentRoomId});
    }
  }

  void _onRoomClosed(ChatRoomClosed event, Emitter<ChatState> emit) {
    _wsSub?.cancel();
    _wsClient.disconnect();
    _currentRoomId = null;
    emit(const ChatInitial());
  }

  @override
  Future<void> close() {
    _wsSub?.cancel();
    _wsClient.disconnect();
    return super.close();
  }
}
