/// News Article Model
/// Model untuk merepresentasikan data berita
/// Support untuk multiple API sources (NewsAPI, GNews, Currents, dll)
library;

class NewsArticle {
  final String id; // Unique identifier
  final String title;
  final String description;
  final String content;
  final String url;
  final String? imageUrl;
  final String? author;
  final String source;
  final DateTime publishedAt;
  final String? category;
  final String? language;
  final String? country;

  // Metadata tambahan
  final String apiSource; // API mana yang digunakan (gnews, newsapi, dll)
  final bool isBookmarked;
  final bool isRead;

  NewsArticle({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.url,
    this.imageUrl,
    this.author,
    required this.source,
    required this.publishedAt,
    this.category,
    this.language,
    this.country,
    required this.apiSource,
    this.isBookmarked = false,
    this.isRead = false,
  });

  /// Factory constructor untuk GNews API
  factory NewsArticle.fromGNews(Map<String, dynamic> json) {
    return NewsArticle(
      id: json['url'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? '',
      content: json['content'] ?? json['description'] ?? '',
      url: json['url'] ?? '',
      imageUrl: json['image'],
      author: json['source']?['name'],
      source: json['source']?['name'] ?? 'Unknown',
      publishedAt: DateTime.parse(
          json['publishedAt'] ?? DateTime.now().toIso8601String()),
      apiSource: 'gnews',
    );
  }

  /// Factory constructor untuk NewsAPI.org
  factory NewsArticle.fromNewsApi(Map<String, dynamic> json) {
    return NewsArticle(
      id: json['url'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? '',
      content: json['content'] ?? json['description'] ?? '',
      url: json['url'] ?? '',
      imageUrl: json['urlToImage'],
      author: json['author'],
      source: json['source']?['name'] ?? 'Unknown',
      publishedAt: DateTime.parse(
          json['publishedAt'] ?? DateTime.now().toIso8601String()),
      apiSource: 'newsapi',
    );
  }

  /// Factory constructor untuk Currents API
  factory NewsArticle.fromCurrents(Map<String, dynamic> json) {
    return NewsArticle(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? '',
      content: json['description'] ??
          '', // Currents tidak punya field content terpisah
      url: json['url'] ?? '',
      imageUrl: json['image'],
      author: json['author'],
      source: 'Currents',
      publishedAt:
          DateTime.parse(json['published'] ?? DateTime.now().toIso8601String()),
      category: (json['category'] as List?)?.first,
      language: json['language'],
      country: json['country'],
      apiSource: 'currents',
    );
  }

  /// Factory constructor untuk NewsData.io
  factory NewsArticle.fromNewsData(Map<String, dynamic> json) {
    return NewsArticle(
      id: json['article_id'] ??
          json['link'] ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? '',
      content: json['content'] ?? json['description'] ?? '',
      url: json['link'] ?? '',
      imageUrl: json['image_url'],
      author: (json['creator'] as List?)?.first,
      source: json['source_id'] ?? 'Unknown',
      publishedAt:
          DateTime.parse(json['pubDate'] ?? DateTime.now().toIso8601String()),
      category: (json['category'] as List?)?.first,
      language: json['language'],
      country: (json['country'] as List?)?.first,
      apiSource: 'newsdata',
    );
  }

  /// Factory constructor untuk Mediastack API
  factory NewsArticle.fromMediastack(Map<String, dynamic> json) {
    return NewsArticle(
      id: json['url'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? '',
      content: json['description'] ??
          '', // Mediastack tidak punya field content terpisah
      url: json['url'] ?? '',
      imageUrl: json['image'],
      author: json['author'],
      source: json['source'] ?? 'Unknown',
      publishedAt: DateTime.parse(
          json['published_at'] ?? DateTime.now().toIso8601String()),
      category: json['category'],
      language: json['language'],
      country: json['country'],
      apiSource: 'mediastack',
    );
  }

  /// Convert to JSON (untuk bookmark/cache)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'content': content,
      'url': url,
      'imageUrl': imageUrl,
      'author': author,
      'source': source,
      'publishedAt': publishedAt.toIso8601String(),
      'category': category,
      'language': language,
      'country': country,
      'apiSource': apiSource,
      'isBookmarked': isBookmarked,
      'isRead': isRead,
    };
  }

  /// Create from JSON (untuk load bookmark/cache)
  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      id: json['id'] ?? '',
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? '',
      content: json['content'] ?? '',
      url: json['url'] ?? '',
      imageUrl: json['imageUrl'],
      author: json['author'],
      source: json['source'] ?? 'Unknown',
      publishedAt: DateTime.parse(
          json['publishedAt'] ?? DateTime.now().toIso8601String()),
      category: json['category'],
      language: json['language'],
      country: json['country'],
      apiSource: json['apiSource'] ?? 'unknown',
      isBookmarked: json['isBookmarked'] ?? false,
      isRead: json['isRead'] ?? false,
    );
  }

  /// Copy with method (untuk update properties)
  NewsArticle copyWith({
    String? id,
    String? title,
    String? description,
    String? content,
    String? url,
    String? imageUrl,
    String? author,
    String? source,
    DateTime? publishedAt,
    String? category,
    String? language,
    String? country,
    String? apiSource,
    bool? isBookmarked,
    bool? isRead,
  }) {
    return NewsArticle(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      url: url ?? this.url,
      imageUrl: imageUrl ?? this.imageUrl,
      author: author ?? this.author,
      source: source ?? this.source,
      publishedAt: publishedAt ?? this.publishedAt,
      category: category ?? this.category,
      language: language ?? this.language,
      country: country ?? this.country,
      apiSource: apiSource ?? this.apiSource,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      isRead: isRead ?? this.isRead,
    );
  }

  /// Helper method untuk cek apakah artikel punya gambar
  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  /// Helper method untuk mendapatkan author atau source
  String get displayAuthor => author ?? source;

  /// Helper method untuk mendapatkan excerpt (150 karakter pertama)
  String get excerpt {
    if (description.length <= 150) return description;
    return '${description.substring(0, 150)}...';
  }

  @override
  String toString() {
    return 'NewsArticle(id: $id, title: $title, source: $source, apiSource: $apiSource)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NewsArticle && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
