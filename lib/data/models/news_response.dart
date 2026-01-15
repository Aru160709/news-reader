import 'news_article.dart';

/// News Response Model
/// Model untuk response dari berbagai API
class NewsResponse {
  final String status;
  final int totalResults;
  final List<NewsArticle> articles;
  final String? message; // Error message jika ada
  final String apiSource;

  NewsResponse({
    required this.status,
    required this.totalResults,
    required this.articles,
    this.message,
    required this.apiSource,
  });

  /// Factory untuk GNews API Response
  factory NewsResponse.fromGNews(Map<String, dynamic> json) {
    final articlesJson = json['articles'] as List? ?? [];

    return NewsResponse(
      status: 'ok',
      totalResults: json['totalArticles'] ?? articlesJson.length,
      articles: articlesJson
          .map((article) => NewsArticle.fromGNews(article))
          .toList(),
      apiSource: 'gnews',
    );
  }

  /// Factory untuk NewsAPI.org Response
  factory NewsResponse.fromNewsApi(Map<String, dynamic> json) {
    final articlesJson = json['articles'] as List? ?? [];

    return NewsResponse(
      status: json['status'] ?? 'ok',
      totalResults: json['totalResults'] ?? articlesJson.length,
      articles: articlesJson
          .map((article) => NewsArticle.fromNewsApi(article))
          .toList(),
      message: json['message'],
      apiSource: 'newsapi',
    );
  }

  /// Factory untuk Currents API Response
  factory NewsResponse.fromCurrents(Map<String, dynamic> json) {
    final articlesJson = json['news'] as List? ?? [];

    return NewsResponse(
      status: json['status'] ?? 'ok',
      totalResults: articlesJson.length,
      articles: articlesJson
          .map((article) => NewsArticle.fromCurrents(article))
          .toList(),
      apiSource: 'currents',
    );
  }

  /// Factory untuk NewsData.io Response
  factory NewsResponse.fromNewsData(Map<String, dynamic> json) {
    final articlesJson = json['results'] as List? ?? [];

    return NewsResponse(
      status: json['status'] ?? 'ok',
      totalResults: json['totalResults'] ?? articlesJson.length,
      articles: articlesJson
          .map((article) => NewsArticle.fromNewsData(article))
          .toList(),
      apiSource: 'newsdata',
    );
  }

  /// Factory untuk Mediastack API Response
  factory NewsResponse.fromMediastack(Map<String, dynamic> json) {
    final articlesJson = json['data'] as List? ?? [];

    return NewsResponse(
      status: 'ok',
      totalResults: json['pagination']?['total'] ?? articlesJson.length,
      articles: articlesJson
          .map((article) => NewsArticle.fromMediastack(article))
          .toList(),
      apiSource: 'mediastack',
    );
  }

  /// Check if response has articles
  bool get hasArticles => articles.isNotEmpty;

  /// Check if response is successful
  bool get isSuccess => status == 'ok' || status == 'success';

  @override
  String toString() {
    return 'NewsResponse(status: $status, totalResults: $totalResults, articlesCount: ${articles.length}, apiSource: $apiSource)';
  }
}
