import 'package:equatable/equatable.dart';

sealed class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object?> get props => [];
}

class BookingsLoadRequested extends BookingEvent {
  final String? statusFilter;

  const BookingsLoadRequested({this.statusFilter});

  @override
  List<Object?> get props => [statusFilter];
}

class BookingDetailRequested extends BookingEvent {
  final String bookingId;

  const BookingDetailRequested(this.bookingId);

  @override
  List<Object> get props => [bookingId];
}

class BookingCreateRequested extends BookingEvent {
  final String serviceId;
  final String addressId;
  final DateTime scheduledAt;
  final double amount;
  final String? notes;
  final String? couponCode;

  const BookingCreateRequested({
    required this.serviceId,
    required this.addressId,
    required this.scheduledAt,
    required this.amount,
    this.notes,
    this.couponCode,
  });

  @override
  List<Object?> get props => [serviceId, addressId, scheduledAt, amount];
}

class BookingCancelRequested extends BookingEvent {
  final String bookingId;
  final String reason;

  const BookingCancelRequested({required this.bookingId, required this.reason});

  @override
  List<Object> get props => [bookingId, reason];
}

class BookingRescheduleRequested extends BookingEvent {
  final String bookingId;
  final DateTime newTime;

  const BookingRescheduleRequested({required this.bookingId, required this.newTime});

  @override
  List<Object> get props => [bookingId, newTime];
}
