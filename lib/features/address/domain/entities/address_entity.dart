import 'package:equatable/equatable.dart';

class AddressEntity extends Equatable {
  final String id;
  final String userId;
  final String label;
  final String line1;
  final String line2;
  final String city;
  final String state;
  final String pinCode;
  final String country;
  final double latitude;
  final double longitude;
  final bool isDefault;
  final DateTime createdAt;

  const AddressEntity({
    required this.id,
    required this.userId,
    required this.label,
    required this.line1,
    required this.line2,
    required this.city,
    required this.state,
    required this.pinCode,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.isDefault,
    required this.createdAt,
  });

  String get shortDisplay => '$line1, $city';
  String get fullDisplay => '$line1${line2.isNotEmpty ? ', $line2' : ''}, $city, $state $pinCode';

  @override
  List<Object?> get props => [id, label, line1, city, pinCode, isDefault];
}
