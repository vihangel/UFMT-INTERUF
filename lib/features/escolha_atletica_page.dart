// lib/features/users/escolha_atletica_page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Listas separadas para as duas séries
final List<Map<String, String>> serieA = [
  {
    'name': 'Atlética Trojan',
    'description': 'Descrição da Atlética Trojan',
    'image': 'assets/images/Atlética Trojan.png',
  },
  {
    'name': 'Atlética Tormenta',
    'description': 'Descrição da Atlética Tormenta',
    'image': 'assets/images/Atlética Tormenta.png',
  },
  {
    'name': 'Atlética Pintada',
    'description': 'Descrição da Atlética Pintada',
    'image': 'assets/images/Atlética Pintada.png',
  },
  {
    'name': 'Atlética Metralha',
    'description': 'Descrição da Atlética Metralha',
    'image': 'assets/images/Atlética Metralha.png',
  },
  {
    'name': 'Atlética Ampère',
    'description': 'Descrição da Atlética Ampère',
    'image': 'assets/images/Atlética Ampère.png',
  },
  {
    'name': 'Atlética Devora',
    'description': 'Descrição da Atlética Devora',
    'image': 'assets/images/Atlética Devora.png',
  },
  {
    'name': 'Atlética Armada',
    'description': 'Descrição da Atlética Armada',
    'image': 'assets/images/Atlética Armada.png',
  },
  {
    'name': 'Atlética Hydra',
    'description': 'Descrição da Atlética Hydra',
    'image': 'assets/images/Atlética Hydra.png',
  },
  {
    'name': 'Atlética Macabra',
    'description': 'Descrição da Atlética Macabra',
    'image': 'assets/images/Atlética Macabra.png',
  },
  {
    'name': 'Atlética Búfalos',
    'description': 'Descrição da Atlética Búfalos',
    'image': 'assets/images/Atlética Búfalos.png',
  },
  {
    'name': 'Atlética Sísmica',
    'description': 'Descrição da Atlética Sísmica',
    'image': 'assets/images/Atlética Sísmica.png',
  },
  {
    'name': 'Atlética Rústica',
    'description': 'Descrição da Atlética Rústica',
    'image': 'assets/images/Atlética Rústica.png',
  },
  {
    'name': 'Atlética Enfúria',
    'description': 'Descrição da Atlética Enfúria',
    'image': 'assets/images/Atlética Enfúria.png',
  },
  {
    'name': 'Atlética Infernal',
    'description': 'Descrição da Atlética Infernal',
    'image': 'assets/images/Atlética Infernal.png',
  },
  {
    'name': 'Atlética Monopólio',
    'description': 'Descrição da Atlética Monopólio',
    'image': 'assets/images/Atlética Monopólio.png',
  },
];

final List<Map<String, String>> serieB = [
  {
    'name': 'Atlética Tempesta',
    'description': 'Descrição da Atlética Tempesta',
    'image': 'assets/images/Atlética Tempesta.png',
  },
  {
    'name': 'Atlética Compila',
    'description': 'Descrição da Atlética Compila',
    'image': 'assets/images/Atlética Compila.png',
  },
  {
    'name': 'Atlética Detona',
    'description': 'Descrição da Atlética Detona',
    'image': 'assets/images/Atlética Detona.png',
  },
  {
    'name': 'Atlética Rochedo',
    'description': 'Descrição da Atlética Rochedo',
    'image': 'assets/images/Atlética Rochedo.png',
  },
  {
    'name': 'Atlética Transtorna',
    'description': 'Descrição da Atlética Transtorna',
    'image': 'assets/images/Atlética Transtorna.png',
  },
  {
    'name': 'Atlética Caiman',
    'description': 'Descrição da Atlética Caiman',
    'image': 'assets/images/Atlética Caiman.png',
  },
  {
    'name': 'Atlética Admafia',
    'description': 'Descrição da Atlética Admafia',
    'image': 'assets/images/Atlética Admafia.png',
  },
  {
    'name': 'Atlética Arcaica',
    'description': 'Descrição da Atlética Arcaica',
    'image': 'assets/images/Atlética Arcaica.png',
  },
  {
    'name': 'Atlética Caótica',
    'description': 'Descrição da Atlética Caótica',
    'image': 'assets/images/Atlética Caótica.png',
  },
  {
    'name': 'Atlética Gato Preto',
    'description': 'Descrição da Atlética Gato Preto',
    'image': 'assets/images/Atlética Gato Preto.png',
  },
  {
    'name': 'Atlética Sumaúma',
    'description': 'Descrição da Atlética Sumaúma',
    'image': 'assets/images/Atlética Sumaúma.png',
  },
  {
    'name': 'Atlética Guará',
    'description': 'Descrição da Atlética Guará',
    'image': 'assets/images/Atlética Guará.png',
  },
  {
    'name': 'Atlética CACIC',
    'description': 'Descrição da Atlética CACIC',
    'image': 'assets/images/Atlética CACIC.png',
  },
  {
    'name': 'Atlética Deltas',
    'description': 'Descrição da Atlética Deltas',
    'image': 'assets/images/Atlética Deltas.png',
  },
  {
    'name': 'Atlética Atômica',
    'description': 'Descrição da Atlética Atômica',
    'image': 'assets/images/Atlética Atômica.png',
  },
  {
    'name': 'Atlética Quântica',
    'description': 'Descrição da Atlética Quântica',
    'image': 'assets/images/Atlética Quântica.png',
  },
];

class EscolhaAtleticaPage extends StatefulWidget {
  const EscolhaAtleticaPage({Key? key}) : super(key: key);

  @override
  _EscolhaAtleticaPageState createState() => _EscolhaAtleticaPageState();
}

class _EscolhaAtleticaPageState extends State<EscolhaAtleticaPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentPageIndex = 0;
  List<Map<String, String>> _currentSeries = serieA;
  String _currentSeriesName = 'Série A';
  double _pageOffset = 0.0;

  final Map<int, PageController> _tabPageControllers = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _tabController.addListener(() {
      setState(() {
        if (_tabController.index == 0) {
          _currentSeries = serieA;
          _currentSeriesName = 'Série A';
        } else {
          _currentSeries = serieB;
          _currentSeriesName = 'Série B';
        }
        _currentPageIndex =
            _tabPageControllers[_tabController.index]?.page?.round() ?? 0;
        _pageOffset =
            _tabPageControllers[_tabController.index]?.page ??
            _tabPageControllers[_tabController.index]?.initialPage
                ?.toDouble() ??
            0.0;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tabPageControllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  void _saveAndNavigate() async {
    final prefs = await SharedPreferences.getInstance();
    final chosenAtletica = _currentSeries[_currentPageIndex];

    await prefs.setString('chosen_athletic_name', chosenAtletica['name']!);
    await prefs.setString('chosen_athletic_series', _currentSeriesName);

    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Escolha uma Atlética',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                    _buildCarousel(serieA, 0),
                    _buildCarousel(serieB, 1),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _currentSeries[_currentPageIndex]['name']!,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 5),
              Text(
                _currentSeries[_currentPageIndex]['description']!,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _saveAndNavigate,
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
    );
  }

  Widget _buildCarousel(List<Map<String, String>> series, int tabIndex) {
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

        return Center(
          child: Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: opacity,
              child: Image.asset(series[index]['image']!, fit: BoxFit.contain),
            ),
          ),
        );
      },
    );
  }
}
