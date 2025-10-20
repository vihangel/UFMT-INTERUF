import 'package:interufmt/core/data/models/news_model.dart';
import 'package:interufmt/core/data/services/news_service.dart';

class NewsRepository {
  final NewsService _newsService;

  NewsRepository(this._newsService);

  Future<List<News>> getNews() {
    return _newsService.getNews();
  }

  // Admin CRUD methods
  Future<List<News>> getAllNews() {
    return _newsService.getAllNews();
  }

  Future<News> createNews({
    required String title,
    String? summary,
    String? body,
    String? imageUrl,
    DateTime? publishedAt,
    String? sourceUrl,
  }) {
    return _newsService.createNews(
      title: title,
      summary: summary,
      body: body,
      imageUrl: imageUrl,
      publishedAt: publishedAt,
      sourceUrl: sourceUrl,
    );
  }

  Future<News> updateNews({
    required String id,
    required String title,
    String? summary,
    String? body,
    String? imageUrl,
    DateTime? publishedAt,
    String? sourceUrl,
  }) {
    return _newsService.updateNews(
      id: id,
      title: title,
      summary: summary,
      body: body,
      imageUrl: imageUrl,
      publishedAt: publishedAt,
      sourceUrl: sourceUrl,
    );
  }

  Future<void> deleteNews(String id) {
    return _newsService.deleteNews(id);
  }
}
