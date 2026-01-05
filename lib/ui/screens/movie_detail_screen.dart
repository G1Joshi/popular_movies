import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/api_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/movie_detail_model.dart';
import '../../data/repositories/movie_repository.dart';
import '../blocs/movies/movie_detail_bloc.dart';
import '../blocs/movies/movie_detail_event.dart';
import '../blocs/movies/movie_detail_state.dart';
import '../blocs/movies/movies_bloc.dart';
import '../blocs/movies/movies_event.dart';
import '../widgets/cast_list_widget.dart';
import '../widgets/error_widget.dart';
import '../widgets/reviews_section.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/trailer_player_widget.dart';

class MovieDetailScreen extends StatelessWidget {
  final int movieId;

  const MovieDetailScreen({super.key, required this.movieId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          MovieDetailBloc(repository: context.read<MovieRepository>())
            ..add(LoadMovieDetail(movieId)),
      child: _MovieDetailView(movieId: movieId),
    );
  }
}

class _MovieDetailView extends StatelessWidget {
  final int movieId;

  const _MovieDetailView({required this.movieId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<MovieDetailBloc, MovieDetailState>(
        listener: (context, state) {
          if (state.movie != null) {
            context.read<MoviesBloc>().add(
              ToggleFavorite(movieId: movieId, isFavorite: !state.isFavorite),
            );
          }
        },
        listenWhen: (previous, current) =>
            previous.isFavorite != current.isFavorite,
        builder: (context, state) {
          if (state.status == MovieDetailStatus.loading) {
            return const MovieDetailShimmer();
          }

          if (state.status == MovieDetailStatus.failure) {
            return Scaffold(
              appBar: AppBar(
                leading: const BackButton(color: AppColors.textPrimary),
                backgroundColor: Colors.transparent,
              ),
              body: NetworkErrorWidget(
                onRetry: () {
                  context.read<MovieDetailBloc>().add(LoadMovieDetail(movieId));
                },
              ),
            );
          }

          if (state.movie == null) {
            return const SizedBox.shrink();
          }

          return _buildContent(context, state);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, MovieDetailState state) {
    final movie = state.movie!;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: Icon(
                    state.isFavorite ? Icons.favorite : Icons.favorite_border,
                    key: ValueKey(state.isFavorite),
                    color: state.isFavorite ? AppColors.favorite : Colors.white,
                  ),
                ),
                onPressed: () {
                  context.read<MovieDetailBloc>().add(
                    const ToggleDetailFavorite(),
                  );

                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        state.isFavorite
                            ? '${movie.title} removed from favorites'
                            : '${movie.title} added to favorites',
                      ),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                Hero(
                  tag: 'movie_poster_$movieId',
                  child: CachedNetworkImage(
                    imageUrl: ApiConstants.getBackdropUrl(
                      movie.backdropPath ?? movie.posterPath,
                    ),
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppColors.cardDark,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.cardDark,
                      child: const Icon(
                        Icons.movie_outlined,
                        size: 64,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),

                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        AppColors.backgroundDark.withValues(alpha: 0.8),
                        AppColors.backgroundDark,
                      ],
                      stops: const [0.0, 0.4, 0.8, 1.0],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie.title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),

                if (movie.tagline != null && movie.tagline!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    movie.tagline!,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                _buildInfoRow(movie, state),

                const SizedBox(height: 16),

                if (movie.genres.isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: movie.genres.map((genre) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          genre.name,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                ],

                const Text(
                  'Synopsis',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  movie.overview ?? 'No synopsis available.',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: CastListWidget(cast: state.cast),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 24),
            child: TrailerPlayerWidget(trailers: state.videos),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 24, bottom: 32),
            child: ReviewsSection(reviews: state.reviews),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(MovieDetailModel movie, MovieDetailState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _InfoItem(
            icon: Icons.star_rounded,
            iconColor: AppColors.rating,
            value: movie.voteAverage.toStringAsFixed(1),
            label: '${movie.voteCount} votes',
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.textHint.withValues(alpha: 0.3),
          ),
          _InfoItem(
            icon: Icons.schedule_rounded,
            iconColor: AppColors.primary,
            value: movie.formattedRuntime,
            label: 'Duration',
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.textHint.withValues(alpha: 0.3),
          ),
          _InfoItem(
            icon: Icons.calendar_today_rounded,
            iconColor: AppColors.accent,
            value: _getYear(movie.releaseDate),
            label: 'Release',
          ),
        ],
      ),
    );
  }

  String _getYear(String? date) {
    if (date == null || date.isEmpty) return 'N/A';
    try {
      return DateTime.parse(date).year.toString();
    } catch (_) {
      return date;
    }
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _InfoItem({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
        ),
      ],
    );
  }
}
