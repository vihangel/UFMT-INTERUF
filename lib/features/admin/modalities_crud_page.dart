// lib/features/admin/modalities_crud_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:interufmt/core/data/repositories/modalities_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ModalitiesCrudPage extends StatefulWidget {
  static const String routename = 'modalities-crud';

  const ModalitiesCrudPage({super.key});

  @override
  State<ModalitiesCrudPage> createState() => _ModalitiesCrudPageState();
}

class _ModalitiesCrudPageState extends State<ModalitiesCrudPage> {
  late ModalitiesRepository _repository;
  List<Map<String, dynamic>> _modalities = [];
  List<Map<String, dynamic>> _filteredModalities = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _filterGender = 'all'; // all, Masculino, Feminino, Misto

  @override
  void initState() {
    super.initState();
    _repository = ModalitiesRepository(Supabase.instance.client);
    _loadModalities();
  }

  Future<void> _loadModalities() async {
    setState(() => _isLoading = true);

    try {
      final modalities = await _repository.getAllModalities();

      setState(() {
        _modalities = modalities;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar modalidades: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _applyFilters() {
    _filteredModalities = _modalities.where((modality) {
      // Apply search filter
      final matchesSearch =
          _searchQuery.isEmpty ||
          modality['name'].toLowerCase().contains(_searchQuery.toLowerCase());

      // Apply gender filter
      final matchesGender =
          _filterGender == 'all' || modality['gender'] == _filterGender;

      return matchesSearch && matchesGender;
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
      _filterGender = filter;
      _applyFilters();
    });
  }

  Future<void> _showCreateDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => _ModalityFormDialog(repository: _repository),
    );

    if (result == true) {
      await _loadModalities();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Modalidade criada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _showEditDialog(Map<String, dynamic> modality) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) =>
          _ModalityFormDialog(repository: _repository, modality: modality),
    );

    if (result == true) {
      await _loadModalities();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Modalidade atualizada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _showDeleteDialog(Map<String, dynamic> modality) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text(
          'Tem certeza que deseja excluir a modalidade "${modality['name']}"?\n\nEsta ação não pode ser desfeita.',
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
      await _deleteModality(modality['id']);
    }
  }

  Future<void> _deleteModality(String id) async {
    try {
      await _repository.deleteModality(id);

      await _loadModalities();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Modalidade excluída com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir modalidade: $e'),
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
        title: const Text('Gerenciar Modalidades'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadModalities,
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
                hintText: 'Buscar por nome...',
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
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('Todas'),
                    selected: _filterGender == 'all',
                    onSelected: (_) => _onFilterChanged('all'),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Masculino'),
                    selected: _filterGender == 'Masculino',
                    onSelected: (_) => _onFilterChanged('Masculino'),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Feminino'),
                    selected: _filterGender == 'Feminino',
                    onSelected: (_) => _onFilterChanged('Feminino'),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Misto'),
                    selected: _filterGender == 'Misto',
                    onSelected: (_) => _onFilterChanged('Misto'),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Modalities list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredModalities.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.sports, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'Nenhuma modalidade encontrada'
                              : 'Nenhuma modalidade encontrada para "$_searchQuery"',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadModalities,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredModalities.length,
                      itemBuilder: (context, index) {
                        final modality = _filteredModalities[index];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading:
                                modality['icon'] != null &&
                                    modality['icon'].toString().isNotEmpty
                                ? CircleAvatar(
                                    backgroundColor: Colors.orange[100],
                                    child: SvgPicture.asset(
                                      modality['icon'].toString().startsWith(
                                            'assets/',
                                          )
                                          ? modality['icon']
                                          : 'assets/icons/${modality['icon']}',
                                      width: 24,
                                      height: 24,
                                      colorFilter: ColorFilter.mode(
                                        Colors.orange[900]!,
                                        BlendMode.srcIn,
                                      ),
                                      placeholderBuilder: (context) => Icon(
                                        Icons.sports,
                                        color: Colors.orange[900],
                                        size: 24,
                                      ),
                                    ),
                                  )
                                : CircleAvatar(
                                    backgroundColor: Colors.grey[300],
                                    child: Icon(
                                      Icons.sports,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                            title: Text(
                              modality['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Row(
                              children: [
                                Icon(
                                  _getGenderIcon(modality['gender']),
                                  size: 14,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  modality['gender'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                if (modality['icon'] != null &&
                                    modality['icon'].toString().isNotEmpty) ...[
                                  const SizedBox(width: 12),
                                  Icon(
                                    Icons.image,
                                    size: 14,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      modality['icon'],
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _showEditDialog(modality);
                                } else if (value == 'delete') {
                                  _showDeleteDialog(modality);
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
        label: const Text('Nova Modalidade'),
      ),
    );
  }

  IconData _getGenderIcon(String gender) {
    switch (gender) {
      case 'Masculino':
        return Icons.male;
      case 'Feminino':
        return Icons.female;
      case 'Misto':
        return Icons.people;
      default:
        return Icons.help_outline;
    }
  }
}

// Form Dialog for Create/Edit
class _ModalityFormDialog extends StatefulWidget {
  final ModalitiesRepository repository;
  final Map<String, dynamic>? modality;

  const _ModalityFormDialog({required this.repository, this.modality});

  @override
  State<_ModalityFormDialog> createState() => _ModalityFormDialogState();
}

class _ModalityFormDialogState extends State<_ModalityFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _iconController;
  String _selectedGender = 'Masculino';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.modality?['name']);
    _iconController = TextEditingController(text: widget.modality?['icon']);
    _selectedGender = widget.modality?['gender'] ?? 'Masculino';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (widget.modality == null) {
        // Create
        await widget.repository.createModality(
          name: _nameController.text.trim(),
          gender: _selectedGender,
          icon: _iconController.text.trim().isEmpty
              ? null
              : _iconController.text.trim(),
        );
      } else {
        // Update
        await widget.repository.updateModality(
          id: widget.modality!['id'],
          name: _nameController.text.trim(),
          gender: _selectedGender,
          icon: _iconController.text.trim().isEmpty
              ? null
              : _iconController.text.trim(),
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
    final isEdit = widget.modality != null;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
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
                    isEdit ? 'Editar Modalidade' : 'Nova Modalidade',
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
                          prefixIcon: Icon(Icons.sports),
                          helperText: 'Nome da modalidade (ex: Futebol, Vôlei)',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nome é obrigatório';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Gender dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedGender,
                        decoration: const InputDecoration(
                          labelText: 'Naipe *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.people),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Masculino',
                            child: Row(
                              children: [
                                Icon(Icons.male, size: 20),
                                SizedBox(width: 8),
                                Text('Masculino'),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'Feminino',
                            child: Row(
                              children: [
                                Icon(Icons.female, size: 20),
                                SizedBox(width: 8),
                                Text('Feminino'),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'Misto',
                            child: Row(
                              children: [
                                Icon(Icons.people, size: 20),
                                SizedBox(width: 8),
                                Text('Misto'),
                              ],
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedGender = value);
                          }
                        },
                      ),

                      const SizedBox(height: 16),

                      // Icon
                      TextFormField(
                        controller: _iconController,
                        decoration: const InputDecoration(
                          labelText: 'Ícone',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.image),
                          helperText:
                              'Nome do arquivo SVG em assets/icons/ (ex: ic_soccer.svg)',
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Info box
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue[700]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'O ícone deve ser um arquivo SVG disponível em assets/icons/',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ),
                          ],
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
