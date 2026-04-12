import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class VerifyPhoneOtpParams extends Equatable {
  final String phone;
  final String otp;
  final String? name;

  const VerifyPhoneOtpParams({
    required this.phone,
    required this.otp,
    this.name,
  });

  @override
  List<Object?> get props => [phone, otp, name];
}

class VerifyPhoneOtpUseCase {
  final AuthRepository _repository;
  const VerifyPhoneOtpUseCase(this._repository);

  Future<Either<Failure, UserEntity>> call(VerifyPhoneOtpParams params) =>
      _repository.verifyPhoneOtp(
        phone: params.phone,
        otp: params.otp,
        name: params.name,
      );
}
