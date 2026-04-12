part of 'tracking_bloc.dart';

sealed class TrackingEvent extends Equatable {
  const TrackingEvent();

  @override
  List<Object?> get props => [];
}

class TrackingStarted extends TrackingEvent {
  final String bookingId;

  const TrackingStarted(this.bookingId);

  @override
  List<Object> get props => [bookingId];
}

class TrackingWsEventReceived extends TrackingEvent {
  final WsEvent wsEvent;

  const TrackingWsEventReceived(this.wsEvent);

  @override
  List<Object> get props => [wsEvent];
}

class TrackingStopped extends TrackingEvent {
  const TrackingStopped();
}
