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

  const ServiceDetailLoaded(this.service);

  @override
  List<Object> get props => [service];
}

class AvailabilityLoaded extends CatalogState {
  final bool available;
  final List<String> slots;

  const AvailabilityLoaded({required this.available, required this.slots});

  @override
  List<Object> get props => [available, slots];
}

class CatalogError extends CatalogState {
  final String message;

  const CatalogError(this.message);

  @override
  List<Object> get props => [message];
}
