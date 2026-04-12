part of 'payment_bloc.dart';

sealed class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object> get props => [];
}

class PaymentInitiated extends PaymentEvent {
  final String bookingId;
  const PaymentInitiated(this.bookingId);

  @override
  List<Object> get props => [bookingId];
}

class PaymentSucceeded extends PaymentEvent {
  final String orderId;
  final String paymentId;
  final String signature;

  const PaymentSucceeded({
    required this.orderId,
    required this.paymentId,
    required this.signature,
  });

  @override
  List<Object> get props => [orderId, paymentId, signature];
}

class PaymentFailed extends PaymentEvent {
  final String reason;
  const PaymentFailed(this.reason);

  @override
  List<Object> get props => [reason];
}

class TransactionsLoaded extends PaymentEvent {
  const TransactionsLoaded();
}
