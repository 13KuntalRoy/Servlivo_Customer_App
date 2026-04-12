part of 'review_cubit.dart';

sealed class ReviewState extends Equatable {
  const ReviewState();

  @override
  List<Object?> get props => [];
}

class ReviewInitial extends ReviewState {
  const ReviewInitial();
}

class ReviewLoading extends ReviewState {
  const ReviewLoading();
}

class ReviewListLoaded extends ReviewState {
  final List<ReviewEntity> reviews;
  const ReviewListLoaded(this.reviews);

  @override
  List<Object> get props => [reviews];
}

class ReviewSubmitted extends ReviewState {
  final ReviewEntity review;
  const ReviewSubmitted(this.review);

  @override
  List<Object> get props => [review];
}

class ReviewError extends ReviewState {
  final String message;
  const ReviewError(this.message);

  @override
  List<Object> get props => [message];
}
