import '../../domain/entities/prime_entity.dart';

class PrimePlanModel extends PrimePlanEntity {
  const PrimePlanModel({
    required super.id,
    required super.tier,
    required super.name,
    required super.tagline,
    required super.priceMonthly,
    required super.priceYearly,
    required super.benefits,
  });

  factory PrimePlanModel.fromJson(Map<String, dynamic> json) => PrimePlanModel(
        id: json['id'] as String,
        tier: json['tier'] as String? ?? 'free',
        name: json['name'] as String,
        tagline: json['tagline'] as String? ?? '',
        priceMonthly: (json['price_monthly'] as num?)?.toDouble() ?? 0,
        priceYearly: (json['price_yearly'] as num?)?.toDouble() ?? 0,
        benefits: ((json['features'] as List?) ?? []).cast<String>(),
      );
}

class PrimeMembershipModel extends PrimeMembershipEntity {
  const PrimeMembershipModel({
    required super.id,
    required super.planId,
    required super.planName,
    required super.startDate,
    required super.endDate,
    required super.isActive,
  });

  factory PrimeMembershipModel.fromJson(Map<String, dynamic> json) =>
      PrimeMembershipModel(
        id: json['id'] as String,
        planId: json['plan_id'] as String,
        planName: json['plan_name'] as String? ?? '',
        startDate: DateTime.parse(json['start_date'] as String),
        endDate: DateTime.parse(json['end_date'] as String),
        isActive: json['is_active'] as bool? ?? false,
      );
}
