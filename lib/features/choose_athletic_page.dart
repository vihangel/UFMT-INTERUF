import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interufmt/core/data/mocks/atleticas_mock.dart';
import 'package:interufmt/core/data/models/atletica_model.dart';
import 'package:interufmt/features/users/home/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChooseAthleticPage extends StatefulWidget {
  static const String routename = 'escolha_atletica';
  const ChooseAthleticPage({super.key});

  @override
  ChooseAthleticPageState createState() => ChooseAthleticPageState();
}

class ChooseAthleticPageState extends State<ChooseAthleticPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentPageIndex = 0;
  List<Atletica> _currentSeries = serieA;
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
            _tabPageControllers[_tabController.index]?.initialPage.toDouble() ??
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

    await prefs.setString('chosen_athletic_name', chosenAtletica.name);
    await prefs.setString('chosen_athletic_series', _currentSeriesName);

    context.goNamed(HomePage.routename);
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
                _currentSeries[_currentPageIndex].name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 5),
              Text(
                _currentSeries[_currentPageIndex].description,
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

  Widget _buildCarousel(List<Atletica> series, int tabIndex) {
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
              child: Image.asset(series[index].image, fit: BoxFit.contain),
            ),
          ),
        );
      },
    );
  }
}
