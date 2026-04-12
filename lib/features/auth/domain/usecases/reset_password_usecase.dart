import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class ResetPasswordParams extends Equatable {
  final String email;
  final String otp;
  final String newPassword;

  const ResetPasswordParams({
    required this.email,
    required this.otp,
    required this.newPassword,
  });

  @override
  List<Object> get props => [email, otp, newPassword];
}

class ResetPasswordUseCase {
  final AuthRepository _repository;
  ResetPasswordUseCase(this._repository);

  Future<Either<Failure, void>> call(ResetPasswordParams params) {
    return _repository.resetPassword(
      email: params.email,
      otp: params.otp,
      newPassword: params.newPassword,
    );
  }
}
