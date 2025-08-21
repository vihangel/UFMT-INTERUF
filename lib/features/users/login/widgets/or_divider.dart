import 'package:flutter/material.dart';

import '../../../../core/theme/app_styles.dart';

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text('ou', style: AppStyles.labelButtonSmall),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}
