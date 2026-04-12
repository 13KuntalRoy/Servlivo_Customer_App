import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/profile_entity.dart';

abstract interface class ProfileRepository {
  Future<Either<Failure, ProfileEntity>> getProfile();
  Future<Either<Failure, ProfileEntity>> updateProfile({
    String? name,
    String? phone,
    String? avatarUrl,
  });
  Future<Either<Failure, String>> uploadAvatar(String filePath);
  Future<Either<Failure, void>> changePassword({
    required String oldPassword,
    required String newPassword,
  });
  Future<Either<Failure, void>> deleteAccount();
}
