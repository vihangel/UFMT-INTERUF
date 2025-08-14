import 'package:flutter/material.dart';
import 'package:interufmt/core/services/auth_service.dart';
import 'package:interufmt/core/widgets/app_buttons.dart';
import 'package:interufmt/core/widgets/app_form_field.dart';
import 'package:provider/provider.dart';

class UpdatePasswordPage extends StatefulWidget {
  static const String routename = 'update-password';
  const UpdatePasswordPage({super.key});

  @override
  State<UpdatePasswordPage> createState() => _UpdatePasswordPageState();
}

class _UpdatePasswordPageState extends State<UpdatePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();
    return Scaffold(
      appBar: AppBar(title: const Text('Criar Nova Senha')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              AppFormField(
                label: 'Nova Senha',
                controller: _passwordController,
                isPassword: true,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Informe a nova senha' : null,
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'Salvar Nova Senha',
                loading: _loading,
                expand: true,
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    setState(() => _loading = true);
                    try {
                      await authService.updatePassword(
                        _passwordController.text,
                      );
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Senha atualizada com sucesso!'),
                          ),
                        );
                        Navigator.of(
                          context,
                        ).popUntil((route) => route.isFirst);
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(e.toString())));
                      }
                    } finally {
                      if (mounted) {
                        setState(() => _loading = false);
                      }
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
