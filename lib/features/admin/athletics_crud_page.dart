// lib/features/admin/athletics_crud_page.dart

import 'package:flutter/material.dart';
import 'package:interufmt/core/data/repositories/athletics_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AthleticsCrudPage extends StatefulWidget {
  static const String routename = 'athletics-crud';

  const AthleticsCrudPage({super.key});

  @override
  State<AthleticsCrudPage> createState() => _AthleticsCrudPageState();
}

class _AthleticsCrudPageState extends State<AthleticsCrudPage> {
  late AthleticsRepository _repository;
  List<Map<String, dynamic>> _athletics = [];
  List<Map<String, dynamic>> _filteredAthletics = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _filterSeries = 'all'; // all, A, B

  @override
  void initState() {
    super.initState();
    _repository = AthleticsRepository(Supabase.instance.client);
    _loadAthletics();
  }

  Future<void> _loadAthletics() async {
    setState(() => _isLoading = true);

    try {
      final athletics = await _repository.getAllAthleticsForCrud();

      setState(() {
        _athletics = athletics;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar atléticas: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _applyFilters() {
    _filteredAthletics = _athletics.where((athletic) {
      // Apply search filter
      final matchesSearch =
          _searchQuery.isEmpty ||
          athletic['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (athletic['nickname'] != null &&
              athletic['nickname'].toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ));

      // Apply series filter
      final matchesSeries =
          _filterSeries == 'all' || athletic['series'] == _filterSeries;

      return matchesSearch && matchesSeries;
    }).toList();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilters();
    });
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _filterSeries = filter;
      _applyFilters();
    });
  }

  Future<void> _showCreateDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => _AthleticFormDialog(repository: _repository),
    );

    if (result == true) {
      await _loadAthletics();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Atlética criada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _showEditDialog(Map<String, dynamic> athletic) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) =>
          _AthleticFormDialog(repository: _repository, athletic: athletic),
    );

    if (result == true) {
      await _loadAthletics();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Atlética atualizada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _showDeleteDialog(Map<String, dynamic> athletic) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text(
          'Tem certeza que deseja excluir a atlética "${athletic['name']}"?\n\nEsta ação não pode ser desfeita e irá excluir todos os atletas associados.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteAthletic(athletic['id']);
    }
  }

  Future<void> _deleteAthletic(String id) async {
    try {
      await _repository.deleteAthletic(id);

      await _loadAthletics();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Atlética excluída com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir atlética: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Atléticas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAthletics,
            tooltip: 'Recarregar',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por nome ou apelido...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: _onSearchChanged,
            ),
          ),

          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Todas'),
                  selected: _filterSeries == 'all',
                  onSelected: (_) => _onFilterChanged('all'),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Série A'),
                  selected: _filterSeries == 'A',
                  onSelected: (_) => _onFilterChanged('A'),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Série B'),
                  selected: _filterSeries == 'B',
                  onSelected: (_) => _onFilterChanged('B'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Athletics list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredAthletics.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.school, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'Nenhuma atlética encontrada'
                              : 'Nenhuma atlética encontrada para "$_searchQuery"',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadAthletics,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredAthletics.length,
                      itemBuilder: (context, index) {
                        final athletic = _filteredAthletics[index];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading:
                                athletic['logo_url'] != null &&
                                    athletic['logo_url'].toString().isNotEmpty
                                ? CircleAvatar(
                                    backgroundColor: Colors.blue[100],
                                    backgroundImage: AssetImage(
                                      'assets/images/${athletic['logo_url'].replaceAll('images/', '')}',
                                    ),
                                  )
                                : CircleAvatar(
                                    backgroundColor: Colors.grey[300],
                                    child: Icon(
                                      Icons.school,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                            title: Text(
                              athletic['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (athletic['nickname'] != null)
                                  Text(
                                    athletic['nickname'],
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.category,
                                      size: 14,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Série ${athletic['series']}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _showEditDialog(athletic);
                                } else if (value == 'delete') {
                                  _showDeleteDialog(athletic);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, color: Colors.blue),
                                      SizedBox(width: 8),
                                      Text('Editar'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text('Excluir'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        icon: const Icon(Icons.add),
        label: const Text('Nova Atlética'),
      ),
    );
  }
}

// Form Dialog for Create/Edit
class _AthleticFormDialog extends StatefulWidget {
  final AthleticsRepository repository;
  final Map<String, dynamic>? athletic;

  const _AthleticFormDialog({required this.repository, this.athletic});

  @override
  State<_AthleticFormDialog> createState() => _AthleticFormDialogState();
}

class _AthleticFormDialogState extends State<_AthleticFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _nicknameController;
  late TextEditingController _logoUrlController;
  late TextEditingController _descriptionController;
  late TextEditingController _instagramController;
  late TextEditingController _twitterController;
  late TextEditingController _youtubeController;
  String _selectedSeries = 'A';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.athletic?['name']);
    _nicknameController = TextEditingController(
      text: widget.athletic?['nickname'],
    );
    _logoUrlController = TextEditingController(
      text: widget.athletic?['logo_url'],
    );
    _descriptionController = TextEditingController(
      text: widget.athletic?['description'],
    );
    _instagramController = TextEditingController(
      text: widget.athletic?['instagram'],
    );
    _twitterController = TextEditingController(
      text: widget.athletic?['twitter'],
    );
    _youtubeController = TextEditingController(
      text: widget.athletic?['youtube'],
    );
    _selectedSeries = widget.athletic?['series'] ?? 'A';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    _logoUrlController.dispose();
    _descriptionController.dispose();
    _instagramController.dispose();
    _twitterController.dispose();
    _youtubeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (widget.athletic == null) {
        // Create
        await widget.repository.createAthletic(
          name: _nameController.text.trim(),
          nickname: _nicknameController.text.trim().isEmpty
              ? null
              : _nicknameController.text.trim(),
          series: _selectedSeries,
          logoUrl: _logoUrlController.text.trim().isEmpty
              ? null
              : _logoUrlController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          instagram: _instagramController.text.trim().isEmpty
              ? null
              : _instagramController.text.trim(),
          twitter: _twitterController.text.trim().isEmpty
              ? null
              : _twitterController.text.trim(),
          youtube: _youtubeController.text.trim().isEmpty
              ? null
              : _youtubeController.text.trim(),
        );
      } else {
        // Update
        await widget.repository.updateAthletic(
          id: widget.athletic!['id'],
          name: _nameController.text.trim(),
          nickname: _nicknameController.text.trim().isEmpty
              ? null
              : _nicknameController.text.trim(),
          series: _selectedSeries,
          logoUrl: _logoUrlController.text.trim().isEmpty
              ? null
              : _logoUrlController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          instagram: _instagramController.text.trim().isEmpty
              ? null
              : _instagramController.text.trim(),
          twitter: _twitterController.text.trim().isEmpty
              ? null
              : _twitterController.text.trim(),
          youtube: _youtubeController.text.trim().isEmpty
              ? null
              : _youtubeController.text.trim(),
        );
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.athletic != null;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(isEdit ? Icons.edit : Icons.add, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    isEdit ? 'Editar Atlética' : 'Nova Atlética',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nome *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.school),
                          helperText: 'Nome completo da atlética',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nome é obrigatório';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Nickname
                      TextFormField(
                        controller: _nicknameController,
                        decoration: const InputDecoration(
                          labelText: 'Apelido',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.badge),
                          helperText: 'Apelido ou nome popular',
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Series dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedSeries,
                        decoration: const InputDecoration(
                          labelText: 'Série *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.category),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'A', child: Text('Série A')),
                          DropdownMenuItem(value: 'B', child: Text('Série B')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedSeries = value);
                          }
                        },
                      ),

                      const SizedBox(height: 16),

                      // Logo URL
                      TextFormField(
                        controller: _logoUrlController,
                        decoration: const InputDecoration(
                          labelText: 'Logo',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.image),
                          helperText:
                              'Nome do arquivo em assets/images/ (ex: trojan.png)',
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Descrição',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                          helperText: 'Descrição da atlética',
                        ),
                        maxLines: 3,
                      ),

                      const SizedBox(height: 16),

                      // Social Media Section
                      Text(
                        'Redes Sociais',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),

                      // Instagram
                      TextFormField(
                        controller: _instagramController,
                        decoration: const InputDecoration(
                          labelText: 'Instagram',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.camera_alt),
                          helperText: 'URL do perfil do Instagram',
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Twitter
                      TextFormField(
                        controller: _twitterController,
                        decoration: const InputDecoration(
                          labelText: 'Twitter',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.chat),
                          helperText: 'URL do perfil do Twitter',
                        ),
                      ),

                      const SizedBox(height: 16),

                      // YouTube
                      TextFormField(
                        controller: _youtubeController,
                        decoration: const InputDecoration(
                          labelText: 'YouTube',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.video_library),
                          helperText: 'URL do canal do YouTube',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(isEdit ? 'Salvar' : 'Criar'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
