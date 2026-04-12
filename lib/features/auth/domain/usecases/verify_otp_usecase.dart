import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class VerifyOtpParams extends Equatable {
  final String email;
  final String otp;

  const VerifyOtpParams({required this.email, required this.otp});

  @override
  List<Object> get props => [email, otp];
}

class VerifyOtpUseCase {
  final AuthRepository _repository;
  VerifyOtpUseCase(this._repository);

  Future<Either<Failure, UserEntity>> call(VerifyOtpParams params) {
    return _repository.verifyOtp(email: params.email, otp: params.otp);
  }
}
