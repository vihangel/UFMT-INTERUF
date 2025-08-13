import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
import '../theme/app_styles.dart';

enum AppButtonVariant { filled, outline, text }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool expand;
  final double minWidth;
  final double height;
  final AppButtonVariant variant;
  final Widget? leading;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry? borderRadius;
  final bool hideTrailing;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.expand = false,
    this.minWidth = 120,
    this.height = 52,
    this.variant = AppButtonVariant.filled,
    this.leading,
    this.trailing,
    this.padding,
    this.borderRadius,
    this.hideTrailing = false,
  });

  const AppButton.outline({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.expand = false,
    this.minWidth = 120,
    this.height = 40,
    this.variant = AppButtonVariant.outline,
    this.leading,
    this.trailing,
    this.padding,
    this.borderRadius,
    this.hideTrailing = false,
  });

  const AppButton.text({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.expand = false,
    this.minWidth = 80,
    this.height = 44,
    this.variant = AppButtonVariant.text,
    this.leading,
    this.trailing,
    this.padding,
    this.borderRadius,
    this.hideTrailing = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final radius = borderRadius ?? BorderRadius.circular(4);

    // conteúdo (loader ou label + ícones)
    final Color fgForLoader = switch (variant) {
      AppButtonVariant.filled => cs.primary,
      _ => cs.primary,
    };

    Widget? effectiveTrailing = trailing;
    if (variant == AppButtonVariant.filled &&
        !hideTrailing &&
        trailing == null) {
      effectiveTrailing = SvgPicture.asset(AppIcons.icArrowRight, height: 20);
    }

    Widget content;
    if (loading) {
      content = _ThreeBounceLoader(size: 10, color: fgForLoader);
    } else {
      content = _AppButtonContent(
        label: label,
        leading: leading,
        trailing: effectiveTrailing,
        variant: variant,
      );
    }

    ButtonStyle style;
    switch (variant) {
      case AppButtonVariant.filled:
        style = ElevatedButton.styleFrom(
          minimumSize: Size(minWidth, height),
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
          backgroundColor: AppColors.white,
          foregroundColor: cs.primary,
          shape: RoundedRectangleBorder(borderRadius: radius),
          elevation: 0,
          shadowColor: Colors.transparent,
        );
        final btn = Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryButtonShadow,
                offset: const Offset(2, 2),
                blurRadius: 5.2,
                spreadRadius: -2,
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: loading ? null : onPressed,
            style: style,
            child: content,
          ),
        );
        return _AppButtonWrapper(
          expand: expand,
          minWidth: minWidth,
          child: btn,
        );

      case AppButtonVariant.outline:
        style = OutlinedButton.styleFrom(
          minimumSize: Size(minWidth, height),
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
          foregroundColor: cs.primary,
          backgroundColor: AppColors.white,
          side: BorderSide(color: Theme.of(context).dividerColor, width: 1.6),
          shape: RoundedRectangleBorder(borderRadius: radius),
        );
        final btn = OutlinedButton(
          onPressed: loading ? null : onPressed,
          style: style,
          child: content,
        );
        return _AppButtonWrapper(
          expand: expand,
          minWidth: minWidth,
          child: btn,
        );

      case AppButtonVariant.text:
        style = TextButton.styleFrom(
          minimumSize: Size(minWidth, height),
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 8),
          foregroundColor: cs.primary,
          shape: RoundedRectangleBorder(borderRadius: radius),
        );
        final btn = TextButton(
          onPressed: loading ? null : onPressed,
          style: style,
          child: content,
        );
        return _AppButtonWrapper(
          expand: expand,
          minWidth: minWidth,
          child: btn,
        );
    }
  }
}

class _AppButtonContent extends StatelessWidget {
  final String label;
  final Widget? leading;
  final Widget? trailing;
  final AppButtonVariant? variant;

  const _AppButtonContent({
    required this.label,
    this.leading,
    this.trailing,
    this.variant,
  });

  @override
  Widget build(BuildContext context) {
    TextStyle? style;
    if (variant == AppButtonVariant.filled) {
      style = AppStyles.buttonPrimary;
    } else if (variant == AppButtonVariant.text) {
      style = AppStyles.buttonText;
    } else {
      style = AppStyles.button;
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (leading != null) ...[leading!, const SizedBox(width: 10)],
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: style,
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 10), trailing!],
      ],
    );
  }
}

class _AppButtonWrapper extends StatelessWidget {
  final bool expand;
  final double minWidth;
  final Widget child;

  const _AppButtonWrapper({
    required this.expand,
    required this.minWidth,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (expand) {
      return SizedBox(width: double.infinity, child: child);
    }
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: minWidth),
        child: child,
      ),
    );
  }
}

/// Loader de “três bolinhas” (sem dependências)
class _ThreeBounceLoader extends StatefulWidget {
  final double size;
  final Color color;
  const _ThreeBounceLoader({required this.size, required this.color});

  @override
  State<_ThreeBounceLoader> createState() => _ThreeBounceLoaderState();
}

class _ThreeBounceLoaderState extends State<_ThreeBounceLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final List<Animation<double>> _scales;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _scales = [
      Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(
          parent: _c,
          curve: const Interval(0.00, 0.60, curve: Curves.easeInOut),
        ),
      ),
      Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(
          parent: _c,
          curve: const Interval(0.20, 0.80, curve: Curves.easeInOut),
        ),
      ),
      Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(
          parent: _c,
          curve: const Interval(0.40, 1.00, curve: Curves.easeInOut),
        ),
      ),
    ];
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ThreeBounceDot(
          animation: _scales[0],
          size: widget.size,
          color: widget.color,
        ),
        SizedBox(width: widget.size * 0.8),
        _ThreeBounceDot(
          animation: _scales[1],
          size: widget.size,
          color: widget.color,
        ),
        SizedBox(width: widget.size * 0.8),
        _ThreeBounceDot(
          animation: _scales[2],
          size: widget.size,
          color: widget.color,
        ),
      ],
    );
  }
}

class _ThreeBounceDot extends StatelessWidget {
  final Animation<double> animation;
  final double size;
  final Color color;

  const _ThreeBounceDot({
    required this.animation,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: animation,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}
