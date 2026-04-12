import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/address_repository.dart';

class UpdateAddressUseCase {
  final AddressRepository _repository;
  UpdateAddressUseCase(this._repository);

  Future<Either<Failure, void>> call({required String id, required Map<String, dynamic> data}) =>
      _repository.updateAddress(id: id, data: data);
}
