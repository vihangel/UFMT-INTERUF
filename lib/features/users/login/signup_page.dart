import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interufmt/core/data/services/auth_service.dart';
import 'package:interufmt/core/data/services/profile_service.dart';
import 'package:interufmt/core/theme/app_styles.dart';
import 'package:interufmt/core/widgets/app_buttons.dart';
import 'package:interufmt/core/widgets/app_form_field.dart';
import 'package:interufmt/features/escolha_atletica_page.dart';
import 'package:interufmt/features/users/login/signup_viewmodel.dart';
import 'package:interufmt/features/users/login/widgets/or_divider.dart';
import 'package:interufmt/features/users/login/widgets/social_buttons.dart';
import 'package:provider/provider.dart';

class SignUpPage extends StatefulWidget {
  static const String routename = 'signup';
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _termsAccepted = false;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SignUpViewModel(
        context.read<AuthService>(),
        context.read<ProfileService>(),
      ),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
          ),
          body: SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Consumer<SignUpViewModel>(
                    builder: (context, vm, _) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: 22),
                          Card(
                            elevation: 1,
                            clipBehavior: Clip.antiAlias,
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      'Criar uma Conta',
                                      style: AppStyles.title,
                                    ),

                                    Text(
                                      'Vamos ser rápidos',
                                      style: AppStyles.body,
                                    ),
                                    SizedBox(height: 16),
                                    AppFormField(
                                      label: 'E-mail',
                                      hintText: 'exemplo@email.com',
                                      controller: _emailController,
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
                                    AppFormField(
                                      label: 'Crie uma senha',
                                      hintText: 'Digite sua senha',
                                      controller: _passwordController,
                                      isPassword: true,
                                      validator: (v) => (v == null || v.isEmpty)
                                          ? 'Informe a senha'
                                          : null,
                                    ),
                                    const SizedBox(height: 16),
                                    AppFormField(
                                      label: 'Repita a senha',
                                      hintText: 'Digite sua senha novamente',
                                      controller: _confirmPasswordController,
                                      isPassword: true,
                                      validator: (v) {
                                        if (v == null || v.isEmpty) {
                                          return 'Confirme a senha';
                                        }
                                        if (v != _passwordController.text) {
                                          return 'As senhas não coincidem';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Checkbox(
                                          visualDensity: VisualDensity.compact,
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          value: _termsAccepted,
                                          onChanged: (v) => setState(
                                            () => _termsAccepted = v ?? false,
                                          ),
                                          splashRadius: 0,
                                        ),
                                        Text(
                                          'Aceito os termos',
                                          style: AppStyles.body,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    AppButton(
                                      label: 'Criar',
                                      loading: vm.loading,
                                      expand: true,

                                      onPressed: () async {
                                        if (_formKey.currentState?.validate() ??
                                            false) {
                                          final ok = await vm.signUp(
                                            email: _emailController.text.trim(),
                                            password: _passwordController.text,
                                            acceptedTerms: _termsAccepted,
                                          );
                                          if (ok && mounted) {
                                            context.goNamed(
                                              EscolhaAtleticaPage.routename,
                                            );
                                          } else if (vm.error == null &&
                                              mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Enviamos um link de confirmação para o seu e-mail.',
                                                ),
                                              ),
                                            );
                                            context.pop();
                                          }
                                        }
                                      },
                                    ),
                                    const SizedBox(height: 20),
                                    const OrDivider(),
                                    const SizedBox(height: 16),
                                    SocialButtons(
                                      onGoogleSignIn: vm.onGoogleSignIn,
                                      onAppleSignIn: vm.onAppleSignIn,
                                    ),
                                    const SizedBox(height: 24),
                                    Text(
                                      'Seja bem-vindo(a)!',
                                      style: AppStyles.body,
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),
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
