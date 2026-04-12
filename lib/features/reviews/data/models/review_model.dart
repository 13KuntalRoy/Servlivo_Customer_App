import '../../domain/entities/review_entity.dart';

class ReviewModel extends ReviewEntity {
  const ReviewModel({
    required super.id,
    required super.bookingId,
    required super.vendorId,
    required super.rating,
    required super.comment,
    required super.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) => ReviewModel(
        id: json['id'] as String,
        bookingId: json['booking_id'] as String,
        vendorId: json['vendor_id'] as String,
        rating: json['rating'] as int,
        comment: json['comment'] as String? ?? '',
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}
