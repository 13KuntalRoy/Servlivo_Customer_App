import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/profile_repository.dart';

class UploadAvatarUseCase {
  final ProfileRepository _repository;
  UploadAvatarUseCase(this._repository);

  Future<Either<Failure, String>> call(String filePath) =>
      _repository.uploadAvatar(filePath);
}
