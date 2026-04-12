import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/payment_entity.dart';
import '../repositories/payment_repository.dart';

class InitiatePaymentUseCase {
  final PaymentRepository repository;
  InitiatePaymentUseCase(this.repository);

  Future<Either<Failure, PaymentOrderEntity>> call(String bookingId) =>
      repository.initiatePayment(bookingId);
}
