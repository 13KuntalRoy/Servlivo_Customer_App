import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/review_entity.dart';
import '../repositories/review_repository.dart';

class PostReviewParams {
  final String bookingId;
  final String vendorId;
  final int rating;
  final String comment;

  const PostReviewParams({
    required this.bookingId,
    required this.vendorId,
    required this.rating,
    required this.comment,
  });
}

class PostReviewUseCase {
  final ReviewRepository repository;
  PostReviewUseCase(this.repository);

  Future<Either<Failure, ReviewEntity>> call(PostReviewParams params) =>
      repository.postReview(
        bookingId: params.bookingId,
        vendorId: params.vendorId,
        rating: params.rating,
        comment: params.comment,
      );
}

class GetVendorReviewsUseCase {
  final ReviewRepository repository;
  GetVendorReviewsUseCase(this.repository);

  Future<Either<Failure, List<ReviewEntity>>> call(String vendorId) =>
      repository.getVendorReviews(vendorId);
}
