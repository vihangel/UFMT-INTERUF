import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:interufmt/core/theme/app_icons.dart';
import 'package:interufmt/core/widgets/app_buttons.dart';
import 'package:interufmt/features/login/login_state.dart';
import 'package:provider/provider.dart';

class SocialButtons extends StatelessWidget {
  const SocialButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<LoginState>();
    return Column(
      children: [
        AppButton.outline(
          label: 'Continuar com o Google',
          onPressed: state.onGoogleSignIn,
          expand: true,
          leading: SvgPicture.asset(AppIcons.icGoogle, height: 20),
        ),
        const SizedBox(height: 12),
        AppButton.outline(
          label: 'Continuar com a Apple',
          onPressed: state.onAppleSignIn,
          expand: true,
          leading: SvgPicture.asset(AppIcons.icApple, height: 20),
        ),
      ],
    );
  }
}
