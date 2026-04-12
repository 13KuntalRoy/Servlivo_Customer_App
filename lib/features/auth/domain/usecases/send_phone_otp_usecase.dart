import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class SendPhoneOtpUseCase {
  final AuthRepository _repository;
  const SendPhoneOtpUseCase(this._repository);

  Future<Either<Failure, void>> call(String phone) =>
      _repository.sendPhoneOtp(phone: phone);
}
