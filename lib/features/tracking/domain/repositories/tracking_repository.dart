import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/tracking_entity.dart';

abstract interface class TrackingRepository {
  Future<Either<Failure, VendorLocationEntity>> getVendorLocation(String vendorId);
}
