// lib/features/admin/venues_crud_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:interufmt/core/data/models/venues_model.dart';
import 'package:interufmt/core/data/repositories/venues_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class VenuesCrudPage extends StatefulWidget {
  static const String routename = 'venues-crud';

  const VenuesCrudPage({super.key});

  @override
  State<VenuesCrudPage> createState() => _VenuesCrudPageState();
}

class _VenuesCrudPageState extends State<VenuesCrudPage> {
  late VenuesRepository _repository;
  List<Venue> _venues = [];
  List<Venue> _filteredVenues = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  String _filterType = 'all'; // all, with_coordinates, without_coordinates

  @override
  void initState() {
    super.initState();
    _repository = VenuesRepository(Supabase.instance.client);
    _loadVenues();
  }

  Future<void> _loadVenues() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final venues = await _repository.getAllVenues();

      setState(() {
        _venues = venues;
        _applyFilters();
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erro ao carregar locais: $error';
      });
    }
  }

  void _applyFilters() {
    var filtered = _venues;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((venue) {
        return venue.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (venue.address?.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ??
                false);
      }).toList();
    }

    setState(() {
      _filteredVenues = filtered;
    });
  }

  Future<void> _showCreateDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => _VenueFormDialog(repository: _repository),
    );

    if (result == true) {
      _loadVenues();
    }
  }

  Future<void> _showEditDialog(Venue venue) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) =>
          _VenueFormDialog(repository: _repository, venue: venue),
    );

    if (result == true) {
      _loadVenues();
    }
  }

  Future<void> _showDeleteDialog(Venue venue) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text(
          'Tem certeza que deseja excluir o local "${venue.name}"?\n\n'
          'Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _deleteVenue(venue);
    }
  }

  Future<void> _deleteVenue(Venue venue) async {
    try {
      await Supabase.instance.client.from('venues').delete().eq('id', venue.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Local "${venue.name}" excluído com sucesso'),
            backgroundColor: Colors.green,
          ),
        );
        _loadVenues();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir local: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
      appBar: AppBar(
        title: const Text('Gerenciar Locais'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
            onPressed: _loadVenues,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                // Search bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar por nome ou endereço...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                                _applyFilters();
                              });
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                      _applyFilters();
                    });
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? _buildErrorState()
                : _filteredVenues.isEmpty
                ? _buildEmptyState()
                : _buildVenuesList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        icon: const Icon(Icons.add),
        label: const Text('Novo Local'),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadVenues,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchQuery.isNotEmpty || _filterType != 'all'
                  ? Icons.search_off
                  : Icons.location_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty || _filterType != 'all'
                  ? 'Nenhum local encontrado com os filtros aplicados'
                  : 'Nenhum local cadastrado',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            if (_searchQuery.isEmpty && _filterType == 'all') ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _showCreateDialog,
                icon: const Icon(Icons.add),
                label: const Text('Adicionar Primeiro Local'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVenuesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredVenues.length,
      itemBuilder: (context, index) {
        final venue = _filteredVenues[index];
        return _buildVenueCard(venue);
      },
    );
  }

  Widget _buildVenueCard(Venue venue) {
    final hasCoordinates = venue.lat != null && venue.lng != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showEditDialog(venue),
        borderRadius: BorderRadius.circular(12),
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
                          ? Colors.green.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(
                      hasCoordinates ? Icons.location_on : Icons.location_off,
                      color: hasCoordinates ? Colors.green : Colors.orange,
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
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          _showEditDialog(venue);
                          break;
                        case 'delete':
                          _showDeleteDialog(venue);
                          break;
                        case 'map':
                          _openMap(venue);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 12),
                            Text('Editar'),
                          ],
                        ),
                      ),
                      if (hasCoordinates)
                        const PopupMenuItem(
                          value: 'map',
                          child: Row(
                            children: [
                              Icon(Icons.map, size: 20),
                              SizedBox(width: 12),
                              Text('Abrir no Mapa'),
                            ],
                          ),
                        ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 12),
                            Text(
                              'Excluir',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.gps_fixed,
                        size: 16,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Lat: ${venue.lat!.toStringAsFixed(6)}, Lng: ${venue.lng!.toStringAsFixed(6)}',
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
      ),
    );
  }
}

// Form Dialog for Create/Edit
class _VenueFormDialog extends StatefulWidget {
  final VenuesRepository repository;
  final Venue? venue;

  const _VenueFormDialog({required this.repository, this.venue});

  @override
  State<_VenueFormDialog> createState() => _VenueFormDialogState();
}

class _VenueFormDialogState extends State<_VenueFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _latController;
  late TextEditingController _lngController;
  bool _isLoading = false;

  bool get isEditing => widget.venue != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.venue?.name ?? '');
    _addressController = TextEditingController(
      text: widget.venue?.address ?? '',
    );
    _latController = TextEditingController(
      text: widget.venue?.lat?.toString() ?? '',
    );
    _lngController = TextEditingController(
      text: widget.venue?.lng?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  Future<void> _saveVenue() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final data = {
        'name': _nameController.text.trim(),
        'address': _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        'lat': _latController.text.trim().isEmpty
            ? null
            : double.parse(_latController.text.trim()),
        'lng': _lngController.text.trim().isEmpty
            ? null
            : double.parse(_lngController.text.trim()),
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (isEditing) {
        // Update existing venue
        await Supabase.instance.client
            .from('venues')
            .update(data)
            .eq('id', widget.venue!.id);
      } else {
        // Create new venue
        data['created_at'] = DateTime.now().toIso8601String();
        await Supabase.instance.client.from('venues').insert(data);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing
                  ? 'Local atualizado com sucesso'
                  : 'Local criado com sucesso',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar local: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isEditing ? 'Editar Local' : 'Novo Local'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome *',
                  hintText: 'Ex: Ginásio de Esportes',
                  prefixIcon: Icon(Icons.location_city),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nome é obrigatório';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Endereço',
                  hintText: 'Ex: Av. Fernando Corrêa da Costa',
                  prefixIcon: Icon(Icons.place),
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              const Text(
                'Coordenadas (opcional)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latController,
                      decoration: const InputDecoration(
                        labelText: 'Latitude',
                        hintText: '-15.123456',
                        prefixIcon: Icon(Icons.gps_fixed),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^-?\d*\.?\d*'),
                        ),
                      ],
                      validator: (value) {
                        if (value != null && value.trim().isNotEmpty) {
                          final lat = double.tryParse(value.trim());
                          if (lat == null) {
                            return 'Latitude inválida';
                          }
                          if (lat < -90 || lat > 90) {
                            return 'Deve estar entre -90 e 90';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _lngController,
                      decoration: const InputDecoration(
                        labelText: 'Longitude',
                        hintText: '-56.123456',
                        prefixIcon: Icon(Icons.gps_fixed),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^-?\d*\.?\d*'),
                        ),
                      ],
                      validator: (value) {
                        if (value != null && value.trim().isNotEmpty) {
                          final lng = double.tryParse(value.trim());
                          if (lng == null) {
                            return 'Longitude inválida';
                          }
                          if (lng < -180 || lng > 180) {
                            return 'Deve estar entre -180 e 180';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Dica: Use o Google Maps para obter as coordenadas',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveVenue,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEditing ? 'Salvar' : 'Criar'),
        ),
      ],
    );
  }
}
