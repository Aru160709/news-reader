import 'package:news_reader/data/models/news_article.dart';

/// News Repository Interface
/// Interface/contract untuk NewsRepository
/// Menggunakan abstract class agar bisa di-implement dengan berbagai cara
abstract class NewsRepository {
  /// Get top headlines
  Future<List<NewsArticle>> getTopHeadlines({
    String? category,
    String? country,
  });

  /// Get news by category
  Future<List<NewsArticle>> getNewsByCategory(String category,
      {String? country});

  /// Search news
  Future<List<NewsArticle>> searchNews(String query);

  /// Get bookmarked articles
  Future<List<NewsArticle>> getBookmarkedArticles();

  /// Bookmark an article
  Future<void> bookmarkArticle(NewsArticle article);

  /// Remove bookmark
  Future<void> removeBookmark(String articleId);

  /// Check if article is bookmarked
  Future<bool> isArticleBookmarked(String articleId);

  /// Mark article as read
  Future<void> markAsRead(String articleId);

  /// Get read articles
  Future<List<NewsArticle>> getReadArticles();

  /// Clear all bookmarks
  Future<void> clearAllBookmarks();

  /// Get cached articles (untuk offline reading)
  Future<List<NewsArticle>> getCachedArticles();

  /// Cache articles
  Future<void> cacheArticles(List<NewsArticle> articles);

  /// Clear cache
  Future<void> clearCache();
}
