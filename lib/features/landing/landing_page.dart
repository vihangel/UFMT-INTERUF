import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_styles.dart';

class LandingPage extends StatelessWidget {
  static const String routename = '/baixar-app';
  const LandingPage({super.key});

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Não foi possível abrir o link $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: AppColors.darkBlue.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: 50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.cardBackground.withOpacity(0.7),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Download',
                      style: AppStyles.title.copyWith(
                        fontSize: 40,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Nosso Novo App',
                      style: AppStyles.title2.copyWith(
                        color: AppColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Baixe o aplicativo oficial do InterUFMT para ficar por dentro de tudo que acontece nos jogos, acompanhar os resultados e torcer pela sua atlética!',
                      style: AppStyles.body.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton.icon(
                      onPressed: () {
                        _launchURL(
                          'https://apps.apple.com/us/app/interufmt/id6753128727',
                        );
                      },
                      icon: const FaIcon(
                        FontAwesomeIcons.apple,
                        color: AppColors.white,
                      ),
                      label: Text(
                        'Download na App Store',
                        style: AppStyles.button.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        _launchURL(
                          'https://drive.google.com/drive/folders/1arzWSy4OghkuR0Bl1EmHUQancFyMnbcC?usp=sharing',
                        );
                      },
                      icon: const FaIcon(
                        FontAwesomeIcons.googlePlay,
                        color: AppColors.white,
                      ),
                      label: Text(
                        'Download para Android',
                        style: AppStyles.button.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkGreen,
                        foregroundColor: AppColors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        'No momento o aplicativo está em revisão, devido a isso estamos disponibilizando no Android por meio do Drive.',
                        textAlign: TextAlign.center,
                        style: AppStyles.body.copyWith(
                          fontSize: 12,
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
