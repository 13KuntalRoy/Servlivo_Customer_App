import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/subscription_entity.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../datasources/subscription_remote_data_source.dart';
import '../models/subscription_model.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SubscriptionRemoteDataSource remote;
  final NetworkInfo networkInfo;

  SubscriptionRepositoryImpl({required this.remote, required this.networkInfo});

  @override
  Future<Either<Failure, List<SubscriptionEntity>>> getSubscriptions() async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure('No internet'));
    try {
      final list = await remote.getSubscriptions();
      return Right(list.map(SubscriptionModel.fromJson).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, SubscriptionEntity>> createSubscription({
    required String serviceId,
    required String frequency,
    required String addressId,
  }) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure('No internet'));
    try {
      final data = await remote.createSubscription({
        'service_id': serviceId,
        'frequency': frequency,
        'address_id': addressId,
      });
      return Right(SubscriptionModel.fromJson(data));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, SubscriptionEntity>> pauseSubscription(String id) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure('No internet'));
    try {
      final data = await remote.pauseSubscription(id);
      return Right(SubscriptionModel.fromJson(data));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, SubscriptionEntity>> resumeSubscription(String id) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure('No internet'));
    try {
      final data = await remote.resumeSubscription(id);
      return Right(SubscriptionModel.fromJson(data));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> cancelSubscription(String id) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure('No internet'));
    try {
      await remote.cancelSubscription(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
