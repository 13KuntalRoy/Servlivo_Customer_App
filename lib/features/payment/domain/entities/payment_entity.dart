import 'package:equatable/equatable.dart';

class PaymentEntity extends Equatable {
  final String id;
  final String bookingId;
  final double amount;
  final String currency;
  final String status; // pending, completed, failed, refunded
  final String method; // razorpay, wallet, cash
  final String? razorpayOrderId;
  final String? razorpayPaymentId;
  final DateTime createdAt;

  const PaymentEntity({
    required this.id,
    required this.bookingId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.method,
    this.razorpayOrderId,
    this.razorpayPaymentId,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, bookingId, amount, status];
}

class PaymentOrderEntity extends Equatable {
  final String orderId;
  final String keyId;
  final double amount;
  final String currency;
  final String bookingId;

  const PaymentOrderEntity({
    required this.orderId,
    required this.keyId,
    required this.amount,
    required this.currency,
    required this.bookingId,
  });

  @override
  List<Object> get props => [orderId, bookingId];
}
