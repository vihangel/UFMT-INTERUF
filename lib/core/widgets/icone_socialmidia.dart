import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class IconeSocialmidia extends StatelessWidget {
  final IconData iconData;
  final String url;
  final double size;

  const IconeSocialmidia({
    Key? key,
    required this.iconData,
    required this.url,
    this.size = 40.0,
  }) : super(key: key);

  static Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Não foi possível abrir o link $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _launchURL(url),
      child: Icon(iconData, size: size),
    );
  }
}
