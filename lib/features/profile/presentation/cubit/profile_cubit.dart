import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/entities/profile_entity.dart';
import '../../domain/usecases/change_password_usecase.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/usecases/upload_avatar_usecase.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final GetProfileUseCase _getProfile;
  final UpdateProfileUseCase _updateProfile;
  final UploadAvatarUseCase _uploadAvatar;
  final ChangePasswordUseCase _changePassword;

  ProfileCubit({
    required GetProfileUseCase getProfile,
    required UpdateProfileUseCase updateProfile,
    required UploadAvatarUseCase uploadAvatar,
    required ChangePasswordUseCase changePassword,
  })  : _getProfile = getProfile,
        _updateProfile = updateProfile,
        _uploadAvatar = uploadAvatar,
        _changePassword = changePassword,
        super(const ProfileInitial());

  Future<void> loadProfile() async {
    emit(const ProfileLoading());
    final result = await _getProfile();
    result.fold(
      (f) => emit(ProfileError(f.message)),
      (profile) => emit(ProfileLoaded(profile)),
    );
  }

  Future<void> updateProfile({String? name, String? phone}) async {
    emit(const ProfileUpdating());
    final result = await _updateProfile(
      UpdateProfileParams(name: name, phone: phone),
    );
    result.fold(
      (f) => emit(ProfileError(f.message)),
      (profile) => emit(ProfileLoaded(profile)),
    );
  }

  Future<void> pickAndUploadAvatar() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      imageQuality: 80,
    );
    if (file == null) return;

    emit(const ProfileUpdating());
    final uploadResult = await _uploadAvatar(file.path);
    await uploadResult.fold(
      (f) async => emit(ProfileError(f.message)),
      (avatarUrl) async {
        final updateResult = await _updateProfile(
          UpdateProfileParams(avatarUrl: avatarUrl),
        );
        updateResult.fold(
          (f) => emit(ProfileError(f.message)),
          (profile) => emit(ProfileLoaded(profile)),
        );
      },
    );
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    emit(const ProfileLoading());
    final result = await _changePassword(
      ChangePasswordParams(oldPassword: oldPassword, newPassword: newPassword),
    );
    result.fold(
      (f) => emit(ProfileError(f.message)),
      (_) => emit(const ProfilePasswordChanged()),
    );
  }
}
