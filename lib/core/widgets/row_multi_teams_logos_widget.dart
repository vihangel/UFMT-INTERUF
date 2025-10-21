import 'package:flutter/material.dart';

class RowMultiTeamsLogosWidget extends StatelessWidget {
  final List<String> logos;
  const RowMultiTeamsLogosWidget({super.key, required this.logos});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: -2,
      runSpacing: -2,
      children: logos.map((logo) {
        return Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey.withValues(alpha: 0.1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/images/$logo',
              width: 32,
              height: 32,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.shield, color: Colors.grey, size: 16);
              },
            ),
          ),
        );
      }).toList(),
    );
  }
}
