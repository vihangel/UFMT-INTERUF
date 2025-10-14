// lib/features/users/escolha_atletica_page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EscolhaAtleticaPage extends StatefulWidget {
  static const String routename = 'escolha_atletica';
  const EscolhaAtleticaPage({super.key});

  @override
  EscolhaAtleticaPageState createState() => EscolhaAtleticaPageState();
}

class EscolhaAtleticaPageState extends State<EscolhaAtleticaPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentPageIndex = 0;
  List<Map<String, dynamic>> _currentSeries = [];
  String _currentSeriesName = 'Série A';
  double _pageOffset = 0.0;

  List<Map<String, dynamic>> _serieA = [];
  List<Map<String, dynamic>> _serieB = [];
  bool _isLoading = true;
  String? _errorMessage;

  final Map<int, PageController> _tabPageControllers = {};

  // Helper function to get the correct asset path for athletic logos
  String? _getAtleticAssetPath(String? logoUrl) {
    if (logoUrl == null || logoUrl.isEmpty) return null;
    return 'assets/images/$logoUrl';
  }

  /*
 Future<void> _incrementTorcidometro(String athleticId) async {
  // A classe Postgrest é a correta para usar o incremento
  final postgrest = Supabase.instance.client.from('torcidometro');
  
  try {
    // Tenta incrementar o campo 'pontos_torcida' em 1 para a atlética
    await postgrest
        .update({'pontos_torcida': postgrest.increment(1)}) 
        .eq('athletic_id', athleticId)
        .single();
        
  } catch (e) {
    // Se a linha não existir (primeiro voto), a gente a cria (INSERT)
    if (e.toString().contains('no rows found')) {
       await Supabase.instance.client
           .from('torcidometro')
           .insert({'athletic_id': athleticId, 'pontos_torcida': 1});
    }
    print('Erro ao atualizar torcidometro: $e');
  }
}
*/
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAthletics();

    _tabController.addListener(() {
      setState(() {
        if (_tabController.index == 0) {
          _currentSeries = _serieA;
          _currentSeriesName = 'Série A';
        } else {
          _currentSeries = _serieB;
          _currentSeriesName = 'Série B';
        }
        _currentPageIndex =
            _tabPageControllers[_tabController.index]?.page?.round() ?? 0;
        _pageOffset =
            _tabPageControllers[_tabController.index]?.page ??
            _tabPageControllers[_tabController.index]?.initialPage.toDouble() ??
            0.0;
      });
    });
  }

  Future<void> _loadAthletics() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final serieAResponse = await Supabase.instance.client
          .from('athletics')
          .select('id, nickname, name, logo_url, series')
          .eq('series', 'A')
          .order('nickname');

      final serieBResponse = await Supabase.instance.client
          .from('athletics')
          .select('id, nickname, name, logo_url, series')
          .eq('series', 'B')
          .order('nickname');

      setState(() {
        _serieA = List<Map<String, dynamic>>.from(serieAResponse);
        _serieB = List<Map<String, dynamic>>.from(serieBResponse);
        _currentSeries = _serieA;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erro ao carregar atléticas: $error';
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tabPageControllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  void _saveAndNavigate() async {
    if (_currentSeries.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final chosenAtletica = _currentSeries[_currentPageIndex];

    await prefs.setString('chosen_athletic_name', chosenAtletica['nickname']!);
    await prefs.setString('chosen_athletic_id', chosenAtletica['id']!);
    await prefs.setString('chosen_athletic_series', _currentSeriesName);

    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Column(
          children: [
            Expanded(child: Center(child: CircularProgressIndicator())),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadAthletics,
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_serieA.isEmpty && _serieB.isEmpty) {
      return Scaffold(
        body: Column(
          children: [
            Expanded(child: Center(child: Text('Nenhuma atlética encontrada'))),
          ],
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Escolha uma Atlética',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    TabBar(
                      controller: _tabController,
                      tabs: const [
                        Tab(text: 'Série A'),
                        Tab(text: 'Série B'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: MediaQuery.of(context).size.width * 0.7,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildCarousel(_serieA, 0),
                          _buildCarousel(_serieB, 1),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_currentSeries.isNotEmpty) ...[
                      Text(
                        _currentSeries[_currentPageIndex]['nickname']!,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _currentSeries[_currentPageIndex]['name'] ?? 'Sem nome',
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const Spacer(),
                    ElevatedButton(
                      onPressed: _currentSeries.isNotEmpty
                          ? _saveAndNavigate
                          : null,
                      child: const Text('Escolher'),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Você poderá mudar no futuro. Sua escolha influencia no Torcidômetro',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarousel(List<Map<String, dynamic>> series, int tabIndex) {
    if (series.isEmpty) {
      return const Center(
        child: Text('Nenhuma atlética encontrada nesta série'),
      );
    }

    if (!_tabPageControllers.containsKey(tabIndex)) {
      _tabPageControllers[tabIndex] = PageController(viewportFraction: 0.6);
      _tabPageControllers[tabIndex]!.addListener(() {
        if (_tabController.index == tabIndex) {
          setState(() {
            _pageOffset = _tabPageControllers[tabIndex]!.page!;
            _currentPageIndex = _pageOffset.round();
          });
        }
      });
    }

    return PageView.builder(
      controller: _tabPageControllers[tabIndex],
      itemCount: series.length,
      itemBuilder: (context, index) {
        double scale = 1.0;
        double opacity = 1.0;

        double page = _tabPageControllers[tabIndex]?.page ?? index.toDouble();
        double diff = (index - page).abs();

        scale = 1.0 - (diff * 0.2);
        scale = scale.clamp(0.6, 1.0);

        opacity = 1.0 - (diff * 0.5);
        opacity = opacity.clamp(0.5, 1.0);

        final logoUrl = series[index]['logo_url'] as String?;
        final assetPath = _getAtleticAssetPath(logoUrl);

        return Center(
          child: Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: opacity,
              child: assetPath != null
                  ? Image.asset(
                      assetPath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 50,
                            color: Colors.grey,
                          ),
                        );
                      },
                    )
                  : Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.sports,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}
