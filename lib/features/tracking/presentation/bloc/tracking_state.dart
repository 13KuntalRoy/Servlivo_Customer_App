part of 'tracking_bloc.dart';

sealed class TrackingState extends Equatable {
  const TrackingState();

  @override
  List<Object?> get props => [];
}

class TrackingInitial extends TrackingState {
  const TrackingInitial();
}

class TrackingConnecting extends TrackingState {
  const TrackingConnecting();
}

class TrackingConnected extends TrackingState {
  final VendorLocationEntity? location;

  const TrackingConnected({required this.location});

  @override
  List<Object?> get props => [location];
}

class TrackingDisconnected extends TrackingState {
  const TrackingDisconnected();
}

class TrackingError extends TrackingState {
  final String message;

  const TrackingError(this.message);

  @override
  List<Object> get props => [message];
}
