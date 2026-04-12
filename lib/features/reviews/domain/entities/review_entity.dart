import 'package:equatable/equatable.dart';

class ReviewEntity extends Equatable {
  final String id;
  final String bookingId;
  final String vendorId;
  final int rating;
  final String comment;
  final DateTime createdAt;

  const ReviewEntity({
    required this.id,
    required this.bookingId,
    required this.vendorId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  @override
  List<Object> get props => [id, bookingId, vendorId, rating];
}
