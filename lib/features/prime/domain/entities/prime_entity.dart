import 'package:equatable/equatable.dart';

class PrimePlanEntity extends Equatable {
  final String id;
  final String name;
  final double price;
  final int durationDays;
  final List<String> benefits;

  const PrimePlanEntity({
    required this.id,
    required this.name,
    required this.price,
    required this.durationDays,
    required this.benefits,
  });

  @override
  List<Object> get props => [id, name, price];
}

class PrimeMembershipEntity extends Equatable {
  final String id;
  final String planId;
  final String planName;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;

  const PrimeMembershipEntity({
    required this.id,
    required this.planId,
    required this.planName,
    required this.startDate,
    required this.endDate,
    required this.isActive,
  });

  int get daysRemaining => endDate.difference(DateTime.now()).inDays;

  @override
  List<Object> get props => [id, planId, isActive];
}
