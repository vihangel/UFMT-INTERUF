import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:interufmt/core/theme/app_colors.dart';
import 'package:interufmt/core/theme/app_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class SectionsSocialMediaWidget extends StatelessWidget {
  const SectionsSocialMediaWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        border: Border.symmetric(
          horizontal: BorderSide(color: AppColors.inputBorder),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          Text(
            'Siga a liga das Atléticas da UFMT',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _SocialMediaButton(
                url: 'https://www.instagram.com/interufmt',
                label: 'Instagram',
                iconPath: AppIcons.icInstagram,
              ),
              _SocialMediaButton(
                url: 'https://twitter.com/interufmt',
                label: 'X (Twitter)',
                iconPath: AppIcons.icTwitter,
              ),

              _SocialMediaButton(
                url: 'https://www.youtube.com/interufmt',
                label: 'YouTube',
                iconPath: AppIcons.icYoutube,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SocialMediaButton extends StatelessWidget {
  final String url;
  final String label;
  final String iconPath;
  const _SocialMediaButton({
    required this.url,
    required this.label,
    required this.iconPath,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _launchURL(url),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            SvgPicture.asset(iconPath, width: 60, height: 60),
            SizedBox(height: 8),
            Text(label, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  static Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Não foi possível abrir o link $url');
    }
  }
}
