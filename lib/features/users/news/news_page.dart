// lib/features/users/pagina_noticias.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interufmt/core/data/mocks/news_mock.dart';
import 'package:interufmt/features/users/news/widget/news_widget.dart';

class NewsPage extends StatelessWidget {
  static const String routename = 'noticias';
  const NewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notícias'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/home');
          },
        ),
      ),
      body: ListView.builder(
        itemCount: newsMock.length,
        itemBuilder: (context, index) {
          final news = newsMock[index];
          return NewsWidget(
            imageUrl: news.imageUrl!,
            title: news.title,
            description: news.summary!,
          );
        },
      ),
    );
  }
}
