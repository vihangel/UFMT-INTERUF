import 'package:flutter/material.dart';
import 'package:interufmt/core/data/models/news_model.dart';
import 'package:interufmt/core/data/repositories/news_repository.dart';

class NewsViewModel extends ChangeNotifier {
  final NewsRepository _newsRepository;

  NewsViewModel(this._newsRepository);

  List<News> _news = [];
  List<News> get news => _news;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchNews() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _news = await _newsRepository.getNews();
    } catch (e) {
      _errorMessage =
          'Falha ao carregar notícias. Por favor, tente novamente mais tarde.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
