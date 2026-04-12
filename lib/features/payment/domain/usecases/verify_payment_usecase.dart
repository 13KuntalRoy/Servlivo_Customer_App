import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/payment_entity.dart';
import '../repositories/payment_repository.dart';

class VerifyPaymentParams {
  final String razorpayOrderId;
  final String razorpayPaymentId;
  final String razorpaySignature;

  const VerifyPaymentParams({
    required this.razorpayOrderId,
    required this.razorpayPaymentId,
    required this.razorpaySignature,
  });
}

class VerifyPaymentUseCase {
  final PaymentRepository repository;
  VerifyPaymentUseCase(this.repository);

  Future<Either<Failure, PaymentEntity>> call(VerifyPaymentParams params) =>
      repository.verifyPayment(
        razorpayOrderId: params.razorpayOrderId,
        razorpayPaymentId: params.razorpayPaymentId,
        razorpaySignature: params.razorpaySignature,
      );
}
