import '../../domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.id,
    required super.email,
    required super.phone,
    required super.name,
    required super.avatarUrl,
    required super.isVerified,
    required super.referralCode,
    required super.primeTier,
    super.primeExpiresAt,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
        id: json['id'] as String? ?? '',
        email: json['email'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        name: json['name'] as String? ?? '',
        avatarUrl: json['avatar_url'] as String? ?? '',
        isVerified: json['is_verified'] as bool? ?? false,
        referralCode: json['referral_code'] as String? ?? '',
        primeTier: json['prime_tier'] as String? ?? 'free',
        primeExpiresAt: json['prime_expires_at'] != null
            ? DateTime.parse(json['prime_expires_at'] as String)
            : null,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : DateTime.now(),
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'] as String)
            : DateTime.now(),
      );
}
