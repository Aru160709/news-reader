import 'package:flutter/material.dart';
import 'package:news_reader/data/models/news_article.dart';
import 'package:news_reader/domain/repositories/news_repository.dart';
import 'package:news_reader/core/constants/api_constants.dart';
import 'package:news_reader/core/exceptions/app_exceptions.dart';

/// News Provider
/// Provider untuk manage state dari News features
/// Menggunakan ChangeNotifier untuk notifikasi perubahan state ke UI
class NewsProvider with ChangeNotifier {
  final NewsRepository repository;

  NewsProvider({required this.repository});

  // ============ STATE VARIABLES ============

  // Articles
  List<NewsArticle> _articles = [];
  List<NewsArticle> _bookmarkedArticles = [];
  List<NewsArticle> _searchResults = [];

  // Loading states
  bool _isLoading = false;
  final bool _isLoadingMore = false;
  bool _isSearching = false;

  // Error states
  String? _errorMessage;
  bool _hasError = false;

  // Filters
  String _selectedCategory = 'general';
  String _selectedCountry = AppConstants.defaultCountry;
  String _searchQuery = '';

  // Offline mode
  bool _isOfflineMode = false;

  // ============ GETTERS ============

  List<NewsArticle> get articles => _articles;
  List<NewsArticle> get bookmarkedArticles => _bookmarkedArticles;
  List<NewsArticle> get searchResults => _searchResults;

  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get isSearching => _isSearching;

  String? get errorMessage => _errorMessage;
  bool get hasError => _hasError;

  String get selectedCategory => _selectedCategory;
  String get selectedCountry => _selectedCountry;
  String get searchQuery => _searchQuery;

  bool get isOfflineMode => _isOfflineMode;
  bool get hasArticles => _articles.isNotEmpty;
  bool get hasBookmarks => _bookmarkedArticles.isNotEmpty;

  // ============ LOAD ARTICLES ============

  /// Load top headlines
  Future<void> loadTopHeadlines({bool refresh = false}) async {
    if (refresh) {
      _articles.clear();
    }

    _setLoading(true);
    _clearError();

    try {
      final articles = await repository.getTopHeadlines(
        country: _selectedCountry,
      );

      _articles = articles;
      _isOfflineMode = false;

      print('✅ Loaded ${articles.length} articles');
    } on NetworkException catch (e) {
      _handleError(e);
      _isOfflineMode = true;
      // Try to load from cache
      await _loadFromCache();
    } catch (e) {
      _handleError(e);
    } finally {
      _setLoading(false);
    }
  }

  /// Load news by category
  Future<void> loadNewsByCategory(String category) async {
    _selectedCategory = category;
    _articles.clear();
    _setLoading(true);
    _clearError();

    try {
      final articles = await repository.getNewsByCategory(
        category,
        country: _selectedCountry,
      );

      _articles = articles;
      _isOfflineMode = false;

      print('✅ Loaded ${articles.length} articles for category: $category');
    } on NetworkException catch (e) {
      _handleError(e);
      _isOfflineMode = true;
      await _loadFromCache();
    } catch (e) {
      _handleError(e);
    } finally {
      _setLoading(false);
    }
  }

  /// Search news
  Future<void> searchNews(String query) async {
    if (query.trim().isEmpty) {
      _searchResults.clear();
      _searchQuery = '';
      notifyListeners();
      return;
    }

    _searchQuery = query;
    _isSearching = true;
    _setLoading(true);
    _clearError();

    try {
      final articles = await repository.searchNews(query);

      _searchResults = articles;

      print('🔍 Found ${articles.length} results for: $query');
    } catch (e) {
      _handleError(e);
      _searchResults.clear();
    } finally {
      _setLoading(false);
      _isSearching = false;
    }
  }

  /// Clear search
  void clearSearch() {
    _searchQuery = '';
    _searchResults.clear();
    _isSearching = false;
    notifyListeners();
  }

  // ============ BOOKMARKS ============

  /// Load bookmarks
  Future<void> loadBookmarks() async {
    try {
      _bookmarkedArticles = await repository.getBookmarkedArticles();
      notifyListeners();
      print('📑 Loaded ${_bookmarkedArticles.length} bookmarks');
    } catch (e) {
      print('⚠️ Failed to load bookmarks: $e');
    }
  }

  /// Toggle bookmark
  Future<void> toggleBookmark(NewsArticle article) async {
    try {
      final isBookmarked = await repository.isArticleBookmarked(article.id);

      if (isBookmarked) {
        await repository.removeBookmark(article.id);
        _bookmarkedArticles.removeWhere((a) => a.id == article.id);
      } else {
        await repository.bookmarkArticle(article);
        _bookmarkedArticles.add(article.copyWith(isBookmarked: true));
      }

      notifyListeners();
    } catch (e) {
      _showSnackbarError('Failed to update bookmark');
    }
  }

  /// Check if article is bookmarked
  bool isBookmarked(String articleId) {
    return _bookmarkedArticles.any((a) => a.id == articleId);
  }

  /// Clear all bookmarks
  Future<void> clearAllBookmarks() async {
    try {
      await repository.clearAllBookmarks();
      _bookmarkedArticles.clear();
      notifyListeners();
    } catch (e) {
      _showSnackbarError('Failed to clear bookmarks');
    }
  }

  // ============ FILTERS ============

  /// Change category
  void changeCategory(String category) {
    if (_selectedCategory != category) {
      _selectedCategory = category;
      loadNewsByCategory(category);
    }
  }

  /// Change country
  void changeCountry(String country) {
    if (_selectedCountry != country) {
      _selectedCountry = country;
      loadTopHeadlines(refresh: true);
    }
  }

  // ============ MARK AS READ ============

  Future<void> markArticleAsRead(String articleId) async {
    try {
      await repository.markAsRead(articleId);
    } catch (e) {
      print('⚠️ Failed to mark as read: $e');
    }
  }

  // ============ CACHE & OFFLINE ============

  /// Load from cache (untuk offline mode)
  Future<void> _loadFromCache() async {
    try {
      final cachedArticles = await repository.getCachedArticles();

      if (cachedArticles.isNotEmpty) {
        _articles = cachedArticles;
        _isOfflineMode = true;
        print(
            '📱 Loaded ${cachedArticles.length} articles from cache (offline mode)');
      }
    } catch (e) {
      print('⚠️ Failed to load from cache: $e');
    }
  }

  /// Clear cache
  Future<void> clearCache() async {
    try {
      await repository.clearCache();
      print('🗑️ Cache cleared');
    } catch (e) {
      _showSnackbarError('Failed to clear cache');
    }
  }

  // ============ HELPER METHODS ============

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _hasError = false;
    _errorMessage = null;
  }

  void _handleError(dynamic error) {
    _hasError = true;
    _errorMessage = ExceptionHandler.getUserMessage(error);
    print('❌ Error: $_errorMessage');
    notifyListeners();
  }

  void _showSnackbarError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Retry last action (setelah error)
  Future<void> retry() async {
    _clearError();

    if (_searchQuery.isNotEmpty) {
      await searchNews(_searchQuery);
    } else if (_selectedCategory != 'general') {
      await loadNewsByCategory(_selectedCategory);
    } else {
      await loadTopHeadlines(refresh: true);
    }
  }

  // ============ DISPOSE ============

  @override
  void dispose() {
    _articles.clear();
    _bookmarkedArticles.clear();
    _searchResults.clear();
    super.dispose();
  }
}
