import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class SecureStorageService {
  Future<void> write({required String key, required String value});
  Future<String?> read({required String key});
  Future<void> delete({required String key});
  Future<void> deleteAll();
  Future<bool> containsKey({required String key});

  Future<bool> get hasAccessToken;
  Future<void> saveTokens({required String accessToken, required String refreshToken});
  Future<void> clearTokens();
}

class SecureStorageServiceImpl implements SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  // Storage key constants
  static const kAccessToken = 'access_token';
  static const kRefreshToken = 'refresh_token';
  static const kUserId = 'user_id';
  static const kUserEmail = 'user_email';
  static const kOnboardingSeen = 'onboarding_seen';

  @override
  Future<void> write({required String key, required String value}) async {
    await _storage.write(key: key, value: value);
  }

  @override
  Future<String?> read({required String key}) async {
    return await _storage.read(key: key);
  }

  @override
  Future<void> delete({required String key}) async {
    await _storage.delete(key: key);
  }

  @override
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  @override
  Future<bool> containsKey({required String key}) async {
    return await _storage.containsKey(key: key);
  }

  @override
  Future<bool> get hasAccessToken async {
    final token = await read(key: kAccessToken);
    return token != null && token.isNotEmpty;
  }

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await write(key: kAccessToken, value: accessToken);
    await write(key: kRefreshToken, value: refreshToken);
  }

  @override
  Future<void> clearTokens() async {
    await delete(key: kAccessToken);
    await delete(key: kRefreshToken);
  }
}
