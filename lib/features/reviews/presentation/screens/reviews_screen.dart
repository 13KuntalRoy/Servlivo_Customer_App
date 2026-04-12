import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../cubit/review_cubit.dart';

class ReviewsScreen extends StatefulWidget {
  final String vendorId;

  const ReviewsScreen({super.key, required this.vendorId});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ReviewCubit>().loadVendorReviews(widget.vendorId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reviews')),
      body: BlocBuilder<ReviewCubit, ReviewState>(
        builder: (context, state) {
          if (state is ReviewLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ReviewError) {
            return Center(child: Text(state.message));
          }
          if (state is ReviewListLoaded) {
            if (state.reviews.isEmpty) {
              return const Center(
                child: Text('No reviews yet',
                    style: TextStyle(color: AppColors.textSecondary)),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.reviews.length,
              separatorBuilder: (_, __) => const Divider(height: 24),
              itemBuilder: (context, i) {
                final review = state.reviews[i];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.divider,
                          child: Icon(Icons.person, size: 16),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text('Customer',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                        Text(
                          DateFormat('dd MMM yyyy').format(review.createdAt),
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(
                        5,
                        (si) => Icon(
                          si < review.rating ? Icons.star : Icons.star_border,
                          color: AppColors.star,
                          size: 16,
                        ),
                      ),
                    ),
                    if (review.comment.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(review.comment,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 14)),
                    ],
                  ],
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
