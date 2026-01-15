/// API Constants
/// File ini berisi semua konfigurasi API yang digunakan
class ApiConstants {
  // ============ NewsData.io API ============
  static const String newsDataBaseUrl = 'https://newsdata.io/api/1';
  static const String newsDataApiKey = 'pub_8a4f8a1c8007448a921d3ede61e0f00b';

  // ============ Currents API ============
  static const String currentsBaseUrl = 'https://api.currentsapi.services/v1';
  static const String currentsApiKey =
      '1f4kxFWKUMBcuAHALrJca9iRdPAjTHETMwdA5i45xID1-6dw';

  // ============ GNews API ============
  static const String gnewsBaseUrl = 'https://gnews.io/api/v4';
  static const String gnewsApiKey = 'c162ee64d3d842a9dd66aefe426504ec';

  // ============ NewsAPI.org ============
  static const String newsApiBaseUrl = 'https://newsapi.org/v2';
  static const String newsApiKey = 'dcd530d9f04c4d39adf527c04d3a2d59';

  // ============ Mediastack API ============
  static const String mediastackBaseUrl = 'http://api.mediastack.com/v1';
  static const String mediastackApiKey = '119c11c2febc783f983f1dd7faefb235';

  // ============ Default Settings ============
  static const String defaultApiSource =
      'gnews'; // gnews, newsapi, currents, newsdata, mediastack
  static const int requestTimeout = 30; // detik
  static const int maxRetries = 3;
}

/// App Constants
/// Konstanta umum aplikasi
class AppConstants {
  static const String appName = 'News Reader Pro';
  static const String appVersion = '1.0.0';

  // Kategori berita (disesuaikan dengan API)
  static const List<String> categories = [
    'general',
    'business',
    'technology',
    'sports',
    'entertainment',
    'science',
    'health',
  ];

  // Negara untuk filter berita
  static const List<Map<String, String>> countries = [
    {'code': 'us', 'name': 'United States'},
    {'code': 'id', 'name': 'Indonesia'},
    {'code': 'gb', 'name': 'United Kingdom'},
    {'code': 'au', 'name': 'Australia'},
    {'code': 'ca', 'name': 'Canada'},
  ];

  static const String defaultCountry = 'us';
  static const String defaultLanguage = 'en';

  // Cache settings
  static const int cacheValidityHours = 1;
  static const int maxCachedArticles = 100;

  // UI Settings
  static const int itemsPerPage = 20;
  static const double cardElevation = 2.0;
  static const double borderRadius = 12.0;
}

/// Storage Keys
/// Key untuk menyimpan data di local storage
class StorageKeys {
  static const String themeMode = 'theme_mode';
  static const String language = 'language';
  static const String bookmarks = 'bookmarks';
  static const String readArticles = 'read_articles';
  static const String selectedCountry = 'selected_country';
  static const String selectedCategory = 'selected_category';
  static const String cachedNews = 'cached_news';
  static const String lastUpdateTime = 'last_update_time';
}

/// Error Messages
class ErrorMessages {
  static const String noInternet =
      'No internet connection. Please check your network.';
  static const String serverError = 'Server error. Please try again later.';
  static const String apiLimitReached =
      'API request limit reached. Please try again later.';
  static const String invalidApiKey =
      'Invalid API key. Please check your configuration.';
  static const String unknownError = 'An unexpected error occurred.';
  static const String noDataFound = 'No news found. Try different keywords.';
  static const String loadingFailed = 'Failed to load news. Please try again.';
}
