import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:interufmt/features/home/presenter/home_state.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_styles.dart';

class HomePage extends StatelessWidget {
  static const String routename = '/';
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeState(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Consumer<HomeState>(
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
                                child: Form(
                                  key: state.formKey,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Entrar', style: AppStyles.title),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Faça login na sua conta.',
                                        style: AppStyles.body,
                                      ),
                                      const SizedBox(height: 24),

                                      // Email
                                      TextFormField(
                                        initialValue: state.email,
                                        decoration: const InputDecoration(
                                          labelText: 'E-mail',
                                          hintText: 'exemplo@email.com',
                                        ),
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        textInputAction: TextInputAction.next,
                                        validator: (v) {
                                          if (v == null || v.trim().isEmpty) {
                                            return 'Informe o e-mail';
                                          }
                                          if (!RegExp(
                                            r'^[^@]+@[^@]+\.[^@]+',
                                          ).hasMatch(v.trim())) {
                                            return 'E-mail inválido';
                                          }
                                          return null;
                                        },
                                        onChanged: (v) => state.email = v,
                                      ),
                                      const SizedBox(height: 16),

                                      // Senha
                                      TextFormField(
                                        initialValue: state.password,
                                        decoration: InputDecoration(
                                          labelText: 'Senha',
                                          suffixIcon: IconButton(
                                            onPressed: state.toggleObscure,
                                            icon: Icon(
                                              state.obscure
                                                  ? Icons.visibility_off
                                                  : Icons.visibility,
                                            ),
                                          ),
                                        ),
                                        obscureText: state.obscure,
                                        validator: (v) =>
                                            (v == null || v.isEmpty)
                                            ? 'Informe a senha'
                                            : null,
                                        onChanged: (v) => state.password = v,
                                      ),
                                      const SizedBox(height: 12),

                                      // Lembrar + Esqueceu
                                      Row(
                                        children: [
                                          Checkbox(
                                            visualDensity:
                                                VisualDensity.compact,
                                            materialTapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                            value: state.remember,
                                            onChanged: (v) =>
                                                state.rememberSetter =
                                                    v ?? false,

                                            splashRadius: 0,
                                          ),

                                          Text(
                                            'Lembrar login',
                                            style: AppStyles.body,
                                          ),

                                          TextButton(
                                            onPressed: state.onForgotPassword,
                                            child: Text(
                                              'Esqueceu a senha?',
                                              style: AppStyles.link,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),

                                      // CTA Entrar
                                      SizedBox(
                                        width: double.infinity,
                                        height: 52,
                                        child: ElevatedButton.icon(
                                          onPressed: state.onSubmit,
                                          icon: const Icon(
                                            Icons.arrow_forward_rounded,
                                          ),
                                          label: const Text('Entrar'),
                                        ),
                                      ),
                                      const SizedBox(height: 20),

                                      // Divisor "ou"
                                      Row(
                                        children: [
                                          const Expanded(child: Divider()),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0,
                                            ),
                                            child: Text(
                                              'ou',
                                              style: AppStyles.body,
                                            ),
                                          ),
                                          const Expanded(child: Divider()),
                                        ],
                                      ),
                                      const SizedBox(height: 16),

                                      // Social buttons
                                      _SocialButton(
                                        label: 'Continuar com o Google',
                                        asset: 'google.svg',
                                        onPressed: state.onGoogleSignIn,
                                      ),
                                      const SizedBox(height: 12),
                                      _SocialButton(
                                        label: 'Continuar com a Apple',
                                        asset: 'apple.svg',
                                        onPressed: state.onAppleSignIn,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Registro
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Não possui uma conta?',
                                  style: AppStyles.body,
                                ),
                                TextButton(
                                  onPressed: state.onGoToRegister,
                                  child: Text(
                                    'Registre-se aqui',
                                    style: AppStyles.link,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final String asset;
  final VoidCallback onPressed;

  const _SocialButton({
    required this.label,
    required this.asset,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 2),
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/$asset', height: 20),
            const SizedBox(width: 12),
            Text(label, style: AppStyles.labelButtonSmall),
          ],
        ),
      ),
    );
  }
}
