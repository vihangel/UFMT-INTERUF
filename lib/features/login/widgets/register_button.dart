import 'package:flutter/material.dart';
import 'package:interufmt/core/widgets/app_buttons.dart';
import 'package:interufmt/features/login/login_viewmodel.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_styles.dart';

class RegisterButton extends StatelessWidget {
  const RegisterButton({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<LoginViewModel>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Não possui uma conta?', style: AppStyles.body),
        Expanded(
          child: AppButton(
            onPressed: state.onGoToRegister,
            label: 'Registre-se aqui',
            variant: AppButtonVariant.text,
          ),
        ),
      ],
    );
  }
}
