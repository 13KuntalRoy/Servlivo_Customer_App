import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, void>> register({
    required String email,
    required String password,
    required String phone,
    required String name,
    String? referralCode,
  });

  Future<Either<Failure, UserEntity>> verifyOtp({
    required String email,
    required String otp,
  });

  Future<Either<Failure, void>> resendOtp({required String email});

  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, void>> forgotPassword({required String email});

  Future<Either<Failure, void>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  });

  Future<Either<Failure, bool>> isLoggedIn();

  Future<Either<Failure, void>> sendPhoneOtp({required String phone});

  Future<Either<Failure, UserEntity>> verifyPhoneOtp({
    required String phone,
    required String otp,
    String? name,
  });
}
