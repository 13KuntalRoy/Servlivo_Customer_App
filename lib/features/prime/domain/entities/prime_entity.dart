import 'package:equatable/equatable.dart';

class PrimePlanEntity extends Equatable {
  final String id;
  final String tier;
  final String name;
  final String tagline;
  final double priceMonthly;
  final double priceYearly;
  final List<String> benefits;

  const PrimePlanEntity({
    required this.id,
    required this.tier,
    required this.name,
    required this.tagline,
    required this.priceMonthly,
    required this.priceYearly,
    required this.benefits,
  });

  @override
  List<Object> get props => [id, tier, name, priceMonthly, priceYearly];
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
