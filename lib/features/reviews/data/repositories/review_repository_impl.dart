import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/review_entity.dart';
import '../../domain/repositories/review_repository.dart';
import '../datasources/review_remote_data_source.dart';
import '../models/review_model.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewRemoteDataSource remote;
  final NetworkInfo networkInfo;

  ReviewRepositoryImpl({required this.remote, required this.networkInfo});

  @override
  Future<Either<Failure, ReviewEntity>> postReview({
    required String bookingId,
    required String vendorId,
    required int rating,
    required String comment,
  }) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure('No internet'));
    try {
      final data = await remote.postReview({
        'booking_id': bookingId,
        'vendor_id': vendorId,
        'rating': rating,
        'comment': comment,
      });
      return Right(ReviewModel.fromJson(data));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<ReviewEntity>>> getVendorReviews(String vendorId) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure('No internet'));
    try {
      final list = await remote.getVendorReviews(vendorId);
      return Right(list.map(ReviewModel.fromJson).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
