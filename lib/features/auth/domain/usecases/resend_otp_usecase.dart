import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class ResendOtpUseCase {
  final AuthRepository _repository;
  ResendOtpUseCase(this._repository);

  Future<Either<Failure, void>> call(String email) {
    return _repository.resendOtp(email: email);
  }
}
