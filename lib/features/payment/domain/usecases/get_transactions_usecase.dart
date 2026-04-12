import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/payment_entity.dart';
import '../repositories/payment_repository.dart';

class GetTransactionsUseCase {
  final PaymentRepository repository;
  GetTransactionsUseCase(this.repository);

  Future<Either<Failure, List<PaymentEntity>>> call() =>
      repository.getTransactions();
}
