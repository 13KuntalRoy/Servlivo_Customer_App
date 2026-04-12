import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/cancel_booking_usecase.dart';
import '../../domain/usecases/create_booking_usecase.dart';
import '../../domain/usecases/get_booking_detail_usecase.dart';
import '../../domain/usecases/get_bookings_usecase.dart';
import '../../domain/usecases/reschedule_booking_usecase.dart';
import 'booking_event.dart';
import 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final CreateBookingUseCase _createBooking;
  final GetBookingsUseCase _getBookings;
  final GetBookingDetailUseCase _getBookingDetail;
  final CancelBookingUseCase _cancelBooking;
  final RescheduleBookingUseCase _rescheduleBooking;

  BookingBloc({
    required CreateBookingUseCase createBooking,
    required GetBookingsUseCase getBookings,
    required GetBookingDetailUseCase getBookingDetail,
    required CancelBookingUseCase cancelBooking,
    required RescheduleBookingUseCase rescheduleBooking,
  })  : _createBooking = createBooking,
        _getBookings = getBookings,
        _getBookingDetail = getBookingDetail,
        _cancelBooking = cancelBooking,
        _rescheduleBooking = rescheduleBooking,
        super(const BookingInitial()) {
    on<BookingsLoadRequested>(_onLoadBookings);
    on<BookingDetailRequested>(_onLoadDetail);
    on<BookingCreateRequested>(_onCreateBooking);
    on<BookingCancelRequested>(_onCancelBooking);
    on<BookingRescheduleRequested>(_onRescheduleBooking);
  }

  Future<void> _onLoadBookings(
    BookingsLoadRequested event,
    Emitter<BookingState> emit,
  ) async {
    emit(const BookingLoading());
    final result = await _getBookings(status: event.statusFilter);
    result.fold(
      (f) => emit(BookingError(f.message)),
      (bookings) => emit(BookingsLoaded(bookings)),
    );
  }

  Future<void> _onLoadDetail(
    BookingDetailRequested event,
    Emitter<BookingState> emit,
  ) async {
    emit(const BookingLoading());
    final result = await _getBookingDetail(event.bookingId);
    result.fold(
      (f) => emit(BookingError(f.message)),
      (booking) => emit(BookingDetailLoaded(booking)),
    );
  }

  Future<void> _onCreateBooking(
    BookingCreateRequested event,
    Emitter<BookingState> emit,
  ) async {
    emit(const BookingLoading());
    final result = await _createBooking(
      CreateBookingParams(
        serviceId: event.serviceId,
        addressId: event.addressId,
        scheduledAt: event.scheduledAt,
        amount: event.amount,
        notes: event.notes,
        couponCode: event.couponCode,
      ),
    );
    result.fold(
      (f) => emit(BookingError(f.message)),
      (booking) => emit(BookingCreated(booking)),
    );
  }

  Future<void> _onCancelBooking(
    BookingCancelRequested event,
    Emitter<BookingState> emit,
  ) async {
    emit(const BookingLoading());
    final result = await _cancelBooking(
      CancelBookingParams(id: event.bookingId, reason: event.reason),
    );
    result.fold(
      (f) => emit(BookingError(f.message)),
      (_) => emit(BookingCancelled(event.bookingId)),
    );
  }

  Future<void> _onRescheduleBooking(
    BookingRescheduleRequested event,
    Emitter<BookingState> emit,
  ) async {
    emit(const BookingLoading());
    final result = await _rescheduleBooking(
      RescheduleParams(id: event.bookingId, newTime: event.newTime),
    );
    result.fold(
      (f) => emit(BookingError(f.message)),
      (_) => emit(const BookingRescheduled()),
    );
  }
}
