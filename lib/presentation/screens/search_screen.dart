import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:news_reader/presentation/providers/news_provider.dart';
import 'package:news_reader/presentation/widgets/grid_news_card.dart'; // ← PENTING: Pakai GridNewsCard!
import 'package:news_reader/presentation/widgets/loading_widget.dart';
import 'package:news_reader/presentation/widgets/empty_state_widget.dart';
import 'package:news_reader/presentation/widgets/gradient_background.dart';
import 'package:news_reader/presentation/screens/news_detail_screen.dart';
import 'package:news_reader/core/theme/app_theme.dart';

/// Search Screen - UPDATED dengan Grid Layout
/// Halaman untuk mencari berita dengan tampilan grid responsive
class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Auto focus ke search field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: _buildSearchField(context, isDark),
        ),
        body: _buildBody(context),
      ),
    );
  }

  /// Search Field
  Widget _buildSearchField(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.darkCard.withOpacity(0.8)
            : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _focusNode,
        style: TextStyle(
          color: isDark ? AppTheme.darkText : AppTheme.lightText,
        ),
        decoration: InputDecoration(
          hintText: 'Search news...',
          hintStyle: TextStyle(
            color: isDark
                ? AppTheme.darkTextSecondary
                : AppTheme.lightTextSecondary,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: AppTheme.primaryBlue,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    context.read<NewsProvider>().clearSearch();
                    setState(() {});
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),
        ),
        onChanged: (value) {
          setState(() {});

          // Search dengan delay (debounce)
          if (value.length >= 3) {
            Future.delayed(const Duration(milliseconds: 500), () {
              if (_searchController.text == value) {
                context.read<NewsProvider>().searchNews(value);
              }
            });
          } else if (value.isEmpty) {
            context.read<NewsProvider>().clearSearch();
          }
        },
        onSubmitted: (value) {
          if (value.isNotEmpty) {
            context.read<NewsProvider>().searchNews(value);
          }
        },
      ),
    );
  }

  /// Body with search results - GRID VERSION!
  Widget _buildBody(BuildContext context) {
    return Consumer<NewsProvider>(
      builder: (context, newsProvider, child) {
        // Initial State
        if (_searchController.text.isEmpty &&
            newsProvider.searchResults.isEmpty) {
          return _buildInitialState(context);
        }

        // Loading State
        if (newsProvider.isLoading) {
          return const CircularLoading(message: 'Searching...');
        }

        // Error State
        if (newsProvider.hasError) {
          return ErrorStateWidget(
            message: newsProvider.errorMessage ?? 'Search failed',
            onRetry: () => newsProvider.searchNews(_searchController.text),
          );
        }

        // Empty Results
        if (newsProvider.searchResults.isEmpty &&
            _searchController.text.isNotEmpty) {
          return EmptyStateWidget(
            icon: Icons.search_off,
            title: 'No Results Found',
            message: 'Try different keywords or check your spelling',
            actionText: 'Clear',
            onActionPressed: () {
              _searchController.clear();
              newsProvider.clearSearch();
              setState(() {});
            },
          );
        }

        // Search Results - GRID LAYOUT! 🎯
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Calculate columns based on screen width
                int crossAxisCount;
                if (constraints.maxWidth < 600) {
                  crossAxisCount = 1; // Mobile: 1 kolom
                } else if (constraints.maxWidth < 900) {
                  crossAxisCount = 2; // Tablet: 2 kolom
                } else {
                  crossAxisCount = 3; // Desktop: 3 kolom
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 4 / 3, // Ratio 4:3
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: newsProvider.searchResults.length,
                  itemBuilder: (context, index) {
                    final article = newsProvider.searchResults[index];
                    final isBookmarked = newsProvider.isBookmarked(article.id);

                    return GridNewsCard(
                      article: article,
                      isBookmarked: isBookmarked,
                      onTap: () {
                        newsProvider.markArticleAsRead(article.id);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                NewsDetailScreen(article: article),
                          ),
                        );
                      },
                      onBookmarkTap: () {
                        newsProvider.toggleBookmark(article);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isBookmarked
                                  ? 'Removed from bookmarks'
                                  : 'Added to bookmarks',
                            ),
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  /// Initial state (before search)
  Widget _buildInitialState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient.scale(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search,
                size: 64,
                color: isDark ? AppTheme.accentBlue : AppTheme.primaryBlue,
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Search for News',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 12),

            Text(
              'Enter at least 3 characters to search',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppTheme.darkTextSecondary
                        : AppTheme.lightTextSecondary,
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Popular searches
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildSuggestionChip('Technology'),
                _buildSuggestionChip('Business'),
                _buildSuggestionChip('Sports'),
                _buildSuggestionChip('Science'),
                _buildSuggestionChip('Health'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Suggestion chip
  Widget _buildSuggestionChip(String text) {
    return ActionChip(
      label: Text(text),
      onPressed: () {
        _searchController.text = text;
        context.read<NewsProvider>().searchNews(text);
        setState(() {});
      },
      backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
      labelStyle: const TextStyle(
        color: AppTheme.primaryBlue,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
