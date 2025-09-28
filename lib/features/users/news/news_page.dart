// lib/features/users/pagina_noticias.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interufmt/features/pagina_noticias/pagina_noticia_detalhes.dart';
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
      body: RefreshIndicator(
        onRefresh: () => context.read<NewsViewModel>().fetchNews(),
        child: viewModel.isLoading
            ? const Center(child: CircularProgressIndicator())
            : viewModel.errorMessage != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Erro ao carregar notícias',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      viewModel.errorMessage!,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<NewsViewModel>().fetchNews(),
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              )
            : viewModel.news.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.article_outlined, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Nenhuma notícia encontrada',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: viewModel.news.length,
                itemBuilder: (context, index) {
                  final news = viewModel.news[index];
                  return NewsWidget(
                    imageUrl: news.imageUrl ?? '',
                    title: news.title,
                    summary: news.summary ?? 'Sem resumo disponível',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              PaginaNoticiaDetalhes(newsId: news.id),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}
