import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:news_reader/data/datasources/news_api_service.dart';
import 'package:news_reader/data/models/news_article.dart';
import 'package:news_reader/domain/repositories/news_repository.dart';
import 'package:news_reader/core/constants/api_constants.dart';
import 'package:news_reader/core/exceptions/app_exceptions.dart';

/// News Repository Implementation
/// Implementasi dari NewsRepository yang menggunakan:
/// - API Service untuk data dari internet
/// - SharedPreferences untuk data local (bookmarks, cache)
class NewsRepositoryImpl implements NewsRepository {
  final NewsApiService apiService;
  final SharedPreferences prefs;

  NewsRepositoryImpl({
    required this.apiService,
    required this.prefs,
  });

  // ============ API METHODS ============

  @override
  Future<List<NewsArticle>> getTopHeadlines({
    String? category,
    String? country,
  }) async {
    try {
      final response = await apiService.getNewsWithFallback(
        category: category,
        country: country ?? AppConstants.defaultCountry,
      );

      if (!response.hasArticles) {
        throw NoDataException(message: 'No news available');
      }

      // Cache articles untuk offline reading
      await cacheArticles(response.articles);

      return response.articles;
    } catch (e) {
      // Jika gagal, coba load dari cache
      final cachedArticles = await getCachedArticles();
      if (cachedArticles.isNotEmpty) {
        print('📱 Loading from cache (offline mode)');
        return cachedArticles;
      }
      rethrow;
    }
  }

  @override
  Future<List<NewsArticle>> getNewsByCategory(
    String category, {
    String? country,
  }) async {
    try {
      final response = await apiService.getNewsWithFallback(
        category: category,
        country: country ?? AppConstants.defaultCountry,
      );

      if (!response.hasArticles) {
        throw NoDataException(message: 'No news in $category category');
      }

      return response.articles;
    } catch (e) {
      throw ExceptionHandler.handleError(e);
    }
  }

  @override
  Future<List<NewsArticle>> searchNews(String query) async {
    try {
      if (query.trim().isEmpty) {
        throw AppException(message: 'Search query cannot be empty');
      }

      final response = await apiService.searchWithFallback(query);

      if (!response.hasArticles) {
        throw NoDataException(message: 'No results found for "$query"');
      }

      return response.articles;
    } catch (e) {
      throw ExceptionHandler.handleError(e);
    }
  }

  // ============ BOOKMARK METHODS ============

  @override
  Future<List<NewsArticle>> getBookmarkedArticles() async {
    try {
      final bookmarksJson = prefs.getString(StorageKeys.bookmarks);

      if (bookmarksJson == null || bookmarksJson.isEmpty) {
        return [];
      }

      final List<dynamic> bookmarksList = json.decode(bookmarksJson);

      return bookmarksList.map((json) => NewsArticle.fromJson(json)).toList();
    } catch (e) {
      throw CacheException(
        message: 'Failed to load bookmarks',
        originalError: e,
      );
    }
  }

  @override
  Future<void> bookmarkArticle(NewsArticle article) async {
    try {
      final bookmarks = await getBookmarkedArticles();

      // Cek apakah sudah ada
      if (bookmarks.any((a) => a.id == article.id)) {
        return; // Sudah di-bookmark
      }

      // Tambahkan ke list
      final updatedArticle = article.copyWith(isBookmarked: true);
      bookmarks.add(updatedArticle);

      // Save ke SharedPreferences
      final bookmarksJson = json.encode(
        bookmarks.map((a) => a.toJson()).toList(),
      );
      await prefs.setString(StorageKeys.bookmarks, bookmarksJson);

      print('📑 Article bookmarked: ${article.title}');
    } catch (e) {
      throw CacheException(
        message: 'Failed to bookmark article',
        originalError: e,
      );
    }
  }

  @override
  Future<void> removeBookmark(String articleId) async {
    try {
      final bookmarks = await getBookmarkedArticles();

      // Remove artikel dengan ID tersebut
      bookmarks.removeWhere((a) => a.id == articleId);

      // Save ke SharedPreferences
      final bookmarksJson = json.encode(
        bookmarks.map((a) => a.toJson()).toList(),
      );
      await prefs.setString(StorageKeys.bookmarks, bookmarksJson);

      print('🗑️ Bookmark removed');
    } catch (e) {
      throw CacheException(
        message: 'Failed to remove bookmark',
        originalError: e,
      );
    }
  }

  @override
  Future<bool> isArticleBookmarked(String articleId) async {
    try {
      final bookmarks = await getBookmarkedArticles();
      return bookmarks.any((a) => a.id == articleId);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> clearAllBookmarks() async {
    try {
      await prefs.remove(StorageKeys.bookmarks);
      print('🗑️ All bookmarks cleared');
    } catch (e) {
      throw CacheException(
        message: 'Failed to clear bookmarks',
        originalError: e,
      );
    }
  }

  // ============ READ ARTICLES METHODS ============

  @override
  Future<void> markAsRead(String articleId) async {
    try {
      final readArticles = await getReadArticles();

      // Cek apakah sudah ada
      if (readArticles.any((a) => a.id == articleId)) {
        return; // Sudah ditandai sebagai read
      }

      // Cari artikel dari bookmarks atau cache
      final bookmarks = await getBookmarkedArticles();
      final cached = await getCachedArticles();

      NewsArticle? article = bookmarks.firstWhere(
        (a) => a.id == articleId,
        orElse: () => cached.firstWhere(
          (a) => a.id == articleId,
          orElse: () => throw Exception('Article not found'),
        ),
      );

      final updatedArticle = article.copyWith(isRead: true);
      readArticles.add(updatedArticle);

      // Save ke SharedPreferences
      final readJson = json.encode(
        readArticles.map((a) => a.toJson()).toList(),
      );
      await prefs.setString(StorageKeys.readArticles, readJson);
    } catch (e) {
      // Tidak throw error, karena ini tidak critical
      print('⚠️ Failed to mark as read: $e');
    }
  }

  @override
  Future<List<NewsArticle>> getReadArticles() async {
    try {
      final readJson = prefs.getString(StorageKeys.readArticles);

      if (readJson == null || readJson.isEmpty) {
        return [];
      }

      final List<dynamic> readList = json.decode(readJson);

      return readList.map((json) => NewsArticle.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // ============ CACHE METHODS (Offline Reading) ============

  @override
  Future<List<NewsArticle>> getCachedArticles() async {
    try {
      final cachedJson = prefs.getString(StorageKeys.cachedNews);

      if (cachedJson == null || cachedJson.isEmpty) {
        return [];
      }

      // Cek apakah cache masih valid (berdasarkan waktu)
      final lastUpdate = prefs.getString(StorageKeys.lastUpdateTime);
      if (lastUpdate != null) {
        final lastUpdateTime = DateTime.parse(lastUpdate);
        final now = DateTime.now();
        final difference = now.difference(lastUpdateTime);

        if (difference.inHours > AppConstants.cacheValidityHours) {
          print('⏰ Cache expired, clearing...');
          await clearCache();
          return [];
        }
      }

      final List<dynamic> cachedList = json.decode(cachedJson);

      print('📱 Loading ${cachedList.length} articles from cache');

      return cachedList.map((json) => NewsArticle.fromJson(json)).toList();
    } catch (e) {
      print('⚠️ Failed to load cache: $e');
      return [];
    }
  }

  @override
  Future<void> cacheArticles(List<NewsArticle> articles) async {
    try {
      // Limit cache size
      final articlesToCache =
          articles.take(AppConstants.maxCachedArticles).toList();

      final cachedJson = json.encode(
        articlesToCache.map((a) => a.toJson()).toList(),
      );

      await prefs.setString(StorageKeys.cachedNews, cachedJson);
      await prefs.setString(
        StorageKeys.lastUpdateTime,
        DateTime.now().toIso8601String(),
      );

      print('💾 Cached ${articlesToCache.length} articles');
    } catch (e) {
      // Tidak throw error, karena caching adalah optional
      print('⚠️ Failed to cache articles: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await prefs.remove(StorageKeys.cachedNews);
      await prefs.remove(StorageKeys.lastUpdateTime);
      print('🗑️ Cache cleared');
    } catch (e) {
      throw CacheException(
        message: 'Failed to clear cache',
        originalError: e,
      );
    }
  }
}
