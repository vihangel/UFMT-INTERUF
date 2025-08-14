import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interufmt/core/services/auth_service.dart';
import 'package:interufmt/core/services/profile_service.dart';
import 'package:interufmt/core/widgets/app_buttons.dart';
import 'package:interufmt/core/widgets/app_form_field.dart';
import 'package:interufmt/features/auth/signup_viewmodel.dart';
import 'package:provider/provider.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _termsAccepted = false;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SignUpViewModel(
        context.read<AuthService>(),
        context.read<ProfileService>(),
      ),
      child: Scaffold(
        appBar: AppBar(title: const Text('Criar Conta')),
        body: Consumer<SignUpViewModel>(
          builder: (context, vm, child) {
            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    AppFormField(
                      label: 'Nome Completo',
                      controller: _nameController,
                    ),
                    const SizedBox(height: 16),
                    AppFormField(
                      label: 'E-mail',
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
                      label: 'Senha',
                      controller: _passwordController,
                      isPassword: true,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Informe a senha' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Checkbox(
                          value: _termsAccepted,
                          onChanged: (v) =>
                              setState(() => _termsAccepted = v ?? false),
                        ),
                        const Text('Aceito os termos de uso'),
                      ],
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      label: 'Criar',
                      loading: vm.loading,
                      expand: true,
                      trailing: const Icon(Icons.arrow_forward_rounded),
                      onPressed: () async {
                        if (_formKey.currentState?.validate() ?? false) {
                          final ok = await vm.signUp(
                            email: _emailController.text.trim(),
                            password: _passwordController.text,
                            fullName: _nameController.text.trim(),
                            acceptedTerms: _termsAccepted,
                          );
                          if (ok) {
                            context.push('/choose-athletic'); // já logado
                          } else if (vm.error == null) {
                            // sem erro => provavelmente precisa confirmar e-mail
                            ScaffoldMessenger.of(context).showSnackBar(
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
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
