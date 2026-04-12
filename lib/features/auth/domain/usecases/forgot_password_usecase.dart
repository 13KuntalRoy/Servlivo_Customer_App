import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class ForgotPasswordUseCase {
  final AuthRepository _repository;
  ForgotPasswordUseCase(this._repository);

  Future<Either<Failure, void>> call(String email) {
    return _repository.forgotPassword(email: email);
  }
}
