// ================= IMPORT =================

// Package dasar Flutter
import 'package:flutter/material.dart';

// Provider untuk state management
import 'package:provider/provider.dart';

// Untuk menampilkan gambar dari internet + cache
import 'package:cached_network_image/cached_network_image.dart';

// Untuk membuka link di browser
import 'package:url_launcher/url_launcher.dart';

// Untuk fitur share ke WhatsApp, dll
import 'package:share_plus/share_plus.dart';

// Untuk format tanggal
import 'package:intl/intl.dart';

// Model data artikel berita
import 'package:news_reader/data/models/news_article.dart';

// Provider berita (bookmark, status baca)
import 'package:news_reader/presentation/providers/news_provider.dart';

// Tema aplikasi
import 'package:news_reader/core/theme/app_theme.dart';

// Background gradasi
import 'package:news_reader/presentation/widgets/gradient_background.dart';

/// ================= NEWS DETAIL SCREEN =================
/// Halaman detail berita dengan:
/// - Gambar header
/// - Bookmark
/// - Share
/// - Preview konten
/// - Tombol buka artikel asli
class NewsDetailScreen extends StatelessWidget {
  // Artikel yang dikirim dari halaman sebelumnya
  final NewsArticle article;

  const NewsDetailScreen({
    Key? key,
    required this.article,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mengecek mode tema
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GradientBackground(
      showPattern: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,

        // CustomScrollView agar AppBar bisa collapse
        body: CustomScrollView(
          slivers: [
            _buildAppBar(context, isDark), // AppBar dengan gambar
            _buildContent(context, isDark), // Konten berita
          ],
        ),
      ),
    );
  }

  /// ================= APP BAR =================
  /// AppBar dengan gambar berita (collapsing)
  Widget _buildAppBar(BuildContext context, bool isDark) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor:
          isDark ? AppTheme.darkSurface : AppTheme.primaryBlue,

      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // ================= IMAGE =================
            // Jika artikel punya gambar → tampilkan
            if (article.hasImage)
              CachedNetworkImage(
                imageUrl: article.imageUrl!,
                fit: BoxFit.cover,

                // Loading saat gambar dimuat
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  child:
                      const Center(child: CircularProgressIndicator()),
                ),

                // Jika error
                errorWidget: (context, url, error) =>
                    _buildPlaceholder(),
              )
            else
              _buildPlaceholder(),

            // ================= GRADIENT OVERLAY =================
            // Agar teks tetap terbaca
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
            ),

            // ================= API SOURCE TAG =================
            Positioned(
              bottom: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  article.apiSource.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // ================= ACTIONS =================
      actions: [
        // Tombol share
        IconButton(
          icon: const Icon(Icons.share),
          tooltip: 'Share',
          onPressed: () => _shareArticle(context),
        ),

        // Tombol bookmark
        Consumer<NewsProvider>(
          builder: (context, provider, child) {
            final isBookmarked =
                provider.isBookmarked(article.id);

            return IconButton(
              icon: Icon(
                isBookmarked
                    ? Icons.bookmark
                    : Icons.bookmark_border,
              ),
              tooltip: isBookmarked
                  ? 'Remove Bookmark'
                  : 'Add Bookmark',
              onPressed: () {
                provider.toggleBookmark(article);

                // Notifikasi
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
        ),
      ],
    );
  }

  /// ================= MAIN CONTENT =================
  /// Isi utama berita
  Widget _buildContent(BuildContext context, bool isDark) {
    return SliverToBoxAdapter(
      child: Container(
        // Background card
        decoration: BoxDecoration(
          color: isDark
              ? AppTheme.darkBackground
              : AppTheme.lightBackground,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),

        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= TITLE =================
              Text(
                article.title,
                style: Theme.of(context)
                    .textTheme
                    .displaySmall
                    ?.copyWith(
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
              ),

              const SizedBox(height: 16),

              // ================= META INFO =================
              _buildMetaInfo(context, isDark),

              const Divider(height: 32),

              // ================= DESCRIPTION =================
              if (article.description.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppTheme.darkCard.withOpacity(0.3)
                        : AppTheme.primaryBlue
                            .withOpacity(0.05),
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                  child: Text(
                    article.description,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(
                          height: 1.6,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // ================= CONTENT PREVIEW =================
              Text(
                'Article Preview',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),

              const SizedBox(height: 12),

              Text(
                article.content,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(
                      height: 1.8,
                      fontSize: 16,
                    ),
              ),

              const SizedBox(height: 24),

              // ================= INFO NOTE =================
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.warning.withOpacity(0.1),
                      AppTheme.info.withOpacity(0.1),
                    ],
                  ),
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'This is a preview. Read the full article for complete details.',
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ================= ACTION BUTTONS =================
              Row(
                children: [
                  // SHARE
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _shareArticle(context),
                      icon: const Icon(Icons.share),
                      label: const Text('Share'),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // READ FULL ARTICLE
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _openArticleUrl(context),
                      icon: const Icon(Icons.open_in_new,
                          color: Colors.white),
                      label:
                          const Text('Read Full Article'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  /// ================= META INFO =================
  /// Sumber, author, dan tanggal publikasi
  Widget _buildMetaInfo(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.darkCard.withOpacity(0.5)
            : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),

      child: Column(
        children: [
          // SOURCE
          Row(
            children: [
              const Icon(Icons.newspaper),
              const SizedBox(width: 12),
              Text(article.source),
            ],
          ),

          const Divider(),

          // AUTHOR & DATE
          Row(
            children: [
              const Icon(Icons.person),
              const SizedBox(width: 8),
              Text(article.displayAuthor),
              const Spacer(),
              const Icon(Icons.calendar_today),
              const SizedBox(width: 8),
              Text(
                DateFormat('MMM dd, yyyy')
                    .format(article.publishedAt),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Placeholder jika gambar tidak tersedia
  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient.scale(0.5),
      ),
      child: const Center(
        child: Icon(
          Icons.article,
          size: 80,
          color: Colors.white54,
        ),
      ),
    );
  }

  /// ================= SHARE ARTICLE =================
  Future<void> _shareArticle(BuildContext context) async {
    try {
      final text = '''
📰 ${article.title}

🔖 Source: ${article.source}
📅 ${DateFormat('MMM dd, yyyy').format(article.publishedAt)}

🔗 ${article.url}

Shared via News Reader Pro
''';

      await Share.share(text,
          subject: article.title);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to share'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  /// ================= OPEN URL =================
  Future<void> _openArticleUrl(BuildContext context) async {
    try {
      final url = Uri.parse(article.url);
      await launchUrl(url,
          mode: LaunchMode.externalApplication);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Failed to open article'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }
}
