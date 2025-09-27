import 'package:flutter/material.dart';
import 'package:interufmt/core/utils/extensions.dart';

class NewsWidget extends StatelessWidget {
  final String? imageUrl;
  final String title;
  final String summary;
  final VoidCallback? onTap;

  const NewsWidget({
    super.key,
    this.imageUrl,
    required this.title,
    required this.summary,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            if (imageUrl != null && imageUrl!.isNotEmpty)
              Image.asset(
                'assets/images/Atlética ${imageUrl!.replaceAll('/', '').capitalize()}',
                fit: BoxFit.cover,
                height: 150,
                width: 150,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 150,
                  width: 150,
                  color: Colors.grey[300],
                  child: const Icon(
                    Icons.broken_image,
                    size: 60,
                    color: Colors.grey,
                  ),
                ),
              ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Título da notícia
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Descrição da notícia
                    Text(
                      summary,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
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
}
