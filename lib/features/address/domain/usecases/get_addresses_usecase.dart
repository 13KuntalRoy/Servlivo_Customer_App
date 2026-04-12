import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/address_entity.dart';
import '../repositories/address_repository.dart';

class GetAddressesUseCase {
  final AddressRepository _repository;
  GetAddressesUseCase(this._repository);

  Future<Either<Failure, List<AddressEntity>>> call() => _repository.getAddresses();
}
