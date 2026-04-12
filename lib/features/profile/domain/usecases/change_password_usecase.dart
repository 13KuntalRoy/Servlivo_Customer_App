import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../repositories/profile_repository.dart';

class ChangePasswordParams extends Equatable {
  final String oldPassword;
  final String newPassword;

  const ChangePasswordParams({required this.oldPassword, required this.newPassword});

  @override
  List<Object> get props => [oldPassword, newPassword];
}

class ChangePasswordUseCase {
  final ProfileRepository _repository;
  ChangePasswordUseCase(this._repository);

  Future<Either<Failure, void>> call(ChangePasswordParams params) =>
      _repository.changePassword(
        oldPassword: params.oldPassword,
        newPassword: params.newPassword,
      );
}
