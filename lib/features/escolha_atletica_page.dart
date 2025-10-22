import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/data/services/auth_service.dart';
import '../core/services/voting_service.dart';

class EscolhaAtleticaPage extends StatefulWidget {
  static const String routename = 'escolha_atletica';
  const EscolhaAtleticaPage({super.key});

  @override
  EscolhaAtleticaPageState createState() => EscolhaAtleticaPageState();
}

class EscolhaAtleticaPageState extends State<EscolhaAtleticaPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late VotingService _votingService;
  late AuthService _authService;
  int _currentPageIndex = 0;
  List<Map<String, dynamic>> _currentSeries = [];
  String _currentSeriesName = 'Série A';
  double _pageOffset = 0.0;

  List<Map<String, dynamic>> _serieA = [];
  List<Map<String, dynamic>> _serieB = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _isVoting = false;
  bool _isAuthenticating = false;
  bool _isAuthenticated = false;
  StreamSubscription<AuthState>? _authSubscription;

  final Map<int, PageController> _tabPageControllers = {};

  // Helper function to get the correct asset path for athletic logos
  String? _getAtleticAssetPath(String? logoUrl) {
    if (logoUrl == null || logoUrl.isEmpty) return null;
    return 'assets/images/$logoUrl';
  }

  /*
 Future<void> _incrementTorcidometro(String athleticId) async {
  // A classe Postgrest é a correta para usar o incremento
  final postgrest = Supabase.instance.client.from('torcidometro');
  
  try {
    // Tenta incrementar o campo 'pontos_torcida' em 1 para a atlética
    await postgrest
        .update({'pontos_torcida': postgrest.increment(1)}) 
        .eq('athletic_id', athleticId)
        .single();
        
  } catch (e) {
    // Se a linha não existir (primeiro voto), a gente a cria (INSERT)
    if (e.toString().contains('no rows found')) {
       await Supabase.instance.client
           .from('torcidometro')
           .insert({'athletic_id': athleticId, 'pontos_torcida': 1});
    }
    print('Erro ao atualizar torcidometro: $e');
  }
}
*/
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _votingService = VotingService(Supabase.instance.client);
    _authService = AuthService(Supabase.instance.client);
    _loadAthletics();

    _isAuthenticated = _authService.isAuthenticated;
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((
      data,
    ) {
      if (mounted) {
        setState(() {
          _isAuthenticated = data.session != null;
        });

        if (data.event == AuthChangeEvent.signedIn) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Login realizado com sucesso! Agora você pode votar.',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    });

    _tabController.addListener(() {
      setState(() {
        if (_tabController.index == 0) {
          _currentSeries = _serieA;
          _currentSeriesName = 'Série A';
        } else {
          _currentSeries = _serieB;
          _currentSeriesName = 'Série B';
        }
        _currentPageIndex =
            _tabPageControllers[_tabController.index]?.page?.round() ?? 0;
        _pageOffset =
            _tabPageControllers[_tabController.index]?.page ??
            _tabPageControllers[_tabController.index]?.initialPage.toDouble() ??
            0.0;
      });
    });
  }

  Future<void> _loadAthletics() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final serieAResponse = await Supabase.instance.client
          .from('athletics')
          .select('id, nickname, name, logo_url, series')
          .eq('series', 'A')
          .order('nickname');

      final serieBResponse = await Supabase.instance.client
          .from('athletics')
          .select('id, nickname, name, logo_url, series')
          .eq('series', 'B')
          .order('nickname');

      setState(() {
        _serieA = List<Map<String, dynamic>>.from(serieAResponse);
        _serieB = List<Map<String, dynamic>>.from(serieBResponse);
        _currentSeries = _serieA;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erro ao carregar atléticas: $error';
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tabPageControllers.forEach((key, controller) => controller.dispose());
    _authSubscription?.cancel();
    super.dispose();
  }

  void _saveAndNavigate() async {
    if (_currentSeries.isEmpty) return;

    final chosenAtletica = _currentSeries[_currentPageIndex];
    final athleticId = chosenAtletica['id'] as String;

    // Check if user is authenticated
    if (!_isAuthenticated) {
      // Show login dialog
      await _showLoginDialog(athleticId, chosenAtletica['nickname']!);
      return;
    }

    // User is authenticated, proceed with voting
    await _registerVoteAndNavigate(athleticId, chosenAtletica['nickname']!);
  }

  Future<void> _showLoginDialog(String athleticId, String nickname) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Login necessário'),
          content: const Text(
            'Para votar, você precisa fazer login com seu email.\n\n'
            'Você também pode continuar sem votar para explorar o aplicativo.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Continuar sem votar'),
              onPressed: () async {
                Navigator.of(context).pop();
                // Save preference without voting
                await _savePreferenceWithoutVoting(athleticId, nickname);
              },
            ),
            ElevatedButton(
              child: const Text('Fazer Login'),
              onPressed: () async {
                Navigator.of(context).pop();
                await _handleEmailLogin(athleticId, nickname);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleEmailLogin(String athleticId, String nickname) async {
    // Show email input dialog
    final email = await _showEmailInputDialog();

    if (email == null || email.isEmpty) {
      return; // User cancelled
    }

    setState(() {
      _isAuthenticating = true;
    });

    try {
      // Send magic link
      await _authService.signInWithMagicLink(email);

      if (mounted) {
        // Show dialog informing user to check email
        await _showWaitingForMagicLinkDialog(email);

        // Save pending vote data to complete after authentication
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('pending_vote_athletic_id', athleticId);
        await prefs.setString('pending_vote_nickname', nickname);

        // Navigate to a waiting screen or stay on current page
        // The auth state listener will handle the rest
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao enviar email: $error'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAuthenticating = false;
        });
      }
    }
  }

  Future<void> _showWaitingForMagicLinkDialog(String email) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to close
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Verifique seu Email'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Um link de autenticação foi enviado para $email.'),
                const SizedBox(height: 10),
                const Text(
                  'Clique no link para fazer login e registrar seu voto.',
                ),
              ],
            ),
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

  Future<String?> _showEmailInputDialog() async {
    final emailController = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Entrar com Email'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Digite seu email. Enviaremos um link mágico para autenticação.',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'seu@email.com',
                  border: OutlineInputBorder(),
                ),
              ),
              if (AuthService.allowedDomains.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Apenas emails dos domínios: ${AuthService.allowedDomains.map((d) => '@$d').join(', ')}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop(null);
              },
            ),
            ElevatedButton(
              child: const Text('Enviar'),
              onPressed: () {
                Navigator.of(context).pop(emailController.text.trim());
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _savePreferenceWithoutVoting(
    String athleticId,
    String nickname,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('chosen_athletic_name', nickname);
      await prefs.setString('chosen_athletic_id', athleticId);
      await prefs.setString('chosen_athletic_series', _currentSeriesName);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Preferência salva! Faça login depois para votar.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );

        context.go('/home');
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar preferência: $error'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _registerVoteAndNavigate(
    String athleticId,
    String nickname,
  ) async {
    setState(() {
      _isVoting = true;
    });

    try {
      // Register vote in database
      await _votingService.vote(athleticId);

      // Save to local preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('chosen_athletic_name', nickname);
      await prefs.setString('chosen_athletic_id', athleticId);
      await prefs.setString('chosen_athletic_series', _currentSeriesName);

      // Clear pending vote if exists
      await prefs.remove('pending_vote_athletic_id');
      await prefs.remove('pending_vote_nickname');

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Voto registrado para $nickname!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      // Navigate to home
      if (mounted) {
        context.go('/home');
      }
    } catch (error) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao registrar voto: $error'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isVoting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Column(
          children: [
            Expanded(child: Center(child: CircularProgressIndicator())),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadAthletics,
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_serieA.isEmpty && _serieB.isEmpty) {
      return Scaffold(
        body: Column(
          children: [
            Expanded(child: Center(child: Text('Nenhuma atlética encontrada'))),
          ],
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Escolha uma Atlética',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 20),
                    TabBar(
                      controller: _tabController,
                      tabs: const [
                        Tab(text: 'Série A'),
                        Tab(text: 'Série B'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: MediaQuery.of(context).size.width * 0.7,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildCarousel(_serieA, 0),
                          _buildCarousel(_serieB, 1),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_currentSeries.isNotEmpty) ...[
                      Text(
                        _currentSeries[_currentPageIndex]['nickname']!,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _currentSeries[_currentPageIndex]['name'] ?? 'Sem nome',
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const Spacer(),
                    ElevatedButton(
                      onPressed: _currentSeries.isNotEmpty && !_isVoting
                          ? _saveAndNavigate
                          : null,
                      child: _isVoting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text('Escolher'),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Você poderá mudar no futuro. Sua escolha influencia no Torcidômetro',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarousel(List<Map<String, dynamic>> series, int tabIndex) {
    if (series.isEmpty) {
      return const Center(
        child: Text('Nenhuma atlética encontrada nesta série'),
      );
    }

    if (!_tabPageControllers.containsKey(tabIndex)) {
      _tabPageControllers[tabIndex] = PageController(viewportFraction: 0.6);
      _tabPageControllers[tabIndex]!.addListener(() {
        if (_tabController.index == tabIndex) {
          setState(() {
            _pageOffset = _tabPageControllers[tabIndex]!.page!;
            _currentPageIndex = _pageOffset.round();
          });
        }
      });
    }

    return PageView.builder(
      controller: _tabPageControllers[tabIndex],
      itemCount: series.length,
      itemBuilder: (context, index) {
        double scale = 1.0;
        double opacity = 1.0;

        double page = _tabPageControllers[tabIndex]?.page ?? index.toDouble();
        double diff = (index - page).abs();

        scale = 1.0 - (diff * 0.2);
        scale = scale.clamp(0.6, 1.0);

        opacity = 1.0 - (diff * 0.5);
        opacity = opacity.clamp(0.5, 1.0);

        final logoUrl = series[index]['logo_url'] as String?;
        final assetPath = _getAtleticAssetPath(logoUrl);

        return Center(
          child: Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: opacity,
              child: assetPath != null
                  ? Image.asset(
                      assetPath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 50,
                            color: Colors.grey,
                          ),
                        );
                      },
                    )
                  : Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.sports,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}
