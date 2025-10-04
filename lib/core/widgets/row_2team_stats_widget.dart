import 'package:flutter/material.dart';
import 'package:interufmt/core/theme/app_colors.dart';

class Row2teamStatsWidget extends StatelessWidget {
  final String? teamALogo;
  final String? teamBLogo;
  final int? scoreA;
  final int? scoreB;
  final int displayScoreA;
  final int displayScoreB;

  const Row2teamStatsWidget({
    super.key,
    this.teamALogo,
    this.teamBLogo,
    this.scoreA,
    this.scoreB,
    required this.displayScoreA,
    required this.displayScoreB,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Team A
          teamALogo != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/images/$teamALogo',
                    width: 76,
                    height: 76,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.shield, color: Colors.grey);
                    },
                  ),
                )
              : const Icon(Icons.shield, color: Colors.grey),

          Text(
            '$displayScoreA X $displayScoreB',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.secondaryText,
            ),
          ),

          // Team B
          teamBLogo != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/images/$teamBLogo',
                    width: 76,
                    height: 76,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.shield, color: Colors.grey);
                    },
                  ),
                )
              : const Icon(Icons.shield, color: Colors.grey),
        ],
      ),
    );
  }
}
