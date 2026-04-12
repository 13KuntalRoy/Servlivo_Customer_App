import '../../domain/entities/subscription_entity.dart';

class SubscriptionModel extends SubscriptionEntity {
  const SubscriptionModel({
    required super.id,
    required super.serviceId,
    required super.serviceName,
    required super.frequency,
    required super.status,
    required super.nextServiceDate,
    required super.price,
    required super.addressId,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) => SubscriptionModel(
        id: json['id'] as String,
        serviceId: json['service_id'] as String,
        serviceName: json['service_name'] as String? ?? '',
        frequency: json['frequency'] as String,
        status: json['status'] as String,
        nextServiceDate: json['next_service_date'] != null
            ? DateTime.parse(json['next_service_date'] as String)
            : DateTime.now(),
        price: (json['price'] as num?)?.toDouble() ?? 0,
        addressId: json['address_id'] as String,
      );
}
