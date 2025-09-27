// lib/features/users/venues/venues_page.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/data/models/venues_model.dart';
import '../../../core/data/repositories/venues_repository.dart';

class VenuesPage extends StatefulWidget {
  const VenuesPage({super.key});

  @override
  VenuesPageState createState() => VenuesPageState();
}

class VenuesPageState extends State<VenuesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late VenuesRepository _repository;

  List<Venue> _allVenues = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _repository = VenuesRepository(Supabase.instance.client);
    _loadVenues();
  }

  Future<void> _loadVenues() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final futures = await Future.wait([
        _repository.getAllVenues(),
        _repository.getVenuesWithCoordinates(),
        _repository.getVenuesWithoutCoordinates(),
      ]);

      setState(() {
        _allVenues = futures[0];
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erro ao carregar locais: $error';
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _openMap(Venue venue) async {
    if (venue.lat != null && venue.lng != null) {
      final url =
          'https://www.google.com/maps/search/?api=1&query=${venue.lat},${venue.lng}';
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Não foi possível abrir o mapa')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Locais',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back, color: Colors.black),
        //   onPressed: () => context.goNamed(HomePage.routename),
        // ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildErrorState()
          : TabBarView(
              controller: _tabController,
              children: [_buildVenuesList(_allVenues, showMapIcon: true)],
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
            onPressed: _loadVenues,
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildVenuesList(List<Venue> venues, {required bool showMapIcon}) {
    if (venues.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Nenhum local encontrado',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadVenues,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: venues.length,
        itemBuilder: (context, index) {
          final venue = venues[index];
          return _buildVenueCard(venue, showMapIcon: showMapIcon);
        },
      ),
    );
  }

  Widget _buildVenueCard(Venue venue, {required bool showMapIcon}) {
    final hasCoordinates = venue.lat != null && venue.lng != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: hasCoordinates
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    hasCoordinates ? Icons.location_on : Icons.location_off,
                    color: hasCoordinates ? Colors.green : Colors.grey,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        venue.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      if (venue.address != null &&
                          venue.address!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          venue.address!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (showMapIcon && hasCoordinates)
                  IconButton(
                    onPressed: () => _openMap(venue),
                    icon: const Icon(Icons.map, color: Colors.blue),
                    tooltip: 'Abrir no mapa',
                  ),
              ],
            ),
            if (hasCoordinates) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.gps_fixed, size: 16, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(
                      'Coordenadas: ${venue.lat!.toStringAsFixed(6)}, ${venue.lng!.toStringAsFixed(6)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
