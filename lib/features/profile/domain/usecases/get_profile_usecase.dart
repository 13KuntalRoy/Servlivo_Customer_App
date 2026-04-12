import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

class GetProfileUseCase {
  final ProfileRepository _repository;
  GetProfileUseCase(this._repository);

  Future<Either<Failure, ProfileEntity>> call() => _repository.getProfile();
}
