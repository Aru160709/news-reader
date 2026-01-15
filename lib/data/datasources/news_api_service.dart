import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:news_reader/core/constants/api_constants.dart';
import 'package:news_reader/core/exceptions/app_exceptions.dart';
import 'package:news_reader/data/models/news_response.dart';

/// News API Service
/// Service untuk mengambil data dari berbagai News API
class NewsApiService {
  final http.Client client;

  NewsApiService({http.Client? client}) : client = client ?? http.Client();

  /// Base method untuk HTTP GET request dengan error handling
  Future<Map<String, dynamic>> _getRequest(String url,
      {Map<String, String>? headers}) async {
    try {
      print('📡 API Request: $url'); // Debug log

      final response = await client
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: ApiConstants.requestTimeout));

      print('📥 API Response Status: ${response.statusCode}'); // Debug log

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return data;
      } else {
        throw ApiException.fromStatusCode(
          response.statusCode,
          message: 'API request failed',
        );
      }
    } on TimeoutException {
      throw TimeoutException(
          message:
              'Request timeout after ${ApiConstants.requestTimeout} seconds');
    } on http.ClientException catch (e) {
      throw NetworkException(
          message: 'Network error: ${e.message}', originalError: e);
    } on FormatException catch (e) {
      throw ParseException(
          message: 'Failed to parse API response', originalError: e);
    } catch (e) {
      throw ExceptionHandler.handleError(e);
    }
  }

  // ============ GNEWS API ============

  /// Get top headlines dari GNews
  Future<NewsResponse> getGNewsTopHeadlines({
    String? category,
    String? country,
    String? query,
    int max = 10,
  }) async {
    try {
      String url = '${ApiConstants.gnewsBaseUrl}/top-headlines?'
          'apikey=${ApiConstants.gnewsApiKey}'
          '&max=$max'
          '&lang=en';

      if (category != null && category != 'general') {
        url += '&topic=$category';
      }
      if (country != null) {
        url += '&country=$country';
      }
      if (query != null && query.isNotEmpty) {
        url += '&q=${Uri.encodeComponent(query)}';
      }

      final data = await _getRequest(url);
      return NewsResponse.fromGNews(data);
    } catch (e) {
      throw ExceptionHandler.handleError(e);
    }
  }

  /// Search news di GNews
  Future<NewsResponse> searchGNews(String query, {int max = 10}) async {
    try {
      final url = '${ApiConstants.gnewsBaseUrl}/search?'
          'apikey=${ApiConstants.gnewsApiKey}'
          '&q=${Uri.encodeComponent(query)}'
          '&max=$max'
          '&lang=en';

      final data = await _getRequest(url);
      return NewsResponse.fromGNews(data);
    } catch (e) {
      throw ExceptionHandler.handleError(e);
    }
  }

  // ============ NEWSAPI.ORG ============

  /// Get top headlines dari NewsAPI.org
  Future<NewsResponse> getNewsApiTopHeadlines({
    String? category,
    String? country,
    String? query,
    int pageSize = 20,
  }) async {
    try {
      String url = '${ApiConstants.newsApiBaseUrl}/top-headlines?'
          'apiKey=${ApiConstants.newsApiKey}'
          '&pageSize=$pageSize';

      if (category != null && category != 'general') {
        url += '&category=$category';
      }
      if (country != null) {
        url += '&country=$country';
      }
      if (query != null && query.isNotEmpty) {
        url += '&q=${Uri.encodeComponent(query)}';
      }

      final data = await _getRequest(url);
      return NewsResponse.fromNewsApi(data);
    } catch (e) {
      throw ExceptionHandler.handleError(e);
    }
  }

  /// Search news di NewsAPI.org
  Future<NewsResponse> searchNewsApi(String query, {int pageSize = 20}) async {
    try {
      final url = '${ApiConstants.newsApiBaseUrl}/everything?'
          'apiKey=${ApiConstants.newsApiKey}'
          '&q=${Uri.encodeComponent(query)}'
          '&pageSize=$pageSize'
          '&sortBy=publishedAt';

      final data = await _getRequest(url);
      return NewsResponse.fromNewsApi(data);
    } catch (e) {
      throw ExceptionHandler.handleError(e);
    }
  }

  // ============ CURRENTS API ============

  /// Get latest news dari Currents API
  Future<NewsResponse> getCurrentsLatestNews({
    String? category,
    String? language = 'en',
  }) async {
    try {
      String url = '${ApiConstants.currentsBaseUrl}/latest-news?'
          'apiKey=${ApiConstants.currentsApiKey}';

      if (category != null && category != 'general') {
        url += '&category=$category';
      }
      if (language != null) {
        url += '&language=$language';
      }

      final data = await _getRequest(url);
      return NewsResponse.fromCurrents(data);
    } catch (e) {
      throw ExceptionHandler.handleError(e);
    }
  }

  /// Search news di Currents API
  Future<NewsResponse> searchCurrents(String query,
      {String language = 'en'}) async {
    try {
      final url = '${ApiConstants.currentsBaseUrl}/search?'
          'apiKey=${ApiConstants.currentsApiKey}'
          '&keywords=${Uri.encodeComponent(query)}'
          '&language=$language';

      final data = await _getRequest(url);
      return NewsResponse.fromCurrents(data);
    } catch (e) {
      throw ExceptionHandler.handleError(e);
    }
  }

  // ============ NEWSDATA.IO ============

  /// Get news dari NewsData.io
  Future<NewsResponse> getNewsDataNews({
    String? category,
    String? country,
    String? query,
    String language = 'en',
  }) async {
    try {
      String url = '${ApiConstants.newsDataBaseUrl}/news?'
          'apikey=${ApiConstants.newsDataApiKey}'
          '&language=$language';

      if (category != null && category != 'general') {
        url += '&category=$category';
      }
      if (country != null) {
        url += '&country=$country';
      }
      if (query != null && query.isNotEmpty) {
        url += '&q=${Uri.encodeComponent(query)}';
      }

      final data = await _getRequest(url);
      return NewsResponse.fromNewsData(data);
    } catch (e) {
      throw ExceptionHandler.handleError(e);
    }
  }

  // ============ MEDIASTACK API ============

  /// Get news dari Mediastack API
  Future<NewsResponse> getMediastackNews({
    String? category,
    String? country,
    String? query,
    int limit = 25,
  }) async {
    try {
      String url = '${ApiConstants.mediastackBaseUrl}/news?'
          'access_key=${ApiConstants.mediastackApiKey}'
          '&limit=$limit'
          '&languages=en';

      if (category != null && category != 'general') {
        url += '&categories=$category';
      }
      if (country != null) {
        url += '&countries=$country';
      }
      if (query != null && query.isNotEmpty) {
        url += '&keywords=${Uri.encodeComponent(query)}';
      }

      final data = await _getRequest(url);
      return NewsResponse.fromMediastack(data);
    } catch (e) {
      throw ExceptionHandler.handleError(e);
    }
  }

  // ============ SMART API SELECTOR ============

  /// Get news dengan automatic fallback ke API lain jika gagal
  Future<NewsResponse> getNewsWithFallback({
    String? category,
    String? country,
    String? query,
  }) async {
    // List API yang akan dicoba secara berurutan
    final apiMethods = [
      () => getGNewsTopHeadlines(
          category: category, country: country, query: query),
      () => getNewsApiTopHeadlines(
          category: category, country: country, query: query),
      () => getCurrentsLatestNews(category: category),
      () => getNewsDataNews(category: category, country: country, query: query),
      () =>
          getMediastackNews(category: category, country: country, query: query),
    ];

    AppException? lastError;

    // Coba setiap API sampai ada yang berhasil
    for (var apiMethod in apiMethods) {
      try {
        print('🔄 Trying API...');
        final response = await apiMethod();

        if (response.hasArticles) {
          print('✅ Success with ${response.apiSource}!');
          return response;
        }
      } catch (e) {
        print('❌ Failed: $e');
        lastError = ExceptionHandler.handleError(e);
        continue; // Try next API
      }
    }

    // Jika semua API gagal
    throw lastError ?? AppException(message: 'All API sources failed');
  }

  /// Search dengan fallback
  Future<NewsResponse> searchWithFallback(String query) async {
    final apiMethods = [
      () => searchGNews(query),
      () => searchNewsApi(query),
      () => searchCurrents(query),
    ];

    AppException? lastError;

    for (var apiMethod in apiMethods) {
      try {
        final response = await apiMethod();
        if (response.hasArticles) {
          return response;
        }
      } catch (e) {
        lastError = ExceptionHandler.handleError(e);
        continue;
      }
    }

    throw lastError ??
        NoDataException(message: 'No results found for "$query"');
  }

  /// Dispose client
  void dispose() {
    client.close();
  }
}
