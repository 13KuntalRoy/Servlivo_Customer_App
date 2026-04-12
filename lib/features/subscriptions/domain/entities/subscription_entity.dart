import 'package:equatable/equatable.dart';

class SubscriptionEntity extends Equatable {
  final String id;
  final String serviceId;
  final String serviceName;
  final String frequency; // weekly, biweekly, monthly
  final String status; // active, paused, cancelled
  final DateTime nextServiceDate;
  final double price;
  final String addressId;

  const SubscriptionEntity({
    required this.id,
    required this.serviceId,
    required this.serviceName,
    required this.frequency,
    required this.status,
    required this.nextServiceDate,
    required this.price,
    required this.addressId,
  });

  bool get isActive => status == 'active';

  @override
  List<Object> get props => [id, serviceId, status, frequency];
}
