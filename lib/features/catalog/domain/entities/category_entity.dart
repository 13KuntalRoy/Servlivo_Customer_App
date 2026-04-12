import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final String slug;
  final String description;
  final String iconUrl;
  final bool isActive;
  final int sortOrder;
  final int serviceCount;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.iconUrl,
    required this.isActive,
    required this.sortOrder,
    this.serviceCount = 0,
  });

  @override
  List<Object?> get props => [id, name, slug];
}

class SubcategoryEntity extends Equatable {
  final String id;
  final String categoryId;
  final String name;
  final String slug;
  final String description;
  final String iconUrl;
  final bool isActive;
  final int sortOrder;

  const SubcategoryEntity({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.slug,
    required this.description,
    required this.iconUrl,
    required this.isActive,
    required this.sortOrder,
  });

  @override
  List<Object?> get props => [id, name, slug];
}

class ServiceEntity extends Equatable {
  final String id;
  final String subcategoryId;
  final String name;
  final String slug;
  final String description;
  final double basePrice;
  final String priceType;
  final int durationMins;
  final String imageUrl;
  final List<String> images;
  final bool isActive;
  final int sortOrder;
  final int vendorCount;
  final double avgRating;
  final bool availableToday;

  const ServiceEntity({
    required this.id,
    required this.subcategoryId,
    required this.name,
    required this.slug,
    required this.description,
    required this.basePrice,
    required this.priceType,
    required this.durationMins,
    required this.imageUrl,
    required this.images,
    required this.isActive,
    required this.sortOrder,
    this.vendorCount = 0,
    this.avgRating = 0,
    this.availableToday = false,
  });

  String get durationDisplay {
    if (durationMins < 60) return '$durationMins mins';
    final h = durationMins ~/ 60;
    final m = durationMins % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }

  @override
  List<Object?> get props => [id, name, basePrice];
}

class ServiceAttributeEntity extends Equatable {
  final String id;
  final String serviceId;
  final String name;
  final String label;
  final String type;
  final bool isRequired;
  final int sortOrder;
  final List<AttributeValueEntity> values;

  const ServiceAttributeEntity({
    required this.id,
    required this.serviceId,
    required this.name,
    required this.label,
    required this.type,
    required this.isRequired,
    required this.sortOrder,
    required this.values,
  });

  @override
  List<Object?> get props => [id, name];
}

class AttributeValueEntity extends Equatable {
  final String id;
  final String attributeId;
  final String value;
  final String label;
  final double priceAdj;
  final int sortOrder;

  const AttributeValueEntity({
    required this.id,
    required this.attributeId,
    required this.value,
    required this.label,
    required this.priceAdj,
    required this.sortOrder,
  });

  @override
  List<Object?> get props => [id, value];
}
