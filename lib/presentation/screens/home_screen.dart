// ================= IMPORT =================

// Package dasar Flutter untuk UI
import 'package:flutter/material.dart';

// Provider untuk state management
import 'package:provider/provider.dart';

// Provider data berita
import 'package:news_reader/presentation/providers/news_provider.dart';

// Provider tema (light / dark)
import 'package:news_reader/presentation/providers/theme_provider.dart';

// Widget kartu berita versi grid
import 'package:news_reader/presentation/widgets/grid_news_card.dart';

// Widget Hot News (headline utama)
import 'package:news_reader/presentation/widgets/hot_news_widget.dart';

// Widget footer aplikasi
import 'package:news_reader/presentation/widgets/footer_widget.dart';

// Widget loading
import 'package:news_reader/presentation/widgets/loading_widget.dart';

// Widget empty state
import 'package:news_reader/presentation/widgets/empty_state_widget.dart';

// Widget background gradasi
import 'package:news_reader/presentation/widgets/gradient_background.dart';

// Halaman detail berita
import 'package:news_reader/presentation/screens/news_detail_screen.dart';

// Halaman bookmark
import 'package:news_reader/presentation/screens/bookmarks_screen.dart';

// Halaman pencarian
import 'package:news_reader/presentation/screens/search_screen.dart';

// Konstanta API (kategori berita)
import 'package:news_reader/core/constants/api_constants.dart';

// Tema aplikasi
import 'package:news_reader/core/theme/app_theme.dart';

/// ================= HOME SCREEN =================
/// Halaman utama aplikasi
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  // Dipanggil sekali saat widget pertama kali dibuat
  @override
  void initState() {
    super.initState();

    // Menjalankan kode setelah build pertama selesai
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Mengambil berita utama
      context.read<NewsProvider>().loadTopHeadlines();

      // Mengambil data bookmark
      context.read<NewsProvider>().loadBookmarks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        // Scaffold transparan agar gradient terlihat
        backgroundColor: Colors.transparent,

        body: RefreshIndicator(
          // Pull to refresh berita
          onRefresh: () =>
              context.read<NewsProvider>().loadTopHeadlines(refresh: true),

          // CustomScrollView untuk Sliver (AppBar, Grid, Footer)
          child: CustomScrollView(
            slivers: [
              _buildStickyAppBar(context), // AppBar tetap
              _buildCategoryChips(),       // Chip kategori
              _buildHotNewsSection(),      // Hot News
              _buildNewsGrid(),            // Grid berita
              _buildFooter(),              // Footer
            ],
          ),
        ),
      ),
    );
  }

  /// ================= STICKY APP BAR =================
  /// AppBar yang tetap di atas saat scroll
  Widget _buildStickyAppBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SliverAppBar(
      expandedHeight: 100,
      floating: false,
      pinned: true, // AppBar tetap terlihat
      backgroundColor: Colors.transparent,

      flexibleSpace: Container(
        decoration: BoxDecoration(
          // Gradient tergantung tema
          gradient: isDark
              ? AppTheme.darkGradient
              : AppTheme.primaryGradient,
        ),

        child: FlexibleSpaceBar(
          centerTitle: false,
          titlePadding: const EdgeInsets.only(left: 20, bottom: 16),

          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Judul aplikasi
              const Text(
                'News Reader Pro',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              // Indikator offline
              Consumer<NewsProvider>(
                builder: (context, provider, child) {
                  if (provider.isOfflineMode) {
                    return const Row(
                      children: [
                        Icon(Icons.wifi_off,
                            size: 10, color: Colors.white70),
                        SizedBox(width: 4),
                        Text(
                          'Offline',
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.white70,
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

      // ================= ACTIONS =================
      actions: [
        // Tombol search
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SearchScreen()),
          ),
        ),

        // Tombol bookmark
        IconButton(
          icon: const Icon(Icons.bookmark, color: Colors.white),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BookmarksScreen()),
          ),
        ),

        // Toggle tema
        Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return IconButton(
              icon: Icon(
                themeProvider.isDarkMode
                    ? Icons.light_mode
                    : Icons.dark_mode,
                color: Colors.white,
              ),
              onPressed: themeProvider.toggleTheme,
            );
          },
        ),
      ],
    );
  }

  /// ================= CATEGORY CHIPS =================
  /// Chip kategori berita (horizontal scroll)
  Widget _buildCategoryChips() {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 60,
        child: Consumer<NewsProvider>(
          builder: (context, newsProvider, child) {
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: AppConstants.categories.length,

              itemBuilder: (context, index) {
                final category = AppConstants.categories[index];
                final isSelected =
                    newsProvider.selectedCategory == category;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      _formatCategoryName(category),
                      style: TextStyle(
                        color: isSelected ? Colors.white : null,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppTheme.primaryBlue,
                    checkmarkColor: Colors.white,

                    // Saat chip dipilih
                    onSelected: (selected) {
                      if (selected) {
                        newsProvider.changeCategory(category);
                      }
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  /// ================= HOT NEWS =================
  /// Section berita utama (horizontal)
  Widget _buildHotNewsSection() {
    return Consumer<NewsProvider>(
      builder: (context, newsProvider, child) {
        if (newsProvider.isLoading ||
            newsProvider.articles.isEmpty) {
          return const SliverToBoxAdapter(
              child: SizedBox.shrink());
        }

        return SliverToBoxAdapter(
          child: HotNewsWidget(
            articles: newsProvider.articles,

            // Saat berita diklik
            onTap: (article) {
              newsProvider.markArticleAsRead(article.id);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      NewsDetailScreen(article: article),
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// ================= NEWS GRID =================
  /// Grid berita responsif (mobile / tablet / desktop)
  Widget _buildNewsGrid() {
    return Consumer<NewsProvider>(
      builder: (context, newsProvider, child) {

        // State loading
        if (newsProvider.isLoading &&
            newsProvider.articles.isEmpty) {
          return const SliverFillRemaining(
            child: LoadingWidget(),
          );
        }

        // State error
        if (newsProvider.hasError &&
            newsProvider.articles.isEmpty) {
          return SliverFillRemaining(
            child: ErrorStateWidget(
              message: newsProvider.errorMessage ??
                  'Failed to load news',
              isOffline: newsProvider.isOfflineMode,
              onRetry: newsProvider.retry,
            ),
          );
        }

        // State kosong
        if (newsProvider.articles.isEmpty) {
          return SliverFillRemaining(
            child: EmptyStateWidget(
              icon: Icons.article_outlined,
              title: 'No News Available',
              message:
                  'Try changing the category or pull to refresh',
              actionText: 'Refresh',
              onActionPressed: () =>
                  newsProvider.loadTopHeadlines(refresh: true),
            ),
          );
        }

        // ================= GRID SUCCESS =================
        return SliverToBoxAdapter(
          child: Center(
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(maxWidth: 1200),
              child: Padding(
                padding: const EdgeInsets.all(16),

                child: LayoutBuilder(
                  builder: (context, constraints) {

                    // Menentukan jumlah kolom
                    int crossAxisCount;
                    if (constraints.maxWidth < 600) {
                      crossAxisCount = 1;
                    } else if (constraints.maxWidth < 900) {
                      crossAxisCount = 2;
                    } else {
                      crossAxisCount = 3;
                    }

                    return GridView.builder(
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: 4 / 3,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),

                      itemCount: newsProvider.articles.length,
                      itemBuilder: (context, index) {
                        final article =
                            newsProvider.articles[index];
                        final isBookmarked =
                            newsProvider.isBookmarked(
                                article.id);

                        return GridNewsCard(
                          article: article,
                          isBookmarked: isBookmarked,

                          // Buka detail berita
                          onTap: () {
                            newsProvider
                                .markArticleAsRead(article.id);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    NewsDetailScreen(
                                        article: article),
                              ),
                            );
                          },

                          // Bookmark
                          onBookmarkTap: () {
                            newsProvider.toggleBookmark(
                                article);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// ================= FOOTER =================
  Widget _buildFooter() {
    return const SliverToBoxAdapter(
      child: FooterWidget(),
    );
  }

  /// Format nama kategori
  String _formatCategoryName(String category) {
    if (category == 'general') return 'All';
    return category[0].toUpperCase() +
        category.substring(1);
  }
}
