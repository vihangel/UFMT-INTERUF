import 'package:interufmt/core/data/models/news_model.dart';
import 'package:interufmt/core/data/services/news_service.dart';

class NewsRepository {
  final NewsService _newsService;

  NewsRepository(this._newsService);

  Future<List<News>> getNews() {
    return _newsService.getNews();
  }
}
