import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/video_model.dart';

class TrailerPlayerWidget extends StatefulWidget {
  final List<VideoModel> trailers;

  const TrailerPlayerWidget({super.key, required this.trailers});

  @override
  State<TrailerPlayerWidget> createState() => _TrailerPlayerWidgetState();
}

class _TrailerPlayerWidgetState extends State<TrailerPlayerWidget> {
  late YoutubePlayerController _controller;
  int _currentTrailerIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.trailers.isNotEmpty) {
      _initializePlayer(_currentTrailerIndex);
    }
  }

  void _initializePlayer(int index) {
    final videoId = widget.trailers[index].key;
    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        enableCaption: true,
        controlsVisibleAtStart: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _switchTrailer(int index) {
    if (index != _currentTrailerIndex) {
      setState(() {
        _currentTrailerIndex = index;
        _controller.dispose();
        _initializePlayer(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.trailers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Trailers',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 12),

        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: YoutubePlayer(
              controller: _controller,
              showVideoProgressIndicator: true,
              progressIndicatorColor: AppColors.primary,
              progressColors: const ProgressBarColors(
                playedColor: AppColors.primary,
                handleColor: AppColors.accent,
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            widget.trailers[_currentTrailerIndex].name,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        if (widget.trailers.length > 1) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: widget.trailers.length,
              itemBuilder: (context, index) {
                final isSelected = index == _currentTrailerIndex;
                final trailer = widget.trailers[index];

                return GestureDetector(
                  onTap: () => _switchTrailer(index),
                  child: Container(
                    width: 120,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textHint.withValues(alpha: 0.3),
                        width: isSelected ? 2 : 1,
                      ),
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : AppColors.cardDark,
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(11),
                          child: Image.network(
                            'https://img.youtube.com/vi/${trailer.key}/mqdefault.jpg',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),

                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(11),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.7),
                              ],
                            ),
                          ),
                        ),

                        Center(
                          child: Icon(
                            isSelected ? Icons.pause_circle : Icons.play_circle,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),

                        Positioned(
                          bottom: 4,
                          left: 4,
                          right: 4,
                          child: Text(
                            'Trailer ${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],

        const SizedBox(height: 24),
      ],
    );
  }
}
