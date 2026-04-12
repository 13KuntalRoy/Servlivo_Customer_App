import '../../domain/entities/address_entity.dart';

class AddressModel extends AddressEntity {
  const AddressModel({
    required super.id,
    required super.userId,
    required super.label,
    required super.line1,
    required super.line2,
    required super.city,
    required super.state,
    required super.pinCode,
    required super.country,
    required super.latitude,
    required super.longitude,
    required super.isDefault,
    required super.createdAt,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) => AddressModel(
        id: json['id'] as String? ?? '',
        userId: json['user_id'] as String? ?? '',
        label: json['label'] as String? ?? 'Home',
        line1: json['line1'] as String? ?? '',
        line2: json['line2'] as String? ?? '',
        city: json['city'] as String? ?? '',
        state: json['state'] as String? ?? '',
        pinCode: json['pin_code'] as String? ?? '',
        country: json['country'] as String? ?? 'India',
        latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
        longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
        isDefault: json['is_default'] as bool? ?? false,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'label': label,
        'line1': line1,
        'line2': line2,
        'city': city,
        'state': state,
        'pin_code': pinCode,
        'country': country,
        'latitude': latitude,
        'longitude': longitude,
        'is_default': isDefault,
      };
}
