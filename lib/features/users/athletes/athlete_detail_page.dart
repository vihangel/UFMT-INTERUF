import 'package:flutter/material.dart';
import 'package:interufmt/core/theme/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/data/models/athlete_detail_model.dart';
import '../../../core/data/repositories/athlete_detail_repository.dart';

class AthleteDetailPage extends StatefulWidget {
  final String athleteId;
  final String gameId;

  const AthleteDetailPage({
    super.key,
    required this.athleteId,
    required this.gameId,
  });

  @override
  AthleteDetailPageState createState() => AthleteDetailPageState();
}

class AthleteDetailPageState extends State<AthleteDetailPage> {
  late AthleteDetailRepository _repository;
  AthleteDetail? _athleteDetail;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _repository = AthleteDetailRepository(Supabase.instance.client);
    _loadAthleteDetail();
  }

  Future<void> _loadAthleteDetail() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final detail = await _repository.getAthleteDetail(
        widget.athleteId,
        widget.gameId,
      );

      setState(() {
        _athleteDetail = detail;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erro ao carregar detalhes do atleta: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Estatísticas do atleta'),

        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildErrorState()
          : _athleteDetail == null
          ? const Center(child: Text('Atleta não encontrado'))
          : _buildContent(),
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
            onPressed: _loadAthleteDetail,
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_athleteDetail == null) return const SizedBox.shrink();
    final detail = _athleteDetail!;
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            border: const Border(
              top: BorderSide(color: AppColors.inputBorder, width: 1),
              bottom: BorderSide(color: AppColors.inputBorder, width: 1),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  detail.modalityWithGender,
                  style: const TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(width: 16),
              Text(
                'Série ${detail.series}',
                style: const TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                _buildPersonalSection(),
                const SizedBox(height: 24),
                _buildStatisticsSection(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalSection() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),

            child: const Text(
              'Pessoal',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Column(
              children: [
                _buildInfoRow('Nome', _athleteDetail!.fullName),
                const SizedBox(height: 12),
                _buildInfoRow('Camisa', '${_athleteDetail!.shirtNumber}'),
                const SizedBox(height: 12),
                _buildInfoRow('Idade', '${_athleteDetail!.age} anos'),
                const SizedBox(height: 12),
                _buildInfoRow('Curso', _athleteDetail!.course),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '$label:',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryText,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, color: AppColors.primaryText),
        ),
      ],
    );
  }

  Widget _buildStatisticsSection() {
    return Card(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Na Partida',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            if (_athleteDetail!.statistics.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Column(
                  children: [
                    Icon(
                      Icons.bar_chart,
                      size: 48,
                      color: AppColors.secondaryText.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Sem estatísticas registradas',
                      style: TextStyle(
                        color: AppColors.secondaryText.withValues(alpha: 0.7),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: _athleteDetail!.statistics.asMap().entries.map((
                    entry,
                  ) {
                    final index = entry.key;
                    final stat = entry.value;
                    final isLast =
                        index == _athleteDetail!.statistics.length - 1;

                    return Column(
                      children: [
                        _buildStatisticRow(stat),
                        if (!isLast)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Divider(height: 1),
                          ),
                      ],
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticRow(AthleteStatistic stat) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            stat.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${stat.value}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
