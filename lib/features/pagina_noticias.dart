// lib/features/users/pagina_noticias.dart

import 'package:flutter/material.dart';
import 'package:interufmt/core/widgets/noticias.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pagina_noticias/models/news_model.dart';
import 'pagina_noticias/services/news_service.dart';
import 'pagina_noticias/repositories/news_repository.dart';

class PaginaNoticias extends StatefulWidget {
  const PaginaNoticias({super.key});

  @override
  State<PaginaNoticias> createState() => _PaginaNoticiasState();
}

class _PaginaNoticiasState extends State<PaginaNoticias> {
  late NewsRepository _newsRepository;
  late Future<List<NewsModel>> _newsFuture;

  @override
  void initState() {
    super.initState();
    final newsService = NewsService(Supabase.instance.client);
    _newsRepository = NewsRepository(newsService);
    _newsFuture = _newsRepository.getPublishedNews();
  }

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
      body: FutureBuilder<List<NewsModel>>(
        future: _newsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Erro ao carregar notícias',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _newsFuture = _newsRepository.getPublishedNews();
                      });
                    },
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          final newsList = snapshot.data ?? [];

          if (newsList.isEmpty) {
            return const Center(
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
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _newsFuture = _newsRepository.getPublishedNews();
              });
              await _newsFuture;
            },
            child: ListView.builder(
              itemCount: newsList.length,
              itemBuilder: (context, index) {
                final news = newsList[index];
                return Noticias(
                  imageUrl: news.imageUrl,
                  title: news.title,
                  summary: news.summary,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
