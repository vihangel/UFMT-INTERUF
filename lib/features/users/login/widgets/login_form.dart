import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interufmt/core/widgets/app_buttons.dart';
import 'package:interufmt/core/widgets/app_form_field.dart';
import 'package:interufmt/features/choose_athletic_page.dart';
import 'package:interufmt/features/users/home/home_page.dart';
import 'package:interufmt/features/users/login/forgot_password_page.dart';
import 'package:interufmt/features/users/login/login_viewmodel.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_styles.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<LoginViewModel>();
    return Form(
      key: state.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Entrar', style: AppStyles.title),
          Text('Faça login na sua conta.', style: AppStyles.body),
          const SizedBox(height: 24),

          // Email
          AppFormField(
            label: 'E-mail',
            hintText: 'exemplo@email.com',
            keyboardType: TextInputType.emailAddress,
            onChanged: (v) => state.emailSetter = v,
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

          // Senha
          AppFormField(
            label: 'Senha',
            hintText: 'Digite sua senha',
            isPassword: true,
            onChanged: (v) => state.passwordSetter = v,
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Informe a senha' : null,
          ),
          const SizedBox(height: 12),

          // Lembrar + Esqueceu
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Checkbox(
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    value: state.remember,
                    onChanged: (v) => state.rememberSetter = v ?? false,
                    splashRadius: 0,
                  ),
                  Text('Lembrar login', style: AppStyles.body),
                ],
              ),
              AppButton.text(
                label: 'Esqueceu a senha?',
                onPressed: () => context.goNamed(ForgotPasswordPage.routename),
              ),
            ],
          ),

          const SizedBox(height: 8),
          // CTA Entrar
          AppButton(
            label: 'Entrar',
            loading: state.loading,
            expand: true,

            onPressed: () async {
              if (state.formKey.currentState?.validate() ?? false) {
                final result = await state.login(state.email, state.password);
                if (context.mounted) {
                  switch (result) {
                    case LoginResult.successHome:
                      context.goNamed(HomePage.routename);
                      break;
                    case LoginResult.successChooseAthletic:
                      context.goNamed(ChooseAthleticPage.routename);
                      break;
                    case LoginResult.failure:
                      break;
                  }
                }
              }
            },
          ),

          const SizedBox(height: 8),

          Center(
            child: TextButton(
              onPressed: () => context.goNamed('home'),
              child: const Text(
                'Pular login',
                style: TextStyle(decoration: TextDecoration.underline),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
