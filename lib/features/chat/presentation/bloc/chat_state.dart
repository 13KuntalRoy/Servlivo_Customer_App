part of 'chat_bloc.dart';

sealed class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {
  const ChatInitial();
}

class ChatLoading extends ChatState {
  const ChatLoading();
}

class ChatLoaded extends ChatState {
  final List<MessageEntity> messages;
  final bool isConnected;

  const ChatLoaded({required this.messages, required this.isConnected});

  ChatLoaded copyWith({
    List<MessageEntity>? messages,
    bool? isConnected,
  }) =>
      ChatLoaded(
        messages: messages ?? this.messages,
        isConnected: isConnected ?? this.isConnected,
      );

  @override
  List<Object> get props => [messages, isConnected];
}

class ChatError extends ChatState {
  final String message;
  const ChatError(this.message);

  @override
  List<Object> get props => [message];
}
