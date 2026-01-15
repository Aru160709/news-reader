import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:news_reader/presentation/providers/news_provider.dart';
import 'package:news_reader/presentation/providers/theme_provider.dart';
import 'package:news_reader/presentation/widgets/grid_news_card.dart'; // ← BARU!
import 'package:news_reader/presentation/widgets/hot_news_widget.dart'; // ← BARU!
import 'package:news_reader/presentation/widgets/footer_widget.dart'; // ← BARU!
import 'package:news_reader/presentation/widgets/loading_widget.dart';
import 'package:news_reader/presentation/widgets/empty_state_widget.dart';
import 'package:news_reader/presentation/widgets/gradient_background.dart';
import 'package:news_reader/presentation/screens/news_detail_screen.dart';
import 'package:news_reader/presentation/screens/bookmarks_screen.dart';
import 'package:news_reader/presentation/screens/search_screen.dart';
import 'package:news_reader/core/constants/api_constants.dart';
import 'package:news_reader/core/theme/app_theme.dart';

/// Home Screen - UPDATED dengan Grid Layout + Hot News + Footer
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NewsProvider>().loadTopHeadlines();
      context.read<NewsProvider>().loadBookmarks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: RefreshIndicator(
          onRefresh: () =>
              context.read<NewsProvider>().loadTopHeadlines(refresh: true),
          child: CustomScrollView(
            slivers: [
              _buildStickyAppBar(context),
              _buildCategoryChips(),
              _buildHotNewsSection(), // ← BARU!
              _buildNewsGrid(), // ← CHANGED dari List ke Grid!
              _buildFooter(), // ← BARU!
            ],
          ),
        ),
      ),
    );
  }

  /// STICKY App Bar (tetap di atas saat scroll)
  Widget _buildStickyAppBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SliverAppBar(
      expandedHeight: 100,
      floating: false,
      pinned: true, // ← PENTING: Navbar tetap di atas!
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: isDark ? AppTheme.darkGradient : AppTheme.primaryGradient,
        ),
        child: FlexibleSpaceBar(
          centerTitle: false,
          titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'News Reader Pro',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Consumer<NewsProvider>(
                builder: (context, provider, child) {
                  if (provider.isOfflineMode) {
                    return const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.wifi_off, size: 10, color: Colors.white70),
                        SizedBox(width: 4),
                        Text(
                          'Offline',
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.white70,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SearchScreen()),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.bookmark, color: Colors.white),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BookmarksScreen()),
          ),
        ),
        Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return IconButton(
              icon: Icon(
                themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: Colors.white,
              ),
              onPressed: () => themeProvider.toggleTheme(),
            );
          },
        ),
      ],
    );
  }

  /// Category Chips
  Widget _buildCategoryChips() {
    return SliverToBoxAdapter(
      child: Container(
        height: 60,
        margin: const EdgeInsets.only(top: 12),
        child: Consumer<NewsProvider>(
          builder: (context, newsProvider, child) {
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: AppConstants.categories.length,
              itemBuilder: (context, index) {
                final category = AppConstants.categories[index];
                final isSelected = newsProvider.selectedCategory == category;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      _formatCategoryName(category),
                      style: TextStyle(
                        color: isSelected ? Colors.white : null,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        newsProvider.changeCategory(category);
                      }
                    },
                    selectedColor: AppTheme.primaryBlue,
                    checkmarkColor: Colors.white,
                    avatar: isSelected
                        ? const Icon(Icons.check_circle,
                            size: 16, color: Colors.white)
                        : null,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  /// HOT NEWS Section (Featured - horizontal scroll)
  Widget _buildHotNewsSection() {
    return Consumer<NewsProvider>(
      builder: (context, newsProvider, child) {
        if (newsProvider.isLoading || newsProvider.articles.isEmpty) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        return SliverToBoxAdapter(
          child: HotNewsWidget(
            articles: newsProvider.articles,
            onTap: (article) {
              newsProvider.markArticleAsRead(article.id);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewsDetailScreen(article: article),
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// NEWS GRID (responsive - 1-4 kolom tergantung layar)
  Widget _buildNewsGrid() {
    return Consumer<NewsProvider>(
      builder: (context, newsProvider, child) {
        // Loading State
        if (newsProvider.isLoading && newsProvider.articles.isEmpty) {
          return const SliverFillRemaining(child: LoadingWidget());
        }

        // Error State
        if (newsProvider.hasError && newsProvider.articles.isEmpty) {
          return SliverFillRemaining(
            child: ErrorStateWidget(
              message: newsProvider.errorMessage ?? 'Failed to load news',
              isOffline: newsProvider.isOfflineMode,
              onRetry: () => newsProvider.retry(),
            ),
          );
        }

        // Empty State
        if (newsProvider.articles.isEmpty) {
          return SliverFillRemaining(
            child: EmptyStateWidget(
              icon: Icons.article_outlined,
              title: 'No News Available',
              message: 'Try changing the category or pull to refresh',
              actionText: 'Refresh',
              onActionPressed: () =>
                  newsProvider.loadTopHeadlines(refresh: true),
            ),
          );
        }

        // SUCCESS: Grid Layout dengan Max-Width
        return SliverToBoxAdapter(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200), // ← Max width!
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section Title
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.newspaper,
                              color: AppTheme.primaryBlue,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Latest News',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const Spacer(),
                          Text(
                            '${newsProvider.articles.length} articles',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.primaryBlue,
                                    ),
                          ),
                        ],
                      ),
                    ),

                    // GRID dengan Responsive Columns
                    LayoutBuilder(
                      builder: (context, constraints) {
                        // Hitung jumlah kolom berdasarkan lebar layar
                        int crossAxisCount;
                        if (constraints.maxWidth < 600) {
                          crossAxisCount = 1; // Mobile: 1 kolom
                        } else if (constraints.maxWidth < 900) {
                          crossAxisCount = 2; // Tablet: 2 kolom
                        } else {
                          crossAxisCount = 3; // Desktop: 3 kolom
                        }

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            childAspectRatio: 4 / 3, // ← RATIO 4:3!
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: newsProvider.articles.length,
                          itemBuilder: (context, index) {
                            final article = newsProvider.articles[index];
                            final isBookmarked =
                                newsProvider.isBookmarked(article.id);

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
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// FOOTER
  Widget _buildFooter() {
    return const SliverToBoxAdapter(
      child: FooterWidget(),
    );
  }

  String _formatCategoryName(String category) {
    if (category == 'general') return 'All';
    return category[0].toUpperCase() + category.substring(1);
  }
}
