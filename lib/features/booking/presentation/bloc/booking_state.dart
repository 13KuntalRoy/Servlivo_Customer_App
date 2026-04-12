import 'package:equatable/equatable.dart';

import '../../domain/entities/booking_entity.dart';

sealed class BookingState extends Equatable {
  const BookingState();

  @override
  List<Object?> get props => [];
}

class BookingInitial extends BookingState {
  const BookingInitial();
}

class BookingLoading extends BookingState {
  const BookingLoading();
}

class BookingsLoaded extends BookingState {
  final List<BookingEntity> bookings;

  const BookingsLoaded(this.bookings);

  @override
  List<Object> get props => [bookings];
}

class BookingDetailLoaded extends BookingState {
  final BookingEntity booking;

  const BookingDetailLoaded(this.booking);

  @override
  List<Object> get props => [booking];
}

class BookingCreated extends BookingState {
  final BookingEntity booking;

  const BookingCreated(this.booking);

  @override
  List<Object> get props => [booking];
}

class BookingCancelled extends BookingState {
  final String bookingId;

  const BookingCancelled(this.bookingId);

  @override
  List<Object> get props => [bookingId];
}

class BookingRescheduled extends BookingState {
  const BookingRescheduled();
}

class BookingError extends BookingState {
  final String message;

  const BookingError(this.message);

  @override
  List<Object> get props => [message];
}
