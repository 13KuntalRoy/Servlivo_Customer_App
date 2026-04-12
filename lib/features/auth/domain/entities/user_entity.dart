import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String phone;
  final String name;
  final String avatarUrl;
  final String role;
  final bool isVerified;
  final bool isActive;
  final String referralCode;
  final String referredByCode;
  final String primeTier;
  final DateTime? primeExpiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.phone,
    required this.name,
    required this.avatarUrl,
    required this.role,
    required this.isVerified,
    required this.isActive,
    required this.referralCode,
    required this.referredByCode,
    required this.primeTier,
    this.primeExpiresAt,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isPrime => primeTier != 'free';

  UserEntity copyWith({
    String? id,
    String? email,
    String? phone,
    String? name,
    String? avatarUrl,
    String? role,
    bool? isVerified,
    bool? isActive,
    String? referralCode,
    String? referredByCode,
    String? primeTier,
    DateTime? primeExpiresAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      referralCode: referralCode ?? this.referralCode,
      referredByCode: referredByCode ?? this.referredByCode,
      primeTier: primeTier ?? this.primeTier,
      primeExpiresAt: primeExpiresAt ?? this.primeExpiresAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        phone,
        name,
        avatarUrl,
        role,
        isVerified,
        isActive,
        referralCode,
        referredByCode,
        primeTier,
        primeExpiresAt,
        createdAt,
        updatedAt,
      ];
}
