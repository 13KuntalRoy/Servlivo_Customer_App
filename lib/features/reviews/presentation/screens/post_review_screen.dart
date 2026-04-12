import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/usecases/review_usecases.dart';
import '../cubit/review_cubit.dart';

class PostReviewScreen extends StatefulWidget {
  final String bookingId;
  final String vendorId;
  final String vendorName;

  const PostReviewScreen({
    super.key,
    required this.bookingId,
    required this.vendorId,
    required this.vendorName,
  });

  @override
  State<PostReviewScreen> createState() => _PostReviewScreenState();
}

class _PostReviewScreenState extends State<PostReviewScreen> {
  int _rating = 5;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReviewCubit, ReviewState>(
      listener: (context, state) {
        if (state is ReviewSubmitted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Review submitted! Thank you.'),
              backgroundColor: AppColors.secondary,
            ),
          );
          Navigator.of(context).pop();
        } else if (state is ReviewError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Rate Your Experience')),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 36,
                  backgroundColor: AppColors.divider,
                  child: Text('S',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 12),
                Text(widget.vendorName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                const Text('Service Professional',
                    style: TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 24),
                const Text('How was your experience?',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    final filled = i < _rating;
                    return GestureDetector(
                      onTap: () => setState(() => _rating = i + 1),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          filled ? Icons.star : Icons.star_border,
                          color: AppColors.star,
                          size: 40,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 8),
                Text(
                  ['', 'Poor', 'Fair', 'Good', 'Great', 'Excellent'][_rating],
                  style: const TextStyle(
                      color: AppColors.secondary, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _commentController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Share your experience (optional)...',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: state is ReviewLoading
                        ? null
                        : () => context.read<ReviewCubit>().submitReview(
                              PostReviewParams(
                                bookingId: widget.bookingId,
                                vendorId: widget.vendorId,
                                rating: _rating,
                                comment: _commentController.text.trim(),
                              ),
                            ),
                    child: state is ReviewLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Submit Review'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
