// lib/features/users/pagina_noticias.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interufmt/features/users/home/home_page.dart';
import 'package:interufmt/features/users/news/viewmodel/news_viewmodel.dart';
import 'package:interufmt/features/users/news/widget/news_widget.dart';
import 'package:provider/provider.dart';

class NewsPage extends StatefulWidget {
  static const String routename = 'noticias';
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NewsViewModel>().fetchNews();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<NewsViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notícias'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.goNamed(HomePage.routename);
          },
        ),
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : viewModel.errorMessage != null
          ? Center(child: Text(viewModel.errorMessage!))
          : viewModel.news.isEmpty
          ? const Center(child: Text('Nenhuma notícia disponível.'))
          : ListView.builder(
              itemCount: viewModel.news.length,
              itemBuilder: (context, index) {
                final news = viewModel.news[index];
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
