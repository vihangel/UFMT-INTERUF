// lib/features/admin/admin_panel_page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:interufmt/core/data/services/auth_service.dart';
import 'package:provider/provider.dart';

class AdminPanelPage extends StatefulWidget {
  static const String routename = 'admin-panel';

  const AdminPanelPage({super.key});

  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> {
  bool _isLoading = true;
  bool _isAuthorized = false;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _checkAuthorization();
  }

  Future<void> _checkAuthorization() async {
    final authService = context.read<AuthService>();

    if (!authService.isAuthenticated) {
      setState(() {
        _isLoading = false;
        _isAuthorized = false;
      });
      return;
    }

    final isAuthorized = await authService.isAdminOrModerator();
    final role = await authService.getUserRole();

    setState(() {
      _isLoading = false;
      _isAuthorized = isAuthorized;
      _userRole = role;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Painel Administrativo')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isAuthorized) {
      return Scaffold(
        appBar: AppBar(title: const Text('Acesso Negado')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline, size: 80, color: Colors.red[300]),
                const SizedBox(height: 24),
                const Text(
                  'Acesso Restrito',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  'Você não tem permissão para acessar esta página.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {
                    context.pop();
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Voltar'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel Administrativo'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _userRole == 'admin'
                      ? Colors.purple[100]
                      : Colors.blue[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _userRole == 'admin' ? 'ADMIN' : 'MODERADOR',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _userRole == 'admin'
                        ? Colors.purple[900]
                        : Colors.blue[900],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              'Gerenciamento de Conteúdo',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Selecione uma categoria para gerenciar',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),

            // Grid of CRUD cards
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.0,
              children: [
                _buildCrudCard(
                  context: context,
                  title: 'Atléticas',
                  icon: FontAwesomeIcons.chessPawn,
                  color: Colors.blue,
                  onTap: () {
                    // TODO: Navigate to athletics CRUD page
                    _showComingSoonDialog(context, 'Atléticas');
                  },
                ),
                _buildCrudCard(
                  context: context,
                  title: 'Modalidades',
                  icon: FontAwesomeIcons.trophy,
                  color: Colors.orange,
                  onTap: () {
                    // TODO: Navigate to modalities CRUD page
                    _showComingSoonDialog(context, 'Modalidades');
                  },
                ),
                _buildCrudCard(
                  context: context,
                  title: 'Jogos',
                  icon: FontAwesomeIcons.futbol,
                  color: Colors.green,
                  onTap: () {
                    // TODO: Navigate to games CRUD page
                    _showComingSoonDialog(context, 'Jogos');
                  },
                ),
                _buildCrudCard(
                  context: context,
                  title: 'Notícias',
                  icon: FontAwesomeIcons.newspaper,
                  color: Colors.red,
                  onTap: () {
                    // TODO: Navigate to news CRUD page
                    _showComingSoonDialog(context, 'Notícias');
                  },
                ),
                _buildCrudCard(
                  context: context,
                  title: 'Atletas',
                  icon: FontAwesomeIcons.personRunning,
                  color: Colors.purple,
                  onTap: () {
                    // TODO: Navigate to athletes CRUD page
                    _showComingSoonDialog(context, 'Atletas');
                  },
                ),
                _buildCrudCard(
                  context: context,
                  title: 'Locais',
                  icon: FontAwesomeIcons.locationDot,
                  color: Colors.teal,
                  onTap: () {
                    // TODO: Navigate to venues CRUD page
                    _showComingSoonDialog(context, 'Locais');
                  },
                ),
                _buildCrudCard(
                  context: context,
                  title: 'Chaveamento',
                  icon: FontAwesomeIcons.diagramProject,
                  color: Colors.indigo,
                  onTap: () {
                    // TODO: Navigate to brackets CRUD page
                    _showComingSoonDialog(context, 'Chaveamento');
                  },
                ),
                if (_userRole == 'admin')
                  _buildCrudCard(
                    context: context,
                    title: 'Usuários',
                    icon: FontAwesomeIcons.users,
                    color: Colors.pink,
                    onTap: () {
                      // TODO: Navigate to users CRUD page
                      _showComingSoonDialog(context, 'Usuários');
                    },
                  ),
              ],
            ),
            const SizedBox(height: 32),

            // Statistics Section (optional)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.analytics_outlined, color: Colors.grey[700]),
                      const SizedBox(width: 8),
                      Text(
                        'Estatísticas Rápidas',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'As estatísticas detalhadas estarão disponíveis em breve.',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCrudCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: FaIcon(icon, size: 28, color: color),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Gerenciar',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.construction, color: Colors.orange[700]),
              const SizedBox(width: 8),
              const Text('Em Desenvolvimento'),
            ],
          ),
          content: Text(
            'A página de gerenciamento de $feature estará disponível em breve!',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
