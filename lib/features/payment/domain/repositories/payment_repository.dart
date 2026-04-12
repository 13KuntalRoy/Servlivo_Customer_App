import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/payment_entity.dart';

abstract class PaymentRepository {
  Future<Either<Failure, PaymentOrderEntity>> initiatePayment(String bookingId);
  Future<Either<Failure, PaymentEntity>> verifyPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  });
  Future<Either<Failure, List<PaymentEntity>>> getTransactions();
  Future<Either<Failure, PaymentEntity>> requestRefund(String paymentId);
}
