import '../models/news_model.dart';
import '../services/news_service.dart';

class NewsRepository {
  final NewsService _newsService;

  NewsRepository(this._newsService);

  /// Fetches published news with error handling
  Future<List<NewsModel>> getPublishedNews() async {
    try {
      return await _newsService.getPublishedNews();
    } catch (e) {
      // Log the error if needed
      throw Exception('Failed to load news: ${e.toString()}');
    }
  }
}
