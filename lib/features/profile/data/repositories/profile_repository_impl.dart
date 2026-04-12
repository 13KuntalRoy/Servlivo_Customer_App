import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remote;
  final NetworkInfo networkInfo;

  ProfileRepositoryImpl({required this.remote, required this.networkInfo});

  @override
  Future<Either<Failure, ProfileEntity>> getProfile() async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure('No internet'));
    try {
      final model = await remote.getProfile();
      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, ProfileEntity>> updateProfile({String? name, String? phone, String? avatarUrl}) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure('No internet'));
    try {
      final model = await remote.updateProfile(name: name, phone: phone, avatarUrl: avatarUrl);
      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, String>> uploadAvatar(String filePath) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure('No internet'));
    try {
      final url = await remote.uploadAvatar(filePath);
      return Right(url);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword({required String oldPassword, required String newPassword}) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure('No internet'));
    try {
      await remote.changePassword(oldPassword: oldPassword, newPassword: newPassword);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure('No internet'));
    try {
      await remote.deleteAccount();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
