import '../../domain/entities/prime_entity.dart';

class PrimePlanModel extends PrimePlanEntity {
  const PrimePlanModel({
    required super.id,
    required super.name,
    required super.price,
    required super.durationDays,
    required super.benefits,
  });

  factory PrimePlanModel.fromJson(Map<String, dynamic> json) => PrimePlanModel(
        id: json['id'] as String,
        name: json['name'] as String,
        price: (json['price'] as num?)?.toDouble() ?? 0,
        durationDays: (json['duration_days'] as int?) ?? 0,
        benefits: ((json['benefits'] as List?) ?? []).cast<String>(),
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
