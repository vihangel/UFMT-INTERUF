// lib/features/admin/athletes_crud_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:interufmt/core/data/repositories/athletes_repository.dart';
import 'package:interufmt/core/data/repositories/athletics_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AthletesCrudPage extends StatefulWidget {
  static const String routename = 'athletes-crud';

  const AthletesCrudPage({super.key});

  @override
  State<AthletesCrudPage> createState() => _AthletesCrudPageState();
}

class _AthletesCrudPageState extends State<AthletesCrudPage> {
  late AthletesRepository _repository;
  late AthleticsRepository _athleticsRepository;
  List<Map<String, dynamic>> _athletes = [];
  List<Map<String, dynamic>> _filteredAthletes = [];
  List<Map<String, dynamic>> _athletics = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _filterAthletic = 'all';

  @override
  void initState() {
    super.initState();
    _repository = AthletesRepository(Supabase.instance.client);
    _athleticsRepository = AthleticsRepository(Supabase.instance.client);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final futures = await Future.wait([
        _repository.getAllAthletes(),
        _athleticsRepository.getAllAthleticsForCrud(),
      ]);

      setState(() {
        _athletes = futures[0] as List<Map<String, dynamic>>;
        _athletics = futures[1] as List<Map<String, dynamic>>;
        _athletics.sort((a, b) =>
            (a['nickname'] ?? a['name'])
                .toString()
                .compareTo((b['nickname'] ?? b['name']).toString()));
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar atletas: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _applyFilters() {
    _filteredAthletes = _athletes.where((athlete) {
      // Apply search filter
      final matchesSearch = _searchQuery.isEmpty ||
          athlete['full_name']
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          (athlete['rga'] != null &&
              athlete['rga']
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase())) ||
          (athlete['course'] != null &&
              athlete['course']
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()));

      // Apply athletic filter
      final matchesAthletic = _filterAthletic == 'all' ||
          athlete['athletic_id'] == _filterAthletic;

      return matchesSearch && matchesAthletic;
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
      _filterAthletic = filter;
      _applyFilters();
    });
  }

  Future<void> _showCreateDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => _AthleteFormDialog(
        repository: _repository,
        athletics: _athletics,
      ),
    );

    if (result == true) {
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Atleta criado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _showEditDialog(Map<String, dynamic> athlete) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => _AthleteFormDialog(
        repository: _repository,
        athletics: _athletics,
        athlete: athlete,
      ),
    );

    if (result == true) {
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Atleta atualizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _showDeleteDialog(Map<String, dynamic> athlete) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text(
          'Tem certeza que deseja excluir o atleta "${athlete['full_name']}"?\n\nEsta ação não pode ser desfeita.',
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
      await _deleteAthlete(athlete['id']);
    }
  }

  Future<void> _deleteAthlete(String id) async {
    try {
      await _repository.deleteAthlete(id);

      await _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Atleta excluído com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir atleta: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getAthleticName(String athleticId) {
    try {
      final athletic =
          _athletics.firstWhere((a) => a['id'] == athleticId);
      return athletic['nickname'] ?? athletic['name'];
    } catch (e) {
      return 'Atlética não encontrada';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Atletas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
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
                hintText: 'Buscar por nome, RGA ou curso...',
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

          // Filter dropdown
          if (_athletics.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _filterAthletic,
                      decoration: const InputDecoration(
                        labelText: 'Filtrar por Atlética',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.filter_list),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: 'all',
                          child: Text('Todas as Atléticas'),
                        ),
                        ..._athletics.map((athletic) => DropdownMenuItem(
                              value: athletic['id'],
                              child: Text(
                                athletic['nickname'] ?? athletic['name'],
                              ),
                            )),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          _onFilterChanged(value);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 8),

          // Athletes list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredAthletes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'Nenhum atleta encontrado'
                                  : 'Nenhum atleta encontrado para "$_searchQuery"',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredAthletes.length,
                          itemBuilder: (context, index) {
                            final athlete = _filteredAthletes[index];
                            final athleticName =
                                _getAthleticName(athlete['athletic_id']);

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.green[100],
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.green[900],
                                  ),
                                ),
                                title: Text(
                                  athlete['full_name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.school,
                                          size: 14,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            athleticName,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (athlete['rga'] != null) ...[
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.badge,
                                            size: 14,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'RGA: ${athlete['rga']}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                    if (athlete['course'] != null) ...[
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.book,
                                            size: 14,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              athlete['course'],
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      _showEditDialog(athlete);
                                    } else if (value == 'delete') {
                                      _showDeleteDialog(athlete);
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
        label: const Text('Novo Atleta'),
      ),
    );
  }
}

// Form Dialog for Create/Edit
class _AthleteFormDialog extends StatefulWidget {
  final AthletesRepository repository;
  final List<Map<String, dynamic>> athletics;
  final Map<String, dynamic>? athlete;

  const _AthleteFormDialog({
    required this.repository,
    required this.athletics,
    this.athlete,
  });

  @override
  State<_AthleteFormDialog> createState() => _AthleteFormDialogState();
}

class _AthleteFormDialogState extends State<_AthleteFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _rgaController;
  late TextEditingController _courseController;
  String? _selectedAthleticId;
  DateTime? _birthdate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fullNameController =
        TextEditingController(text: widget.athlete?['full_name']);
    _rgaController = TextEditingController(text: widget.athlete?['rga']);
    _courseController = TextEditingController(text: widget.athlete?['course']);
    _selectedAthleticId = widget.athlete?['athletic_id'];
    
    if (widget.athlete?['birthdate'] != null) {
      _birthdate = DateTime.parse(widget.athlete!['birthdate']);
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _rgaController.dispose();
    _courseController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthdate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _birthdate ?? DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _birthdate = date;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedAthleticId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione uma atlética'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (widget.athlete == null) {
        // Create
        await widget.repository.createAthlete(
          athleticId: _selectedAthleticId!,
          fullName: _fullNameController.text.trim(),
          rga: _rgaController.text.trim().isEmpty
              ? null
              : _rgaController.text.trim(),
          course: _courseController.text.trim().isEmpty
              ? null
              : _courseController.text.trim(),
          birthdate: _birthdate,
        );
      } else {
        // Update
        await widget.repository.updateAthlete(
          id: widget.athlete!['id'],
          athleticId: _selectedAthleticId!,
          fullName: _fullNameController.text.trim(),
          rga: _rgaController.text.trim().isEmpty
              ? null
              : _rgaController.text.trim(),
          course: _courseController.text.trim().isEmpty
              ? null
              : _courseController.text.trim(),
          birthdate: _birthdate,
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
    final isEdit = widget.athlete != null;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 650),
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
                  Icon(
                    isEdit ? Icons.edit : Icons.add,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isEdit ? 'Editar Atleta' : 'Novo Atleta',
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
                      // Full Name
                      TextFormField(
                        controller: _fullNameController,
                        decoration: const InputDecoration(
                          labelText: 'Nome Completo *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                          helperText: 'Nome completo do atleta',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nome é obrigatório';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Athletic dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedAthleticId,
                        decoration: const InputDecoration(
                          labelText: 'Atlética *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.school),
                        ),
                        items: widget.athletics
                            .map((athletic) => DropdownMenuItem<String>(
                                  value: athletic['id'],
                                  child: Text(
                                    athletic['nickname'] ?? athletic['name'],
                                  ),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() => _selectedAthleticId = value);
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Atlética é obrigatória';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // RGA
                      TextFormField(
                        controller: _rgaController,
                        decoration: const InputDecoration(
                          labelText: 'RGA',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.badge),
                          helperText: 'Registro Geral do Aluno',
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Course
                      TextFormField(
                        controller: _courseController,
                        decoration: const InputDecoration(
                          labelText: 'Curso',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.book),
                          helperText: 'Curso do atleta',
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Birthdate
                      InkWell(
                        onTap: _selectBirthdate,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Data de Nascimento',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            _birthdate == null
                                ? 'Selecione a data'
                                : DateFormat('dd/MM/yyyy').format(_birthdate!),
                            style: TextStyle(
                              color: _birthdate == null
                                  ? Colors.grey[600]
                                  : Colors.black,
                            ),
                          ),
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
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!),
                ),
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
