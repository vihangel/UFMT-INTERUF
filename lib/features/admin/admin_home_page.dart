import 'package:flutter/material.dart';

class AdminHomePage extends StatelessWidget {
  static const String routename = 'admin-home';
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Admin Home Page')));
  }
}
