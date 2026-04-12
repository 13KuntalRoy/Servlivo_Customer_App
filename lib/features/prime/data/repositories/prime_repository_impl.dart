import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/prime_entity.dart';
import '../../domain/repositories/prime_repository.dart';
import '../datasources/prime_remote_data_source.dart';
import '../models/prime_model.dart';

class PrimeRepositoryImpl implements PrimeRepository {
  final PrimeRemoteDataSource remote;
  final NetworkInfo networkInfo;

  PrimeRepositoryImpl({required this.remote, required this.networkInfo});

  @override
  Future<Either<Failure, List<PrimePlanEntity>>> getPlans() async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure('No internet'));
    try {
      final list = await remote.getPlans();
      return Right(list.map(PrimePlanModel.fromJson).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, PrimeMembershipEntity>> subscribe(String planId) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure('No internet'));
    try {
      final data = await remote.subscribe(planId);
      return Right(PrimeMembershipModel.fromJson(data));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, PrimeMembershipEntity?>> getMembership() async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure('No internet'));
    try {
      final data = await remote.getMembership();
      return Right(data != null ? PrimeMembershipModel.fromJson(data) : null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
