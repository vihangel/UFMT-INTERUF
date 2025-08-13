import 'package:flutter/material.dart';

import '../../../core/theme/app_styles.dart';

class HomePage extends StatelessWidget {
  static const String routename = '/';
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Page')),
      body: Center(
        child: Text('Welcome to the Home Page!', style: AppStyles.body),
      ),
    );
  }
}
