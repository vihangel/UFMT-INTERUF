import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/news_model.dart';

class NewsService {
  final SupabaseClient _client;

  NewsService(this._client);

  /// Fetches published news from Supabase
  /// Executes: SELECT id, title, summary, image_url FROM news
  /// WHERE published_at IS NOT NULL AND published_at <= now()
  /// ORDER BY published_at DESC
  Future<List<NewsModel>> getPublishedNews() async {
    try {
      final response = await _client
          .from('news')
          .select('id, title, summary, image_url')
          .not('published_at', 'is', null)
          .lte('published_at', DateTime.now().toIso8601String())
          .order('published_at', ascending: false);

      return (response as List)
          .map((json) => NewsModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch news: $e');
    }
  }
}
