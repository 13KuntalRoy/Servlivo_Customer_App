import '../../domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.slug,
    required super.description,
    required super.iconUrl,
    required super.isActive,
    required super.sortOrder,
    super.serviceCount,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        slug: json['slug'] as String? ?? '',
        description: json['description'] as String? ?? '',
        iconUrl: json['icon_url'] as String? ?? '',
        isActive: json['is_active'] as bool? ?? true,
        sortOrder: json['sort_order'] as int? ?? 0,
      );
}

class SubcategoryModel extends SubcategoryEntity {
  const SubcategoryModel({
    required super.id,
    required super.categoryId,
    required super.name,
    required super.slug,
    required super.description,
    required super.iconUrl,
    required super.isActive,
    required super.sortOrder,
  });

  factory SubcategoryModel.fromJson(Map<String, dynamic> json) => SubcategoryModel(
        id: json['id'] as String? ?? '',
        categoryId: json['category_id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        slug: json['slug'] as String? ?? '',
        description: json['description'] as String? ?? '',
        iconUrl: json['icon_url'] as String? ?? '',
        isActive: json['is_active'] as bool? ?? true,
        sortOrder: json['sort_order'] as int? ?? 0,
      );
}

class ServiceModel extends ServiceEntity {
  const ServiceModel({
    required super.id,
    required super.subcategoryId,
    required super.name,
    required super.slug,
    required super.description,
    required super.basePrice,
    required super.priceType,
    required super.durationMins,
    required super.imageUrl,
    required super.images,
    required super.isActive,
    required super.sortOrder,
    super.vendorCount,
    super.avgRating,
    super.availableToday,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) => ServiceModel(
        id: json['id'] as String? ?? '',
        subcategoryId: json['subcategory_id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        slug: json['slug'] as String? ?? '',
        description: json['description'] as String? ?? '',
        basePrice: (json['base_price'] as num?)?.toDouble() ?? 0,
        priceType: json['price_type'] as String? ?? 'fixed',
        durationMins: json['duration_mins'] as int? ?? 60,
        imageUrl: json['image_url'] as String? ?? '',
        images: (json['images'] as List<dynamic>?)?.cast<String>() ?? [],
        isActive: json['is_active'] as bool? ?? true,
        sortOrder: json['sort_order'] as int? ?? 0,
        vendorCount: json['vendor_count'] as int? ?? 0,
        avgRating: (json['avg_rating'] as num?)?.toDouble() ?? 0,
        availableToday: json['available_today'] as bool? ?? false,
      );
}

class ServiceAttributeModel extends ServiceAttributeEntity {
  const ServiceAttributeModel({
    required super.id,
    required super.serviceId,
    required super.name,
    required super.label,
    required super.type,
    required super.isRequired,
    required super.sortOrder,
    required super.values,
  });

  factory ServiceAttributeModel.fromJson(Map<String, dynamic> json) {
    final vals = (json['values'] as List<dynamic>?)
            ?.map((v) => AttributeValueModel.fromJson(v as Map<String, dynamic>))
            .toList() ??
        [];
    return ServiceAttributeModel(
      id: json['id'] as String? ?? '',
      serviceId: json['service_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      label: json['label'] as String? ?? '',
      type: json['type'] as String? ?? 'select',
      isRequired: json['is_required'] as bool? ?? false,
      sortOrder: json['sort_order'] as int? ?? 0,
      values: vals,
    );
  }
}

class AttributeValueModel extends AttributeValueEntity {
  const AttributeValueModel({
    required super.id,
    required super.attributeId,
    required super.value,
    required super.label,
    required super.priceAdj,
    required super.sortOrder,
  });

  factory AttributeValueModel.fromJson(Map<String, dynamic> json) => AttributeValueModel(
        id: json['id'] as String? ?? '',
        attributeId: json['attribute_id'] as String? ?? '',
        value: json['value'] as String? ?? '',
        label: json['label'] as String? ?? '',
        priceAdj: (json['price_adj'] as num?)?.toDouble() ?? 0,
        sortOrder: json['sort_order'] as int? ?? 0,
      );
}
