import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interufmt/core/widgets/app_buttons.dart';
import 'package:interufmt/core/widgets/app_form_field.dart';
import 'package:interufmt/features/users/login/auth/auth_viewmodel.dart';
import 'package:provider/provider.dart';

class UpdatePasswordPage extends StatefulWidget {
  static const routename = 'update-password';
  const UpdatePasswordPage({super.key});

  @override
  State<UpdatePasswordPage> createState() => _UpdatePasswordPageState();
}

class _UpdatePasswordPageState extends State<UpdatePasswordPage> {
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppFormField(
                  controller: _passwordController,
                  label: "Nova senha",
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira sua nova senha';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                AppButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await authViewModel.updatePassword(
                        _passwordController.text,
                        onSuccess: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Senha atualizada com sucesso!'),
                            ),
                          );
                          context.go('/');
                        },
                        onError: (message) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(message)));
                        },
                      );
                    }
                  },
                  label: "Atualizar senha",
                  loading: authViewModel.isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
