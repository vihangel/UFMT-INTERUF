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

    final response = await client.from(AppSupabaseTables.news).select().lt('published_at', DateTime.now());
    final newsList = response as List;
    return newsList.map((item) => News.fromJson(item)).toList();
  }
}
