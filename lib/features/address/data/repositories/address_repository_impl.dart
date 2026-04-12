import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/address_entity.dart';
import '../../domain/repositories/address_repository.dart';
import '../datasources/address_remote_data_source.dart';

class AddressRepositoryImpl implements AddressRepository {
  final AddressRemoteDataSource remote;
  final NetworkInfo networkInfo;

  AddressRepositoryImpl({required this.remote, required this.networkInfo});

  @override
  Future<Either<Failure, List<AddressEntity>>> getAddresses() async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure('No internet'));
    try {
      final list = await remote.getAddresses();
      return Right(list);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, AddressEntity>> createAddress({
    required String label,
    required String line1,
    String? line2,
    required String city,
    required String state,
    required String pinCode,
    String country = 'India',
    double? latitude,
    double? longitude,
    bool isDefault = false,
  }) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure('No internet'));
    try {
      final model = await remote.createAddress({
        'label': label,
        'line1': line1,
        'line2': line2 ?? '',
        'city': city,
        'state': state,
        'pin_code': pinCode,
        'country': country,
        'latitude': latitude ?? 0,
        'longitude': longitude ?? 0,
        'is_default': isDefault,
      });
      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateAddress({required String id, required Map<String, dynamic> data}) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure('No internet'));
    try {
      await remote.updateAddress(id: id, data: data);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAddress(String id) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure('No internet'));
    try {
      await remote.deleteAddress(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
