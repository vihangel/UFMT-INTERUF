import 'package:flutter/material.dart';
import 'package:interufmt/core/widgets/shimmer_loading.dart';

class TabelaClassificacaoShimmer extends StatelessWidget {
  const TabelaClassificacaoShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ShimmerLoading.rectangular(height: 12, width: 100),

            for (int i = 0; i < 4; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    const ShimmerLoading.circular(width: 16, height: 24),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: ShimmerLoading.rectangular(height: 12),
                    ),
                    const SizedBox(width: 16),
                    const ShimmerLoading.rectangular(height: 12, width: 40),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
