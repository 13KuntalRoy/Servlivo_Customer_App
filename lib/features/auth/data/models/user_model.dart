import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.phone,
    required super.name,
    required super.avatarUrl,
    required super.role,
    required super.isVerified,
    required super.isActive,
    required super.referralCode,
    required super.referredByCode,
    required super.primeTier,
    super.primeExpiresAt,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      name: json['name'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String? ?? '',
      role: json['role'] as String? ?? 'customer',
      isVerified: json['is_verified'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      referralCode: json['referral_code'] as String? ?? '',
      referredByCode: json['referred_by_code'] as String? ?? '',
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'name': name,
      'avatar_url': avatarUrl,
      'role': role,
      'is_verified': isVerified,
      'is_active': isActive,
      'referral_code': referralCode,
      'referred_by_code': referredByCode,
      'prime_tier': primeTier,
      'prime_expires_at': primeExpiresAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserEntity toEntity() => UserEntity(
        id: id,
        email: email,
        phone: phone,
        name: name,
        avatarUrl: avatarUrl,
        role: role,
        isVerified: isVerified,
        isActive: isActive,
        referralCode: referralCode,
        referredByCode: referredByCode,
        primeTier: primeTier,
        primeExpiresAt: primeExpiresAt,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
