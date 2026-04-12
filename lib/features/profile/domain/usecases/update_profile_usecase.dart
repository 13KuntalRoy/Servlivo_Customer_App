import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileParams extends Equatable {
  final String? name;
  final String? phone;
  final String? avatarUrl;

  const UpdateProfileParams({this.name, this.phone, this.avatarUrl});

  @override
  List<Object?> get props => [name, phone, avatarUrl];
}

class UpdateProfileUseCase {
  final ProfileRepository _repository;
  UpdateProfileUseCase(this._repository);

  Future<Either<Failure, ProfileEntity>> call(UpdateProfileParams params) =>
      _repository.updateProfile(
        name: params.name,
        phone: params.phone,
        avatarUrl: params.avatarUrl,
      );
}
