import 'package:dio/dio.dart';

import '../../../../core/api/endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../models/profile_model.dart';

abstract interface class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile();
  Future<ProfileModel> updateProfile({String? name, String? phone, String? avatarUrl});
  Future<String> uploadAvatar(String filePath);
  Future<void> changePassword({required String oldPassword, required String newPassword});
  Future<void> deleteAccount();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio _dio;
  ProfileRemoteDataSourceImpl(this._dio);

  @override
  Future<ProfileModel> getProfile() async {
    try {
      final response = await _dio.get(Endpoints.profile);
      return ProfileModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  @override
  Future<ProfileModel> updateProfile({String? name, String? phone, String? avatarUrl}) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (phone != null) data['phone'] = phone;
      if (avatarUrl != null) data['avatar_url'] = avatarUrl;
      final response = await _dio.patch(Endpoints.profile, data: data);
      return ProfileModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  @override
  Future<String> uploadAvatar(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });
      final response = await _dio.post(Endpoints.avatar, data: formData);
      return response.data['avatar_url'] as String;
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  @override
  Future<void> changePassword({required String oldPassword, required String newPassword}) async {
    try {
      await _dio.put(Endpoints.password, data: {
        'old_password': oldPassword,
        'new_password': newPassword,
      });
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      await _dio.delete(Endpoints.deleteAccount);
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  Never _handleError(DioException e) {
    final data = e.response?.data;
    final message = (data?['error']?['message'] ?? data?['message']) as String? ??
        e.message ?? 'Error';
    throw ServerException(message: message, statusCode: e.response?.statusCode);
  }
}
