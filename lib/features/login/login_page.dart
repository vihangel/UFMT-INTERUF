import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:interufmt/core/theme/app_icons.dart';
import 'package:interufmt/core/widgets/app_buttons.dart';
import 'package:interufmt/core/widgets/app_form_field.dart';
import 'package:interufmt/features/login/login_state.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_styles.dart';

class LoginPage extends StatelessWidget {
  static const String routename = 'login';
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginState(),
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
                  child: Consumer<LoginState>(
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Entrar', style: AppStyles.title),

                                    Text(
                                      'Faça login na sua conta.',
                                      style: AppStyles.body,
                                    ),
                                    const SizedBox(height: 24),

                                    // Email
                                    AppFormField(
                                      label: 'E-mail',
                                      hintText: 'exemplo@email.com',
                                      keyboardType: TextInputType.emailAddress,
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
                                    ),
                                    const SizedBox(height: 16),

                                    // Senha
                                    AppFormField(
                                      label: 'Senha',
                                      hintText: 'Digite sua senha',
                                      isPassword: true,
                                      validator: (v) => (v == null || v.isEmpty)
                                          ? 'Informe a senha'
                                          : null,
                                    ),
                                    const SizedBox(height: 12),

                                    // Lembrar + Esqueceu
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
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
                                          ],
                                        ),

                                        AppButton.text(
                                          label: 'Esqueceu a senha?',
                                          onPressed: state.onForgotPassword,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),

                                    // CTA Entrar
                                    AppButton(
                                      label: 'Entrar',
                                      onPressed: state.onSubmit,
                                      expand: true,
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
                                            style: AppStyles.labelButtonSmall,
                                          ),
                                        ),
                                        const Expanded(child: Divider()),
                                      ],
                                    ),
                                    const SizedBox(height: 16),

                                    // Social buttons
                                    AppButton.outline(
                                      label: 'Continuar com o Google',
                                      onPressed: state.onGoogleSignIn,
                                      expand: true,
                                      leading: SvgPicture.asset(
                                        AppIcons.icGoogle,
                                        height: 20,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    AppButton.outline(
                                      label: 'Continuar com a Apple',
                                      onPressed: state.onAppleSignIn,
                                      expand: true,
                                      leading: SvgPicture.asset(
                                        AppIcons.icApple,
                                        height: 20,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,

                                      children: [
                                        Text(
                                          'Não possui uma conta?',
                                          style: AppStyles.body,
                                        ),
                                        Expanded(
                                          child: AppButton(
                                            onPressed: state.onGoToRegister,
                                            label: 'Registre-se aqui',
                                            variant: AppButtonVariant.text,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
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
    );
  }
}
