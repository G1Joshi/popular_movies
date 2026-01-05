import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/review_model.dart';

class ReviewsSection extends StatelessWidget {
  final List<ReviewModel> reviews;

  const ReviewsSection({super.key, required this.reviews});

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Text(
                'Reviews',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  reviews.length.toString(),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: reviews.length > 3 ? 3 : reviews.length,
          itemBuilder: (context, index) {
            return _ReviewCard(review: reviews[index]);
          },
        ),
      ],
    );
  }
}

class _ReviewCard extends StatefulWidget {
  final ReviewModel review;

  const _ReviewCard({required this.review});

  @override
  State<_ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<_ReviewCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final content = widget.review.content ?? 'No content';
    final isLong = content.length > 200;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                child: Text(
                  widget.review.author[0].toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.review.author,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (widget.review.authorDetails?.rating != null) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: AppColors.rating,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.review.authorDetails!.rating!
                                .toStringAsFixed(1),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            firstChild: Text(
              content,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            secondChild: Text(
              content,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
          ),
          if (isLong) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Text(
                _isExpanded ? 'Show less' : 'Read more',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
