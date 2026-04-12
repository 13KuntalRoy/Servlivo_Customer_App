import '../../domain/entities/payment_entity.dart';

class PaymentModel extends PaymentEntity {
  const PaymentModel({
    required super.id,
    required super.bookingId,
    required super.amount,
    required super.currency,
    required super.status,
    required super.method,
    super.razorpayOrderId,
    super.razorpayPaymentId,
    required super.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) => PaymentModel(
        id: json['id'] as String,
        bookingId: json['booking_id'] as String,
        amount: (json['amount'] as num?)?.toDouble() ?? 0,
        currency: json['currency'] as String? ?? 'INR',
        status: json['status'] as String,
        method: json['method'] as String? ?? 'razorpay',
        razorpayOrderId: json['razorpay_order_id'] as String?,
        razorpayPaymentId: json['razorpay_payment_id'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}

class PaymentOrderModel extends PaymentOrderEntity {
  const PaymentOrderModel({
    required super.orderId,
    required super.keyId,
    required super.amount,
    required super.currency,
    required super.bookingId,
  });

  factory PaymentOrderModel.fromJson(Map<String, dynamic> json) =>
      PaymentOrderModel(
        orderId: json['order_id'] as String,
        keyId: json['key_id'] as String,
        amount: (json['amount'] as num?)?.toDouble() ?? 0,
        currency: json['currency'] as String? ?? 'INR',
        bookingId: json['booking_id'] as String,
      );
}
