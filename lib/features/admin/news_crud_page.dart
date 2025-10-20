// lib/features/admin/news_crud_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:interufmt/core/data/models/news_model.dart';
import 'package:interufmt/core/data/repositories/news_repository.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsCrudPage extends StatefulWidget {
  static const String routename = 'news-crud';

  const NewsCrudPage({super.key});

  @override
  State<NewsCrudPage> createState() => _NewsCrudPageState();
}

class _NewsCrudPageState extends State<NewsCrudPage> {
  List<News> _news = [];
  List<News> _filteredNews = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _filterType = 'all'; // all, published, draft

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  Future<void> _loadNews() async {
    setState(() => _isLoading = true);

    try {
      final repository = context.read<NewsRepository>();
      final news = await repository.getAllNews();

      setState(() {
        _news = news;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar notícias: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _applyFilters() {
    _filteredNews = _news.where((news) {
      // Apply search filter
      final matchesSearch =
          _searchQuery.isEmpty ||
          news.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (news.summary?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
              false);

      // Apply type filter
      final now = DateTime.now();
      final matchesType =
          _filterType == 'all' ||
          (_filterType == 'published' &&
              news.publishedAt != null &&
              news.publishedAt!.isBefore(now)) ||
          (_filterType == 'draft' &&
              (news.publishedAt == null || news.publishedAt!.isAfter(now)));

      return matchesSearch && matchesType;
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
      _filterType = filter;
      _applyFilters();
    });
  }

  Future<void> _showCreateDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) =>
          _NewsFormDialog(repository: context.read<NewsRepository>()),
    );

    if (result == true) {
      await _loadNews();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notícia criada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _showEditDialog(News news) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => _NewsFormDialog(
        repository: context.read<NewsRepository>(),
        news: news,
      ),
    );

    if (result == true) {
      await _loadNews();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notícia atualizada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _showDeleteDialog(News news) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text(
          'Tem certeza que deseja excluir a notícia "${news.title}"?\n\nEsta ação não pode ser desfeita.',
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
      await _deleteNews(news.id);
    }
  }

  Future<void> _deleteNews(String id) async {
    try {
      final repository = context.read<NewsRepository>();
      await repository.deleteNews(id);

      await _loadNews();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notícia excluída com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir notícia: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível abrir o link'),
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
        title: const Text('Gerenciar Notícias'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNews,
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
                hintText: 'Buscar por título ou resumo...',
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
                  selected: _filterType == 'all',
                  onSelected: (_) => _onFilterChanged('all'),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Publicadas'),
                  selected: _filterType == 'published',
                  onSelected: (_) => _onFilterChanged('published'),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Rascunhos'),
                  selected: _filterType == 'draft',
                  onSelected: (_) => _onFilterChanged('draft'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // News list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredNews.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.article_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'Nenhuma notícia encontrada'
                              : 'Nenhuma notícia encontrada para "$_searchQuery"',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadNews,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredNews.length,
                      itemBuilder: (context, index) {
                        final news = _filteredNews[index];
                        final now = DateTime.now();
                        final isPublished =
                            news.publishedAt != null &&
                            news.publishedAt!.isBefore(now);

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Image (if available)
                              if (news.imageUrl != null &&
                                  news.imageUrl!.isNotEmpty)
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    topRight: Radius.circular(12),
                                  ),
                                  child: Image.asset(
                                    'assets/images/${news.imageUrl!.replaceAll('/', '')}',
                                    height: 150,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stack) =>
                                        Container(
                                          height: 150,
                                          color: Colors.grey[300],
                                          child: const Icon(
                                            Icons.broken_image,
                                            size: 48,
                                            color: Colors.grey,
                                          ),
                                        ),
                                  ),
                                ),

                              ListTile(
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        news.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    // Status indicator
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isPublished
                                            ? Colors.green[100]
                                            : Colors.orange[100],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        isPublished ? 'Publicada' : 'Rascunho',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: isPublished
                                              ? Colors.green[900]
                                              : Colors.orange[900],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (news.summary != null &&
                                        news.summary!.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        news.summary!,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          size: 14,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          news.publishedAt != null
                                              ? DateFormat(
                                                  'dd/MM/yyyy HH:mm',
                                                ).format(news.publishedAt!)
                                              : 'Não publicada',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        if (news.sourceUrl != null &&
                                            news.sourceUrl!.isNotEmpty) ...[
                                          const SizedBox(width: 16),
                                          InkWell(
                                            onTap: () =>
                                                _openUrl(news.sourceUrl!),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.link,
                                                  size: 14,
                                                  color: Colors.blue[600],
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Fonte',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.blue[600],
                                                    decoration: TextDecoration
                                                        .underline,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      _showEditDialog(news);
                                    } else if (value == 'delete') {
                                      _showDeleteDialog(news);
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
                            ],
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
        label: const Text('Nova Notícia'),
      ),
    );
  }
}

// Form Dialog for Create/Edit
class _NewsFormDialog extends StatefulWidget {
  final NewsRepository repository;
  final News? news;

  const _NewsFormDialog({required this.repository, this.news});

  @override
  State<_NewsFormDialog> createState() => _NewsFormDialogState();
}

class _NewsFormDialogState extends State<_NewsFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _summaryController;
  late TextEditingController _bodyController;
  late TextEditingController _imageUrlController;
  late TextEditingController _sourceUrlController;
  DateTime? _publishedAt;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.news?.title);
    _summaryController = TextEditingController(text: widget.news?.summary);
    _bodyController = TextEditingController(text: widget.news?.body);
    _imageUrlController = TextEditingController(text: widget.news?.imageUrl);
    _sourceUrlController = TextEditingController(text: widget.news?.sourceUrl);
    _publishedAt = widget.news?.publishedAt;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _summaryController.dispose();
    _bodyController.dispose();
    _imageUrlController.dispose();
    _sourceUrlController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _publishedAt ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_publishedAt ?? DateTime.now()),
      );

      if (time != null) {
        setState(() {
          _publishedAt = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (widget.news == null) {
        // Create
        await widget.repository.createNews(
          title: _titleController.text.trim(),
          summary: _summaryController.text.trim().isEmpty
              ? null
              : _summaryController.text.trim(),
          body: _bodyController.text.trim().isEmpty
              ? null
              : _bodyController.text.trim(),
          imageUrl: _imageUrlController.text.trim().isEmpty
              ? null
              : _imageUrlController.text.trim(),
          publishedAt: _publishedAt,
          sourceUrl: _sourceUrlController.text.trim().isEmpty
              ? null
              : _sourceUrlController.text.trim(),
        );
      } else {
        // Update
        await widget.repository.updateNews(
          id: widget.news!.id,
          title: _titleController.text.trim(),
          summary: _summaryController.text.trim().isEmpty
              ? null
              : _summaryController.text.trim(),
          body: _bodyController.text.trim().isEmpty
              ? null
              : _bodyController.text.trim(),
          imageUrl: _imageUrlController.text.trim().isEmpty
              ? null
              : _imageUrlController.text.trim(),
          publishedAt: _publishedAt,
          sourceUrl: _sourceUrlController.text.trim().isEmpty
              ? null
              : _sourceUrlController.text.trim(),
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
    final isEdit = widget.news != null;

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
                    isEdit ? 'Editar Notícia' : 'Nova Notícia',
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
                      // Title
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Título *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.title),
                        ),
                        maxLines: 2,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Título é obrigatório';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Summary
                      TextFormField(
                        controller: _summaryController,
                        decoration: const InputDecoration(
                          labelText: 'Resumo',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.short_text),
                          helperText: 'Breve descrição da notícia',
                        ),
                        maxLines: 3,
                      ),

                      const SizedBox(height: 16),

                      // Body
                      TextFormField(
                        controller: _bodyController,
                        decoration: const InputDecoration(
                          labelText: 'Conteúdo',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.article),
                          helperText: 'Conteúdo completo da notícia',
                        ),
                        maxLines: 8,
                      ),

                      const SizedBox(height: 16),

                      // Image URL
                      TextFormField(
                        controller: _imageUrlController,
                        decoration: const InputDecoration(
                          labelText: 'Nome da Imagem',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.image),
                          helperText:
                              'Nome do arquivo em assets/images/ (ex: trojan.png)',
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Source URL
                      TextFormField(
                        controller: _sourceUrlController,
                        decoration: const InputDecoration(
                          labelText: 'Link da Fonte',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.link),
                          helperText: 'Link para a fonte original da notícia',
                        ),
                        validator: (value) {
                          if (value != null &&
                              value.isNotEmpty &&
                              !Uri.tryParse(value)!.isAbsolute) {
                            return 'URL inválida';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Published At
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.calendar_today),
                        title: const Text('Data de Publicação'),
                        subtitle: Text(
                          _publishedAt != null
                              ? DateFormat(
                                  'dd/MM/yyyy HH:mm',
                                ).format(_publishedAt!)
                              : 'Não definida (rascunho)',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_publishedAt != null)
                              IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() => _publishedAt = null);
                                },
                                tooltip: 'Limpar data',
                              ),
                            ElevatedButton.icon(
                              onPressed: _selectDateTime,
                              icon: const Icon(Icons.edit_calendar),
                              label: const Text('Selecionar'),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Info text
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
                                'Notícias sem data de publicação ou com data futura ficam como rascunhos',
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
