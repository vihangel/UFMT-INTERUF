import 'package:flutter/material.dart';
import 'package:interufmt/features/login/auth/auth_viewmodel.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  static const String routename = 'home';
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Home'),
            ElevatedButton(
              onPressed: () {
                context.read<AuthViewModel>().signOut();
              },
              child: const Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
}
