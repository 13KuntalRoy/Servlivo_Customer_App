import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../entities/address_entity.dart';
import '../repositories/address_repository.dart';

class CreateAddressParams extends Equatable {
  final String label;
  final String line1;
  final String? line2;
  final String city;
  final String state;
  final String pinCode;
  final String country;
  final double? latitude;
  final double? longitude;
  final bool isDefault;

  const CreateAddressParams({
    required this.label,
    required this.line1,
    this.line2,
    required this.city,
    required this.state,
    required this.pinCode,
    this.country = 'India',
    this.latitude,
    this.longitude,
    this.isDefault = false,
  });

  @override
  List<Object?> get props => [label, line1, city, state, pinCode];
}

class CreateAddressUseCase {
  final AddressRepository _repository;
  CreateAddressUseCase(this._repository);

  Future<Either<Failure, AddressEntity>> call(CreateAddressParams params) =>
      _repository.createAddress(
        label: params.label,
        line1: params.line1,
        line2: params.line2,
        city: params.city,
        state: params.state,
        pinCode: params.pinCode,
        country: params.country,
        latitude: params.latitude,
        longitude: params.longitude,
        isDefault: params.isDefault,
      );
}
