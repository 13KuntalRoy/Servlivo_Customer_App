import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/wallet_entity.dart';

abstract class WalletRepository {
  Future<Either<Failure, WalletEntity>> getBalance();
  Future<Either<Failure, List<WalletTransactionEntity>>> getTransactions();
}
