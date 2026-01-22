// Import dasar Flutter untuk UI
import 'package:flutter/material.dart';

// Provider untuk state management
import 'package:provider/provider.dart';

// NewsProvider → mengatur data berita & pencarian
import 'package:news_reader/presentation/providers/news_provider.dart';

// Widget kartu berita versi GRID
import 'package:news_reader/presentation/widgets/grid_news_card.dart';

// Widget loading
import 'package:news_reader/presentation/widgets/loading_widget.dart';

// Widget ketika data kosong
import 'package:news_reader/presentation/widgets/empty_state_widget.dart';

// Background dengan gradient
import 'package:news_reader/presentation/widgets/gradient_background.dart';

// Halaman detail berita
import 'package:news_reader/presentation/screens/news_detail_screen.dart';

// Theme aplikasi
import 'package:news_reader/core/theme/app_theme.dart';

/// ===============================
/// SEARCH SCREEN
/// Halaman untuk mencari berita
/// dengan tampilan GRID responsive
/// ===============================
class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

  // Controller untuk mengambil teks dari TextField
  final TextEditingController _searchController = TextEditingController();

  // FocusNode → supaya keyboard langsung muncul
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    // Setelah widget selesai dirender,
    // langsung fokus ke kolom search
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    // WAJIB dispose supaya tidak memory leak
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    // Mengecek apakah mode gelap aktif
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,

        // AppBar berisi search field
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: _buildSearchField(context, isDark),
        ),

        // Body utama
        body: _buildBody(context),
      ),
    );
  }

  /// ===============================
  /// SEARCH FIELD (INPUT PENCARIAN)
  /// ===============================
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

        // Warna teks mengikuti theme
        style: TextStyle(
          color: isDark ? AppTheme.darkText : AppTheme.lightText,
        ),

        decoration: InputDecoration(
          hintText: 'Search news...',
          prefixIcon: const Icon(Icons.search, color: AppTheme.primaryBlue),

          // Tombol clear muncul jika ada teks
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

        // Dipanggil setiap teks berubah
        onChanged: (value) {
          setState(() {});

          // Search hanya jika >= 3 huruf
          if (value.length >= 3) {
            Future.delayed(const Duration(milliseconds: 500), () {
              // Cegah search berulang (debounce)
              if (_searchController.text == value) {
                context.read<NewsProvider>().searchNews(value);
              }
            });
          } 
          // Jika kosong → hapus hasil pencarian
          else if (value.isEmpty) {
            context.read<NewsProvider>().clearSearch();
          }
        },

        // Saat tekan ENTER
        onSubmitted: (value) {
          if (value.isNotEmpty) {
            context.read<NewsProvider>().searchNews(value);
          }
        },
      ),
    );
  }

  /// ===============================
  /// BODY HASIL SEARCH (GRID)
  /// ===============================
  Widget _buildBody(BuildContext context) {
    return Consumer<NewsProvider>(
      builder: (context, newsProvider, child) {

        // Kondisi awal (belum search)
        if (_searchController.text.isEmpty &&
            newsProvider.searchResults.isEmpty) {
          return _buildInitialState(context);
        }

        // Loading
        if (newsProvider.isLoading) {
          return const CircularLoading(message: 'Searching...');
        }

        // Error
        if (newsProvider.hasError) {
          return ErrorStateWidget(
            message: newsProvider.errorMessage ?? 'Search failed',
            onRetry: () =>
                newsProvider.searchNews(_searchController.text),
          );
        }

        // Hasil kosong
        if (newsProvider.searchResults.isEmpty &&
            _searchController.text.isNotEmpty) {
          return EmptyStateWidget(
            icon: Icons.search_off,
            title: 'No Results Found',
            message: 'Try different keywords',
            actionText: 'Clear',
            onActionPressed: () {
              _searchController.clear();
              newsProvider.clearSearch();
              setState(() {});
            },
          );
        }

        // ===============================
        // HASIL SEARCH → GRID VIEW
        // ===============================
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: LayoutBuilder(
              builder: (context, constraints) {

                // Menentukan jumlah kolom
                int crossAxisCount;
                if (constraints.maxWidth < 600) {
                  crossAxisCount = 1; // HP
                } else if (constraints.maxWidth < 900) {
                  crossAxisCount = 2; // Tablet
                } else {
                  crossAxisCount = 3; // Desktop
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 4 / 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: newsProvider.searchResults.length,
                  itemBuilder: (context, index) {
                    final article =
                        newsProvider.searchResults[index];
                    final isBookmarked =
                        newsProvider.isBookmarked(article.id);

                    return GridNewsCard(
                      article: article,
                      isBookmarked: isBookmarked,

                      // Buka detail berita
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

                      // Bookmark
                      onBookmarkTap: () {
                        newsProvider.toggleBookmark(article);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isBookmarked
                                  ? 'Removed from bookmarks'
                                  : 'Added to bookmarks',
                            ),
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

  /// ===============================
  /// TAMPILAN AWAL SEBELUM SEARCH
  /// ===============================
  Widget _buildInitialState(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64),
          const SizedBox(height: 16),
          Text('Search for News'),
          const SizedBox(height: 8),
          Text('Enter at least 3 characters'),
        ],
      ),
    );
  }
}
