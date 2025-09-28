// lib/features/users/modalities/modalities_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:interufmt/core/theme/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/data/models/modality_with_status_model.dart';
import '../../../core/data/repositories/modalities_repository.dart';

class ModalitiesPage extends StatefulWidget {
  const ModalitiesPage({super.key});

  @override
  ModalitiesPageState createState() => ModalitiesPageState();
}

class ModalitiesPageState extends State<ModalitiesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ModalitiesRepository _repository;

  Map<String, List<ModalityAggregated>> _serieAModalities = {};
  Map<String, List<ModalityAggregated>> _serieBModalities = {};
  Map<String, List<ModalityAggregated>> _currentModalities = {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _repository = ModalitiesRepository(Supabase.instance.client);
    _loadModalities();

    _tabController.addListener(() {
      setState(() {
        _currentModalities = _tabController.index == 0
            ? _serieAModalities
            : _serieBModalities;
      });
    });
  }

  Future<void> _loadModalities() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final modalitiesData = await _repository.getAllModalitiesBySeries();

      setState(() {
        final serieAList = modalitiesData['A'] ?? [];
        final serieBList = modalitiesData['B'] ?? [];

        _serieAModalities = _repository.groupModalitiesByGender(serieAList);
        _serieBModalities = _repository.groupModalitiesByGender(serieBList);
        _currentModalities = _serieAModalities;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erro ao carregar modalidades: $error';
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Modalidades',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.cardBackground,
        elevation: 0,
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back, color: Colors.black),
        //   onPressed: () => context.goNamed(HomePage.routename),
        // ),
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
          : _buildModalitiesContent(),
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
            onPressed: _loadModalities,
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildModalitiesContent() {
    return RefreshIndicator(
      onRefresh: _loadModalities,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 10),
            // Three-column layout for gender sections
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Masculino - Left column
                Expanded(child: _buildGenderSection('Masculino', Colors.grey)),
                const SizedBox(width: 12),
                // Misto - Center column
                Expanded(child: _buildGenderSection('Misto', Colors.grey)),
                const SizedBox(width: 12),
                // Feminino - Right column
                Expanded(child: _buildGenderSection('Feminino', Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderSection(String gender, Color color) {
    final modalities = _currentModalities[gender] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          gender,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.secondaryText,
          ),
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 16),

        if (modalities.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.sports,
                  size: 32,
                  color: Colors.grey.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 8),
                Text(
                  'Nenhuma\nmodalidade',
                  style: TextStyle(
                    color: Colors.grey.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ...modalities.map((modality) => _buildModalityCard(modality, color)),
      ],
    );
  }

  Widget _buildModalityCard(ModalityAggregated modality, Color genderColor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),

      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: SvgPicture.asset(
                modality.assetPath,
                width: 32,
                height: 32,
                colorFilter: ColorFilter.mode(
                  AppColors.primaryText,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(height: 5),

            // Modality icon and name
            Text(
              modality.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryText,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 2),

            // Status
            Text(
              modality.modalityStatus,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.secondaryText,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
