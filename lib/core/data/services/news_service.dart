import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:interufmt/core/data/mocks/news_mock.dart';
import 'package:interufmt/core/data/models/news_model.dart';
import 'package:interufmt/core/utils/app_supabase_tables.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NewsService {
  final SupabaseClient client;
  final bool useMock = false;

  NewsService(this.client);

  Future<List<News>> getNews() async {
    if (useMock && kDebugMode) {
      log('Using news mock data');
      await Future.delayed(const Duration(seconds: 1));
      return newsMock;
    }

    final response = await client
        .from(AppSupabaseTables.news)
        .select()
        .lt('published_at', DateTime.now());
    final newsList = response as List;
    return newsList.map((item) => News.fromJson(item)).toList();
  }

  // Admin CRUD methods
  Future<List<News>> getAllNews() async {
    final response = await client
        .from(AppSupabaseTables.news)
        .select()
        .order('published_at', ascending: false);
    final newsList = response as List;
    return newsList.map((item) => News.fromJson(item)).toList();
  }

  Future<News> createNews({
    required String title,
    String? summary,
    String? body,
    String? imageUrl,
    DateTime? publishedAt,
    String? sourceUrl,
  }) async {
    final response = await client
        .from(AppSupabaseTables.news)
        .insert({
          'title': title,
          'summary': summary,
          'body': body,
          'image_url': imageUrl,
          'published_at': publishedAt?.toIso8601String(),
          'source_url': sourceUrl,
        })
        .select()
        .single();

    return News.fromJson(response);
  }

  Future<News> updateNews({
    required String id,
    required String title,
    String? summary,
    String? body,
    String? imageUrl,
    DateTime? publishedAt,
    String? sourceUrl,
  }) async {
    final response = await client
        .from(AppSupabaseTables.news)
        .update({
          'title': title,
          'summary': summary,
          'body': body,
          'image_url': imageUrl,
          'published_at': publishedAt?.toIso8601String(),
          'source_url': sourceUrl,
        })
        .eq('id', id)
        .select()
        .single();

    return News.fromJson(response);
  }

  Future<void> deleteNews(String id) async {
    await client.from(AppSupabaseTables.news).delete().eq('id', id);
  }
}
