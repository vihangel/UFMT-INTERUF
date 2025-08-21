import 'package:flutter/material.dart';

class ChooseAthleticPage extends StatelessWidget {
  static const String routename = 'choose-athletic';
  const ChooseAthleticPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escolha uma Atlética')),
      body: const Center(child: Text('Página de Escolha de Atlética')),
    );
  }
}
