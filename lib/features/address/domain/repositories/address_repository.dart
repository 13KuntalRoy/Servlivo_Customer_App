import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/address_entity.dart';

abstract interface class AddressRepository {
  Future<Either<Failure, List<AddressEntity>>> getAddresses();
  Future<Either<Failure, AddressEntity>> createAddress({
    required String label,
    required String line1,
    String? line2,
    required String city,
    required String state,
    required String pinCode,
    String country,
    double? latitude,
    double? longitude,
    bool isDefault,
  });
  Future<Either<Failure, void>> updateAddress({required String id, required Map<String, dynamic> data});
  Future<Either<Failure, void>> deleteAddress(String id);
}
