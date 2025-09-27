// lib/features/users/modalities/modalities_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

  Icon _getStatusIcon(String status) {
    switch (status) {
      case 'Não iniciada':
        return const Icon(Icons.schedule, color: Colors.grey, size: 16);
      case 'Em disputa':
        return const Icon(Icons.play_circle_fill, color: Colors.grey, size: 16);
      case 'Finalizada':
        return const Icon(Icons.check_circle, color: Colors.grey, size: 16);
      default:
        return const Icon(Icons.help_outline, color: Colors.grey, size: 16);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Modalidades',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                gender,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const SizedBox(height: 12),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: genderColor.withValues(alpha: 0.2), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Modality icon and name
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: genderColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: modality.icon != null
                      ? SvgPicture.asset(
                          modality.assetPath,
                          width: 16,
                          height: 16,
                          colorFilter: ColorFilter.mode(
                            genderColor,
                            BlendMode.srcIn,
                          ),
                        )
                      : Icon(Icons.emoji_events, color: genderColor, size: 16),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    modality.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Status
            Row(
              children: [
                _getStatusIcon(modality.modalityStatus),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    modality.modalityStatus,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}
