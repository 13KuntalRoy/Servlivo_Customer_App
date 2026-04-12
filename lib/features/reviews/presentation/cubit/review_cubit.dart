import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/review_entity.dart';
import '../../domain/usecases/review_usecases.dart';

part 'review_state.dart';

class ReviewCubit extends Cubit<ReviewState> {
  final PostReviewUseCase _postReview;
  final GetVendorReviewsUseCase _getReviews;

  ReviewCubit({
    required PostReviewUseCase postReview,
    required GetVendorReviewsUseCase getReviews,
  })  : _postReview = postReview,
        _getReviews = getReviews,
        super(const ReviewInitial());

  Future<void> loadVendorReviews(String vendorId) async {
    emit(const ReviewLoading());
    final result = await _getReviews(vendorId);
    result.fold(
      (failure) => emit(ReviewError(failure.message)),
      (reviews) => emit(ReviewListLoaded(reviews)),
    );
  }

  Future<void> submitReview(PostReviewParams params) async {
    emit(const ReviewLoading());
    final result = await _postReview(params);
    result.fold(
      (failure) => emit(ReviewError(failure.message)),
      (review) => emit(ReviewSubmitted(review)),
    );
  }
}
