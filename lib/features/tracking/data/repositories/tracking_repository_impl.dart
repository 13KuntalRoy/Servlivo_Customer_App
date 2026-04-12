import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/tracking_entity.dart';
import '../../domain/repositories/tracking_repository.dart';
import '../datasources/tracking_remote_data_source.dart';

class TrackingRepositoryImpl implements TrackingRepository {
  final TrackingRemoteDataSource remote;
  final NetworkInfo networkInfo;

  TrackingRepositoryImpl({required this.remote, required this.networkInfo});

  @override
  Future<Either<Failure, VendorLocationEntity>> getVendorLocation(String vendorId) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure('No internet'));
    try {
      final data = await remote.getVendorLocation(vendorId);
      return Right(VendorLocationEntity(
        bookingId: '',
        latitude: (data['latitude'] as num?)?.toDouble() ?? 0,
        longitude: (data['longitude'] as num?)?.toDouble() ?? 0,
        speed: 0,
        etaSeconds: 0,
      ));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
