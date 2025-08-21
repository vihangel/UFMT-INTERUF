import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interufmt/core/widgets/app_buttons.dart';

import '../../../../core/theme/app_styles.dart';

class RegisterButton extends StatelessWidget {
  const RegisterButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Não possui uma conta?', style: AppStyles.body),
        Expanded(
          child: AppButton(
            onPressed: () => context.push('/signup'),
            label: 'Registre-se aqui',
            variant: AppButtonVariant.text,
          ),
        ),
      ],
    );
  }
}
