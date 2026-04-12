import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  final SecureStorageService storage;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remote,
    required this.storage,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, void>> register({
    required String email,
    required String password,
    required String phone,
    required String name,
    String? referralCode,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }
    try {
      await remote.register(
        email: email,
        password: password,
        phone: phone,
        name: name,
        referralCode: referralCode,
      );
      return const Right(null);
    } on UnauthorizedException {
      return const Left(AuthFailure('Registration failed'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }
    try {
      final data = await remote.verifyOtp(email: email, otp: otp);
      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      await storage.saveTokens(
        accessToken: data['access_token'] as String,
        refreshToken: data['refresh_token'] as String,
      );
      await storage.write(
        key: SecureStorageServiceImpl.kUserId,
        value: user.id,
      );
      return Right(user.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> resendOtp({required String email}) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }
    try {
      await remote.resendOtp(email: email);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }
    try {
      final data = await remote.login(email: email, password: password);
      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      await storage.saveTokens(
        accessToken: data['access_token'] as String,
        refreshToken: data['refresh_token'] as String,
      );
      await storage.write(
        key: SecureStorageServiceImpl.kUserId,
        value: user.id,
      );
      return Right(user.toEntity());
    } on UnauthorizedException {
      return const Left(AuthFailure('Invalid email or password'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remote.logout();
    } catch (_) {
      // Ignore logout API errors — always clear local tokens
    }
    await storage.clearTokens();
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> forgotPassword({required String email}) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }
    try {
      await remote.forgotPassword(email: email);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }
    try {
      await remote.resetPassword(
        email: email,
        otp: otp,
        newPassword: newPassword,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> isLoggedIn() async {
    final hasToken = await storage.hasAccessToken;
    return Right(hasToken);
  }

  @override
  Future<Either<Failure, void>> sendPhoneOtp({required String phone}) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }
    try {
      await remote.sendPhoneOtp(phone: phone);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> verifyPhoneOtp({
    required String phone,
    required String otp,
    String? name,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }
    try {
      final data = await remote.verifyPhoneOtp(phone: phone, otp: otp, name: name);
      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      await storage.saveTokens(
        accessToken: data['access_token'] as String,
        refreshToken: data['refresh_token'] as String,
      );
      await storage.write(
        key: SecureStorageServiceImpl.kUserId,
        value: user.id,
      );
      return Right(user.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
