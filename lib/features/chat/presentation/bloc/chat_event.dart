part of 'chat_bloc.dart';

sealed class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class ChatRoomOpened extends ChatEvent {
  final String roomId;
  const ChatRoomOpened(this.roomId);

  @override
  List<Object> get props => [roomId];
}

class ChatWsEventReceived extends ChatEvent {
  final WsEvent wsEvent;
  const ChatWsEventReceived(this.wsEvent);

  @override
  List<Object> get props => [wsEvent];
}

class ChatMessageSent extends ChatEvent {
  final String content;
  const ChatMessageSent(this.content);

  @override
  List<Object> get props => [content];
}

class ChatRoomClosed extends ChatEvent {
  const ChatRoomClosed();
}
