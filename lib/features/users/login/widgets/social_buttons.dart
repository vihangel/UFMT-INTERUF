import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:interufmt/core/theme/app_icons.dart';
import 'package:interufmt/core/widgets/app_buttons.dart';

class SocialButtons extends StatelessWidget {
  final VoidCallback? onGoogleSignIn;
  final VoidCallback? onAppleSignIn;

  const SocialButtons({super.key, this.onGoogleSignIn, this.onAppleSignIn});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppButton.outline(
          label: 'Continuar com o Google',
          onPressed: onGoogleSignIn,
          expand: true,
          leading: SvgPicture.asset(AppIcons.icGoogle, height: 20),
        ),
        const SizedBox(height: 12),
        AppButton.outline(
          label: 'Continuar com a Apple',
          onPressed: onAppleSignIn,
          expand: true,
          leading: SvgPicture.asset(AppIcons.icApple, height: 20),
        ),
      ],
    );
  }
}
