import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/constants/api_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/cast_model.dart';

class CastListWidget extends StatelessWidget {
  final List<CastModel> cast;

  const CastListWidget({super.key, required this.cast});

  @override
  Widget build(BuildContext context) {
    if (cast.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Cast',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: cast.length > 10 ? 10 : cast.length,
            itemBuilder: (context, index) {
              final actor = cast[index];
              return _CastCard(actor: actor);
            },
          ),
        ),
      ],
    );
  }
}

class _CastCard extends StatelessWidget {
  final CastModel actor;

  const _CastCard({required this.actor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: ApiConstants.getPosterUrl(
                  actor.profilePath,
                  size: ApiConstants.posterSizeW185,
                ),
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppColors.cardDark,
                  child: const Icon(
                    Icons.person_outline,
                    color: AppColors.textSecondary,
                    size: 32,
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.cardDark,
                  child: const Icon(
                    Icons.person_outline,
                    color: AppColors.textSecondary,
                    size: 32,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            actor.name,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (actor.character != null) ...[
            const SizedBox(height: 2),
            Text(
              actor.character!,
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
