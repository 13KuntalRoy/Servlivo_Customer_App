import 'package:equatable/equatable.dart';

class VendorLocationEntity extends Equatable {
  final String bookingId;
  final double latitude;
  final double longitude;
  final double speed;
  final int etaSeconds;

  const VendorLocationEntity({
    required this.bookingId,
    required this.latitude,
    required this.longitude,
    required this.speed,
    required this.etaSeconds,
  });

  String get etaDisplay {
    final minutes = (etaSeconds / 60).round();
    if (minutes < 60) return '$minutes min';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '$h h' : '$h h $m min';
  }

  @override
  List<Object?> get props => [bookingId, latitude, longitude, etaSeconds];
}
