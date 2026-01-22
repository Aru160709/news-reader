// ================= IMPORT =================

// Package dasar Flutter
import 'package:flutter/material.dart';

// Provider untuk state management
import 'package:provider/provider.dart';

// Provider berita (bookmark, data artikel)
import 'package:news_reader/presentation/providers/news_provider.dart';

// Widget kartu berita versi grid
import 'package:news_reader/presentation/widgets/grid_news_card.dart';

// Widget tampilan kosong (empty state)
import 'package:news_reader/presentation/widgets/empty_state_widget.dart';

// Widget background gradasi
import 'package:news_reader/presentation/widgets/gradient_background.dart';

// Halaman detail berita
import 'package:news_reader/presentation/screens/news_detail_screen.dart';

// Tema aplikasi
import 'package:news_reader/core/theme/app_theme.dart';

/// ================= BOOKMARKS SCREEN =================
/// Halaman untuk menampilkan semua artikel yang di-bookmark
class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mengecek apakah tema sedang dark mode
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GradientBackground(
      child: Scaffold(
        // Background transparan agar gradient terlihat
        backgroundColor: Colors.transparent,

        // CustomScrollView agar bisa pakai SliverAppBar + Grid
        body: CustomScrollView(
          slivers: [
            _buildAppBar(context, isDark), // AppBar bookmark
            _buildBookmarksGrid(context), // Grid bookmark
          ],
        ),
      ),
    );
  }

  /// ================= APP BAR =================
  /// AppBar dengan efek sticky & gradient
  Widget _buildAppBar(BuildContext context, bool isDark) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true, // Tetap terlihat saat scroll
      backgroundColor: Colors.transparent,

      flexibleSpace: Container(
        decoration: BoxDecoration(
          // Gradient menyesuaikan tema
          gradient: isDark
              ? AppTheme.darkGradient
              : AppTheme.primaryGradient,
        ),

        child: const FlexibleSpaceBar(
          centerTitle: false,
          titlePadding: EdgeInsets.only(left: 60, bottom: 16),

          // Judul halaman
          title: Text(
            'Bookmarks',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),

      // ================= ACTIONS =================
      actions: [
        // Tombol hapus semua bookmark
        Consumer<NewsProvider>(
          builder: (context, provider, child) {
            // Jika tidak ada bookmark, tombol disembunyikan
            if (provider.bookmarkedArticles.isEmpty) {
              return const SizedBox.shrink();
            }

            return IconButton(
              icon: const Icon(Icons.delete_sweep,
                  color: Colors.white),
              tooltip: 'Clear All',

              // Tampilkan dialog konfirmasi
              onPressed: () =>
                  _showClearDialog(context, provider),
            );
          },
        ),
      ],
    );
  }

  /// ================= BOOKMARKS GRID =================
  /// Grid artikel yang disimpan
  Widget _buildBookmarksGrid(BuildContext context) {
    return Consumer<NewsProvider>(
      builder: (context, newsProvider, child) {
        // Ambil daftar bookmark
        final bookmarks = newsProvider.bookmarkedArticles;

        // ================= EMPTY STATE =================
        // Jika belum ada bookmark
        if (bookmarks.isEmpty) {
          return SliverFillRemaining(
            child: EmptyStateWidget(
              icon: Icons.bookmark_border,
              title: 'No Bookmarks Yet',
              message:
                  'Save your favorite articles to read them later',
              actionText: 'Explore News',

              // Kembali ke halaman sebelumnya
              onActionPressed: () => Navigator.pop(context),
            ),
          );
        }

        // ================= GRID SUCCESS =================
        return SliverToBoxAdapter(
          child: Center(
            child: ConstrainedBox(
              // Batas lebar maksimum (desktop friendly)
              constraints:
                  const BoxConstraints(maxWidth: 1200),

              child: Padding(
                padding: const EdgeInsets.all(16),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ================= HEADER =================
                    Padding(
                      padding:
                          const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          // Icon bookmark
                          Container(
                            padding:
                                const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBlue
                                  .withOpacity(0.1),
                              borderRadius:
                                  BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.bookmark,
                              color:
                                  AppTheme.primaryBlue,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Judul section
                          Text(
                            'Saved Articles',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                          ),
                          const Spacer(),

                          // Jumlah bookmark
                          Text(
                            '${bookmarks.length} saved',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color:
                                      AppTheme.primaryBlue,
                                ),
                          ),
                        ],
                      ),
                    ),

                    // ================= RESPONSIVE GRID =================
                    LayoutBuilder(
                      builder: (context, constraints) {
                        // Menentukan jumlah kolom
                        int crossAxisCount;
                        if (constraints.maxWidth < 600) {
                          crossAxisCount = 1; // Mobile
                        } else if (constraints.maxWidth < 900) {
                          crossAxisCount = 2; // Tablet
                        } else {
                          crossAxisCount = 3; // Desktop
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

                          itemCount: bookmarks.length,
                          itemBuilder: (context, index) {
                            final article =
                                bookmarks[index];

                            // ================= DISMISSIBLE =================
                            // Swipe ke kiri untuk hapus bookmark
                            return Dismissible(
                              key: Key(article.id),
                              direction:
                                  DismissDirection.endToStart,

                              background: Container(
                                alignment:
                                    Alignment.centerRight,
                                padding:
                                    const EdgeInsets.only(
                                        right: 20),
                                decoration: BoxDecoration(
                                  color: AppTheme.error,
                                  borderRadius:
                                      BorderRadius.circular(
                                          12),
                                ),
                                child: const Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .center,
                                  children: [
                                    Icon(Icons.delete,
                                        color: Colors.white,
                                        size: 32),
                                    SizedBox(height: 4),
                                    Text(
                                      'Remove',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Saat swipe selesai
                              onDismissed: (direction) {
                                newsProvider
                                    .toggleBookmark(
                                        article);

                                // Snackbar + UNDO
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                        'Bookmark removed'),
                                    action: SnackBarAction(
                                      label: 'UNDO',
                                      onPressed: () {
                                        newsProvider
                                            .toggleBookmark(
                                                article);
                                      },
                                    ),
                                    duration:
                                        const Duration(
                                            seconds: 3),
                                    behavior:
                                        SnackBarBehavior
                                            .floating,
                                  ),
                                );
                              },

                              // ================= GRID CARD =================
                              child: GridNewsCard(
                                article: article,
                                isBookmarked: true,

                                // Buka detail berita
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          NewsDetailScreen(
                                              article:
                                                  article),
                                    ),
                                  );
                                },

                                // Hapus bookmark via icon
                                onBookmarkTap: () {
                                  newsProvider
                                      .toggleBookmark(
                                          article);

                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Bookmark removed'),
                                      duration:
                                          Duration(seconds: 2),
                                      behavior:
                                          SnackBarBehavior
                                              .floating,
                                    ),
                                  );
                                },
                              ),
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

  /// ================= CLEAR ALL DIALOG =================
  /// Dialog konfirmasi hapus semua bookmark
  void _showClearDialog(
      BuildContext context, NewsProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Bookmarks?'),
        content:
            const Text('This action cannot be undone.'),

        actions: [
          // Tombol batal
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),

          // Tombol hapus semua
          ElevatedButton(
            onPressed: () {
              provider.clearAllBookmarks();
              Navigator.pop(context);

              // Notifikasi berhasil
              ScaffoldMessenger.of(context)
                  .showSnackBar(
                const SnackBar(
                  content:
                      Text('All bookmarks cleared'),
                  duration: Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
