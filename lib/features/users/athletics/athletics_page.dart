// lib/features/users/athletics/athletics_page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interufmt/core/theme/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:interufmt/features/torcidometro_page.dart';
import '../../../core/data/athletics_item_model.dart';
import '../../../core/data/repositories/athletics_repository.dart';
import 'athletic_detail_page.dart';
import '../../torcidometro_page.dart';

class AthleticsPage extends StatefulWidget {
  static const String routename = 'athletics';
  const AthleticsPage({super.key});

  @override
  AthleticsPageState createState() => AthleticsPageState();
}

class AthleticsPageState extends State<AthleticsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late AthleticsRepository _repository;

  List<AthleticsItem> _serieA = [];
  List<AthleticsItem> _serieB = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _repository = AthleticsRepository(Supabase.instance.client);
    _loadAthletics();
  }

  Future<void> _loadAthletics() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final athleticsData = await _repository.getAllAthletics();

      setState(() {
        _serieA = athleticsData['A'] ?? [];
        _serieB = athleticsData['B'] ?? [];
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
    super.dispose();
  }

  void _navigateToAthleticDetail(AthleticsItem athletic) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AthleticDetailPage(athletic: athletic),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Página de Atléticas',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.bar_chart,
              color: Colors.black,
            ), // Ícone de barras
            onPressed: () {
              context.goNamed(TorcidometroPage.routename);
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,

          tabs: const [
            Tab(text: 'Série A'),
            Tab(text: 'Série B'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildErrorState()
          : TabBarView(
              controller: _tabController,
              children: [
                _buildAthleticsList(_serieA),
                _buildAthleticsList(_serieB),
              ],
            ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
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
    );
  }

  Widget _buildAthleticsList(List<AthleticsItem> athletics) {
    if (athletics.isEmpty) {
      return const Center(
        child: Text(
          'Nenhuma atlética encontrada',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(children: athletics.map(_buildAthleticCard).toList()),
    );
  }

  Widget _buildAthleticCard(AthleticsItem athletic) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () => _navigateToAthleticDetail(athletic),
        child: Stack(
          children: [
            SizedBox(
              height: 140,
              child: Card(
                margin: const EdgeInsets.only(left: 70),
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 86,
                    right: 16,
                    top: 16,
                    bottom: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        athletic.nickname,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryText,
                        ),

                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // const SizedBox(height: 4),
                      Expanded(
                        child: Text(
                          athletic.name,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.secondaryText,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Athletic Logo
            ClipRRect(
              borderRadius: BorderRadius.circular(400),

              child: Container(
                height: 140,
                width: 140,
                color: AppColors.background,
                child: Image.asset(
                  'assets/images/${athletic.assetPath.replaceAll('images/', '')}',
                  height: 140,
                  width: 140,
                  fit: BoxFit.cover,

                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: const Icon(
                        Icons.sports,
                        size: 40,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
