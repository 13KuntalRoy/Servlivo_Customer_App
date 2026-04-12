import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/wallet_entity.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../datasources/wallet_remote_data_source.dart';
import '../models/wallet_model.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDataSource remote;
  final NetworkInfo networkInfo;

  WalletRepositoryImpl({required this.remote, required this.networkInfo});

  @override
  Future<Either<Failure, WalletEntity>> getBalance() async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure('No internet'));
    try {
      final data = await remote.getBalance();
      return Right(WalletModel.fromJson(data));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<WalletTransactionEntity>>> getTransactions() async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure('No internet'));
    try {
      final list = await remote.getTransactions();
      return Right(list.map(WalletTransactionModel.fromJson).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
