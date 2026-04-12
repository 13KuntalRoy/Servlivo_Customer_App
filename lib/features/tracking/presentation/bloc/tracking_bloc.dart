import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/api/endpoints.dart';
import '../../../../core/websocket/ws_client.dart';
import '../../../../core/websocket/ws_event.dart';
import '../../domain/entities/tracking_entity.dart';


part 'tracking_event.dart';
part 'tracking_state.dart';

class TrackingBloc extends Bloc<TrackingEvent, TrackingState> {
  final WsClient _wsClient;
  StreamSubscription<WsEvent>? _wsSub;

  TrackingBloc({required WsClient wsClient})
      : _wsClient = wsClient,
        super(const TrackingInitial()) {
    on<TrackingStarted>(_onStarted);
    on<TrackingWsEventReceived>(_onWsEvent);
    on<TrackingStopped>(_onStopped);
  }

  Future<void> _onStarted(TrackingStarted event, Emitter<TrackingState> emit) async {
    emit(const TrackingConnecting());
    final stream = _wsClient.connect(Endpoints.trackingWs(event.bookingId));
    _wsSub = stream.listen(
      (wsEvent) => add(TrackingWsEventReceived(wsEvent)),
    );
  }

  void _onWsEvent(TrackingWsEventReceived event, Emitter<TrackingState> emit) {
    final wsEvent = event.wsEvent;
    switch (wsEvent) {
      case WsConnected():
        emit(const TrackingConnected(location: null));
      case WsDisconnected():
        emit(const TrackingDisconnected());
      case WsError():
        emit(TrackingError(wsEvent.error.toString()));
      case WsMessage():
        final data = wsEvent.data;
        final location = VendorLocationEntity(
          bookingId: data['booking_id'] as String? ?? '',
          latitude: (data['latitude'] as num?)?.toDouble() ?? 0,
          longitude: (data['longitude'] as num?)?.toDouble() ?? 0,
          speed: (data['speed'] as num?)?.toDouble() ?? 0,
          etaSeconds: data['eta'] as int? ?? 0,
        );
        emit(TrackingConnected(location: location));
    }
  }

  void _onStopped(TrackingStopped event, Emitter<TrackingState> emit) {
    _wsSub?.cancel();
    _wsClient.disconnect();
    emit(const TrackingDisconnected());
  }

  @override
  Future<void> close() {
    _wsSub?.cancel();
    _wsClient.disconnect();
    return super.close();
  }
}
