import 'package:interufmt/core/data/models/news_model.dart';

final List<News> newsMock = [
  News(
    id: '1',
    title: 'Primeira Notícia',
    summary: 'Este é um resumo da primeira notícia.',
    body:
        'Este é o corpo completo da primeira notícia. Aqui você encontrará mais detalhes sobre o que aconteceu.',

    publishedAt: DateTime.now().subtract(const Duration(days: 1)),
    sourceUrl: 'https://example.com/news/1',
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    updatedAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
  News(
    id: '2',
    title: 'Segunda Notícia Esportiva',
    summary: 'Tudo sobre o último jogo.',
    body:
        'O jogo de ontem foi incrível, com muitos momentos emocionantes. A equipe da casa venceu por uma margem apertada.',
    imageUrl: 'https://picsum.photos/seed/2/600/400',
    publishedAt: DateTime.now().subtract(const Duration(hours: 12)),
    sourceUrl: 'https://example.com/news/2',
    createdAt: DateTime.now().subtract(const Duration(hours: 12)),
    updatedAt: DateTime.now().subtract(const Duration(hours: 12)),
  ),
  News(
    id: '3',
    title: 'Terceira Notícia: Tecnologia',
    summary: 'As últimas inovações em tecnologia.',
    body:
        'Uma nova tecnologia revolucionária foi anunciada hoje, prometendo mudar a forma como interagimos com nossos dispositivos.',
    imageUrl: 'https://picsum.photos/seed/3/600/400',
    publishedAt: DateTime.now().subtract(const Duration(hours: 6)),
    sourceUrl: 'https://example.com/news/3',
    createdAt: DateTime.now().subtract(const Duration(hours: 6)),
    updatedAt: DateTime.now().subtract(const Duration(hours: 6)),
  ),
];
