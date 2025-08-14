import 'package:flutter/material.dart';
import 'package:interufmt/features/auth/auth_viewmodel.dart';
import 'package:interufmt/features/login/login_viewmodel.dart';
import 'package:interufmt/features/login/widgets/or_divider.dart';
import 'package:interufmt/features/login/widgets/register_button.dart';
import 'package:interufmt/features/login/widgets/social_buttons.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_styles.dart';
import 'widgets/login_form.dart';

class LoginPage extends StatelessWidget {
  static const String routename = 'login';
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(context.read<AuthViewModel>()),
      child: Consumer<AuthViewModel>(
        builder: (context, auth, child) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (auth.error != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(auth.error!)));
            }
          });
          return child!;
        },
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus(); // Fecha o teclado ao tocar fora
          },
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            body: SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Consumer<LoginViewModel>(
                      builder: (context, state, _) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Logo + título
                            Column(
                              children: [
                                // SvgPicture.asset('assets/logo.svg', height: 72),
                                const SizedBox(height: 12),
                                Text(
                                  'LOGO \nNTERUFMT',
                                  style: AppStyles.title2,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Card do formulário
                            Card(
                              elevation: 1,
                              clipBehavior: Clip.antiAlias,
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    const LoginForm(),
                                    const SizedBox(height: 20),
                                    const OrDivider(),
                                    const SizedBox(height: 16),
                                    const SocialButtons(),
                                    const SizedBox(height: 16),
                                    const RegisterButton(),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
