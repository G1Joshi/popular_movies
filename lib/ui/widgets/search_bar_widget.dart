import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;
  final String hintText;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.onChanged,
    this.onClear,
    this.hintText = 'Search movies...',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 16),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.textSecondary,
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    controller.clear();
                    onClear?.call();
                  },
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.textSecondary,
                  ),
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
