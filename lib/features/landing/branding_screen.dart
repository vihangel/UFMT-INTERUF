import 'package:flutter/material.dart';

// Esta tela será animada (fade-in), mas ainda sem o Timer.
// O 'main.dart' continua controlando quando ela aparece e desaparece.

class BrandingScreen extends StatefulWidget {
  const BrandingScreen({Key? key}) : super(key: key);

  @override
  State<BrandingScreen> createState() => _BrandingScreenState();
}

class _BrandingScreenState extends State<BrandingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  // 1. Variável _scaleAnimation foi REMOVIDA

  @override
  void initState() {
    super.initState();

    // Configura o AnimationController para 1 segundo de duração
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    // Animação de Fade-in para o texto e logo
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.5).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn, // Suaviza a entrada
      ),
    );

    // 2. Animação de Scale (Pop-in) foi REMOVIDA

    // Inicia a animação de fade-in
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black, // Fundo preto
        body: Center(
          // 3. O FadeTransition agora é o widget principal
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 4. O ScaleTransition foi REMOVIDO daqui
                Image.asset('assets/images/trojan.png', width: 80, height: 80),
                const SizedBox(height: 20),
                const Text(
                  'Desenvolvido pela Trojan',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
