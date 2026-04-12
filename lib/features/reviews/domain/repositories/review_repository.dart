import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/review_entity.dart';

abstract class ReviewRepository {
  Future<Either<Failure, ReviewEntity>> postReview({
    required String bookingId,
    required String vendorId,
    required int rating,
    required String comment,
  });
  Future<Either<Failure, List<ReviewEntity>>> getVendorReviews(String vendorId);
}
