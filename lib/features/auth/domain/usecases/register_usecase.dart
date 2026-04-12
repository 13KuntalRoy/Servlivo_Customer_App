import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class RegisterParams extends Equatable {
  final String email;
  final String password;
  final String phone;
  final String name;
  final String? referralCode;

  const RegisterParams({
    required this.email,
    required this.password,
    required this.phone,
    required this.name,
    this.referralCode,
  });

  @override
  List<Object?> get props => [email, password, phone, name, referralCode];
}

class RegisterUseCase {
  final AuthRepository _repository;
  RegisterUseCase(this._repository);

  Future<Either<Failure, void>> call(RegisterParams params) {
    return _repository.register(
      email: params.email,
      password: params.password,
      phone: params.phone,
      name: params.name,
      referralCode: params.referralCode,
    );
  }
}
