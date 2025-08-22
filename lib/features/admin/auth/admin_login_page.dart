import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interufmt/core/theme/app_styles.dart';
import 'package:interufmt/core/widgets/app_buttons.dart';
import 'package:interufmt/core/widgets/app_form_field.dart';
import 'package:interufmt/features/admin/auth/admin_login_viewmodel.dart';
import 'package:interufmt/features/users/login/login_page.dart';
import 'package:provider/provider.dart';

class AdminLoginPage extends StatefulWidget {
  static const String routename = '/admin-login';
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  late final AdminLoginViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AdminLoginViewModel();
    _viewModel.addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    super.dispose();
  }

  void _onViewModelChanged() {
    if (_viewModel.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_viewModel.errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Consumer<AdminLoginViewModel>(
              builder: (context, viewModel, child) {
                return Form(
                  key: viewModel.formKey,
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
                        controller: viewModel.emailController,
                        label: 'E-mail',
                        hintText: 'admin@email.com',
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
                        controller: viewModel.passwordController,
                        label: 'Senha',
                        hintText: 'Digite sua senha',
                        isPassword: true,
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Informe a senha' : null,
                      ),
                      const SizedBox(height: 24),
                      AppButton(
                        label: 'Entrar',
                        loading: viewModel.loading,
                        expand: true,
                        onPressed: () => viewModel.login(context),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => context.goNamed(LoginPage.routename),
                        child: const Text('Voltar ao login de usuário'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
