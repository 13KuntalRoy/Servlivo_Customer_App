import 'package:equatable/equatable.dart';

sealed class WsEvent extends Equatable {
  const WsEvent();

  @override
  List<Object?> get props => [];
}

class WsConnected extends WsEvent {
  const WsConnected();
}

class WsDisconnected extends WsEvent {
  const WsDisconnected();
}

class WsError extends WsEvent {
  final Object error;
  const WsError(this.error);

  @override
  List<Object?> get props => [error];
}

class WsMessage extends WsEvent {
  final Map<String, dynamic> data;
  const WsMessage(this.data);

  @override
  List<Object?> get props => [data];
}
