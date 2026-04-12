import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/wallet_entity.dart';
import '../repositories/wallet_repository.dart';

class GetWalletBalanceUseCase {
  final WalletRepository repository;
  GetWalletBalanceUseCase(this.repository);

  Future<Either<Failure, WalletEntity>> call() => repository.getBalance();
}

class GetWalletTransactionsUseCase {
  final WalletRepository repository;
  GetWalletTransactionsUseCase(this.repository);

  Future<Either<Failure, List<WalletTransactionEntity>>> call() =>
      repository.getTransactions();
}
