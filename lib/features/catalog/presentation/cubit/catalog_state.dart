part of 'catalog_cubit.dart';

sealed class CatalogState extends Equatable {
  const CatalogState();

  @override
  List<Object?> get props => [];
}

class CatalogInitial extends CatalogState {
  const CatalogInitial();
}

class CatalogLoading extends CatalogState {
  const CatalogLoading();
}

class CategoriesLoaded extends CatalogState {
  final List<CategoryEntity> categories;

  const CategoriesLoaded(this.categories);

  @override
  List<Object> get props => [categories];
}

class SubcategoriesLoaded extends CatalogState {
  final List<SubcategoryEntity> subcategories;

  const SubcategoriesLoaded(this.subcategories);

  @override
  List<Object> get props => [subcategories];
}

class ServicesLoaded extends CatalogState {
  final List<ServiceEntity> services;

  const ServicesLoaded(this.services);

  @override
  List<Object> get props => [services];
}

class ServiceDetailLoaded extends CatalogState {
  final ServiceEntity service;
  final List<ServiceAttributeEntity> attributes;

  const ServiceDetailLoaded(this.service, {this.attributes = const []});

  @override
  List<Object> get props => [service, attributes];
}

class CatalogError extends CatalogState {
  final String message;

  const CatalogError(this.message);

  @override
  List<Object> get props => [message];
}
