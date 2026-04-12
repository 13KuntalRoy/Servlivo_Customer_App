import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  final String id;
  final String email;
  final String phone;
  final String name;
  final String avatarUrl;
  final bool isVerified;
  final String referralCode;
  final String primeTier;
  final DateTime? primeExpiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProfileEntity({
    required this.id,
    required this.email,
    required this.phone,
    required this.name,
    required this.avatarUrl,
    required this.isVerified,
    required this.referralCode,
    required this.primeTier,
    this.primeExpiresAt,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, email, phone, name, avatarUrl, isVerified, referralCode, primeTier];
}
