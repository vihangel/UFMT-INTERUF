import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interufmt/core/data/repositories/auth_repository.dart';
import 'package:interufmt/core/data/services/auth_service.dart';
import 'package:interufmt/core/theme/app_styles.dart';
import 'package:interufmt/core/widgets/app_buttons.dart';
import 'package:interufmt/core/widgets/app_form_field.dart';
import 'package:interufmt/features/admin/admin_home_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminLoginPage extends StatefulWidget {
  static const String routename = '/admin-login';
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _loading = true);

    try {
      final authRepo = AuthRepository(AuthService(Supabase.instance.client));
      await authRepo.signInWithPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      // Se o login for bem-sucedido, verifique a role nos metadados do usuário
      final user = Supabase.instance.client.auth.currentUser;
      final role = user?.appMetadata['role'];

      if (role == 'admin') {
        if (mounted) {
          context.go(AdminHomePage.routename);
        }
      } else {
        // Se não for admin, deslogue e mostre erro
        await authRepo.signOut();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Acesso negado. Você não é um administrador.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ocorreu um erro inesperado: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Login do Administrador', style: AppStyles.title),
                Text(
                  'Acesso restrito ao painel de controle.',
                  style: AppStyles.body,
                ),
                const SizedBox(height: 32),
                AppFormField(
                  controller: _emailController,
                  label: 'E-mail',
                  hintText: 'admin@email.com',
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Informe o e-mail';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim())) {
                      return 'E-mail inválido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AppFormField(
                  controller: _passwordController,
                  label: 'Senha',
                  hintText: 'Digite sua senha',
                  isPassword: true,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Informe a senha' : null,
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: 'Entrar',
                  loading: _loading,
                  expand: true,
                  onPressed: _login,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
