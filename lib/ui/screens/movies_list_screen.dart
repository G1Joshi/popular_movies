import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/error/failures.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/debouncer.dart';
import '../blocs/connectivity/connectivity_bloc.dart';
import '../blocs/connectivity/connectivity_state.dart';
import '../blocs/movies/movies_bloc.dart';
import '../blocs/movies/movies_event.dart';
import '../blocs/movies/movies_state.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/error_widget.dart';
import '../widgets/movie_card.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/shimmer_loading.dart';

class MoviesListScreen extends StatefulWidget {
  const MoviesListScreen({super.key});

  @override
  State<MoviesListScreen> createState() => _MoviesListScreenState();
}

class _MoviesListScreenState extends State<MoviesListScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  late final Debouncer _debouncer;

  @override
  void initState() {
    super.initState();
    _debouncer = Debouncer(delay: AppConstants.searchDebounce);
    _scrollController.addListener(_onScroll);

    context.read<MoviesBloc>().add(const LoadMovies());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<MoviesBloc>().add(const LoadMoreMovies());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _onSearchChanged(String query) {
    _debouncer.run(() {
      if (query.isEmpty) {
        context.read<MoviesBloc>().add(const ClearSearch());
      } else {
        context.read<MoviesBloc>().add(SearchMovies(query));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildFilterToggle(),
            Expanded(child: _buildMoviesGrid()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          const Text(
            'Movies',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),

          BlocBuilder<ConnectivityBloc, ConnectivityState>(
            builder: (context, state) {
              if (!state.isInitialized) return const SizedBox.shrink();

              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: state.isConnected
                      ? AppColors.success.withValues(alpha: 0.2)
                      : AppColors.warning.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      state.isConnected ? Icons.wifi : Icons.wifi_off,
                      size: 16,
                      color: state.isConnected
                          ? AppColors.success
                          : AppColors.warning,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      state.isConnected ? 'Online' : 'Offline',
                      style: TextStyle(
                        color: state.isConnected
                            ? AppColors.success
                            : AppColors.warning,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return SearchBarWidget(
      controller: _searchController,
      onChanged: _onSearchChanged,
      onClear: () {
        context.read<MoviesBloc>().add(const ClearSearch());
      },
    );
  }

  Widget _buildFilterToggle() {
    return BlocBuilder<MoviesBloc, MoviesState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              _FilterChip(
                label: 'All Movies',
                isSelected: !state.showFavoritesOnly,
                onTap: () {
                  if (state.showFavoritesOnly) {
                    context.read<MoviesBloc>().add(
                      const ToggleShowFavoritesOnly(),
                    );
                  }
                },
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Favorites',
                icon: Icons.favorite,
                isSelected: state.showFavoritesOnly,
                count: state.favoriteIds.length,
                onTap: () {
                  if (!state.showFavoritesOnly) {
                    context.read<MoviesBloc>().add(
                      const ToggleShowFavoritesOnly(),
                    );
                  }
                },
              ),
              const Spacer(),
              if (state.isSearching)
                Text(
                  'Results for "${state.searchQuery}"',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMoviesGrid() {
    return BlocConsumer<MoviesBloc, MoviesState>(
      listener: (context, state) {
        if (state.failure != null && state.status != MoviesStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.failure!.message),
              backgroundColor: AppColors.warning,
              behavior: SnackBarBehavior.floating,
              action: state.failure is NetworkFailure
                  ? null
                  : SnackBarAction(
                      label: 'Retry',
                      textColor: Colors.white,
                      onPressed: () {
                        context.read<MoviesBloc>().add(const LoadMovies());
                      },
                    ),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state.status == MoviesStatus.initial ||
            (state.status == MoviesStatus.loading && state.movies.isEmpty)) {
          return const MovieGridShimmer();
        }

        if (state.status == MoviesStatus.failure && state.movies.isEmpty) {
          if (state.failure is NetworkFailure) {
            if (state.favoriteMovies.isNotEmpty) {
              return _buildGrid(state, showOfflineMessage: true);
            }
            return NetworkErrorWidget(
              onRetry: () {
                context.read<MoviesBloc>().add(const LoadMovies(refresh: true));
              },
            );
          }
          return GenericErrorWidget(
            message: state.failure?.message ?? 'An error occurred',
            onRetry: () {
              context.read<MoviesBloc>().add(const LoadMovies(refresh: true));
            },
          );
        }

        if (state.displayedMovies.isEmpty) {
          if (state.showFavoritesOnly) {
            return EmptyStateWidget(
              icon: Icons.favorite_border,
              title: 'No Favorites Yet',
              message: 'Movies you mark as favorite will appear here.',
              actionText: 'Browse Movies',
              onAction: () {
                context.read<MoviesBloc>().add(const ToggleShowFavoritesOnly());
              },
            );
          }
          return EmptyStateWidget(
            icon: Icons.movie_outlined,
            title: 'No Movies Found',
            message: state.isSearching
                ? 'Try a different search term'
                : 'Unable to load movies',
            actionText: 'Refresh',
            onAction: () {
              context.read<MoviesBloc>().add(const LoadMovies(refresh: true));
            },
          );
        }

        return _buildGrid(state);
      },
    );
  }

  Widget _buildGrid(MoviesState state, {bool showOfflineMessage = false}) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<MoviesBloc>().add(const LoadMovies(refresh: true));
      },
      color: AppColors.primary,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          if (showOfflineMessage)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.wifi_off, color: AppColors.warning, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You\'re offline. Showing favorite movies only.',
                        style: TextStyle(
                          color: AppColors.warning,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.62,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final movie = state.displayedMovies[index];
                return MovieCard(
                  key: ValueKey(movie.id),
                  movie: movie,
                  isFavorite: state.isFavorite(movie.id),
                  onTap: () {
                    context.push('/movie/${movie.id}');
                  },
                  onFavoriteTap: () {
                    context.read<MoviesBloc>().add(
                      ToggleFavorite(
                        movieId: movie.id,
                        isFavorite: state.isFavorite(movie.id),
                      ),
                    );

                    final isFav = state.isFavorite(movie.id);
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isFav
                              ? '${movie.title} removed from favorites'
                              : '${movie.title} added to favorites',
                        ),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                );
              }, childCount: state.displayedMovies.length),
            ),
          ),

          if (state.status == MoviesStatus.loadingMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final int? count;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    this.icon,
    required this.isSelected,
    this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.cardDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            if (count != null && count! > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.2)
                      : AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
