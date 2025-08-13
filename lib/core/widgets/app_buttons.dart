import 'package:flutter/material.dart';

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
  });

  const AppButton.outline({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.expand = false,
    this.minWidth = 120,
    this.height = 52,
    this.variant = AppButtonVariant.outline,
    this.leading,
    this.trailing,
    this.padding,
    this.borderRadius,
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
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final radius = borderRadius ?? BorderRadius.circular(10);

    // conteúdo (loader ou label + ícones)
    final Color fgForLoader = switch (variant) {
      AppButtonVariant.filled => cs.onPrimary,
      _ => cs.primary,
    };

    Widget content;
    if (loading) {
      content = _ThreeBounceLoader(size: 10, color: fgForLoader);
    } else {
      content = _AppButtonContent(
        label: label,
        leading: leading,
        trailing: trailing,
      );
    }

    ButtonStyle style;
    switch (variant) {
      case AppButtonVariant.filled:
        style = ElevatedButton.styleFrom(
          minimumSize: Size(minWidth, height),
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: radius),
          elevation: 0,
        );
        final btn = ElevatedButton(
          onPressed: loading ? null : onPressed,
          style: style,
          child: content,
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

  const _AppButtonContent({required this.label, this.leading, this.trailing});

  @override
  Widget build(BuildContext context) {
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
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
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
