import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:lexcore/app/theme/app_colors.dart';
import 'package:lexcore/app/theme/app_spacing.dart';

class AuthIconAssets {
  const AuthIconAssets._();

  static const brandLogo = 'assets/icons/auth/brand_scale.svg';
  static const google = 'assets/icons/auth/google.svg';
  static const wechat = 'assets/icons/auth/wechat.svg';
}

class AuthPageFrame extends StatelessWidget {
  const AuthPageFrame({
    super.key,
    required this.child,
    this.topBar,
    this.contentTopPadding = AppSpacing.lg,
  });

  final Widget child;
  final Widget? topBar;
  final double contentTopPadding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBackground(context),
      body: SafeArea(
        child: Column(
          children: [
            ..._optionalWidget(topBar),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  contentTopPadding,
                  AppSpacing.xl,
                  AppSpacing.xl + MediaQuery.viewPaddingOf(context).bottom,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: child,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthTopBar extends StatelessWidget {
  const AuthTopBar({super.key, required this.title, this.onBack});

  final String title;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final appBarTitleStyle =
        Theme.of(context).appBarTheme.titleTextStyle ??
        Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700);

    return SizedBox(
      height: kToolbarHeight,
      child: Row(
        children: [
          SizedBox(
            width: kToolbarHeight,
            child: onBack == null
                ? const SizedBox.shrink()
                : IconButton(
                    onPressed: onBack,
                    icon: const Icon(Icons.arrow_back),
                    tooltip: '返回',
                  ),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: appBarTitleStyle,
            ),
          ),
          const SizedBox(width: kToolbarHeight),
        ],
      ),
    );
  }
}

class AuthFixedBottomLayout extends StatelessWidget {
  const AuthFixedBottomLayout({
    super.key,
    this.top,
    required this.content,
    required this.footer,
    this.contentPadding = const EdgeInsets.fromLTRB(
      AppSpacing.xl,
      AppSpacing.lg,
      AppSpacing.xl,
      AppSpacing.xl,
    ),
    this.maxWidth = 420,
    this.footerHorizontalPadding = AppSpacing.xl,
    this.footerTopPadding = AppSpacing.sm,
    this.footerBottomPadding = AppSpacing.sm,
    this.designWidth = 390,
    this.designHeight = 844,
    this.lockTextScaling = true,
  });

  final Widget? top;
  final Widget content;
  final Widget footer;
  final EdgeInsetsGeometry contentPadding;
  final double maxWidth;
  final double footerHorizontalPadding;
  final double footerTopPadding;
  final double footerBottomPadding;
  final double designWidth;
  final double designHeight;
  final bool lockTextScaling;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final effectiveMediaQuery = lockTextScaling
        ? mediaQuery.copyWith(textScaler: TextScaler.noScaling)
        : mediaQuery;
    final keyboardVisible = mediaQuery.viewInsets.bottom > 0;

    return SafeArea(
      maintainBottomViewPadding: true,
      child: MediaQuery(
        data: effectiveMediaQuery,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  mainAxisAlignment: keyboardVisible
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ..._optionalWidget(top),
                        Padding(
                          padding: contentPadding,
                          child: Center(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: maxWidth),
                              child: content,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        footerHorizontalPadding,
                        footerTopPadding,
                        footerHorizontalPadding,
                        footerBottomPadding,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: maxWidth),
                          child: footer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class AuthAccountLegalFooter extends StatelessWidget {
  const AuthAccountLegalFooter({
    super.key,
    required this.accountPromptText,
    required this.accountActionText,
    required this.onAccountAction,
    required this.onTermsOfService,
    required this.onPrivacyPolicy,
  });

  final String accountPromptText;
  final String accountActionText;
  final VoidCallback onAccountAction;
  final VoidCallback onTermsOfService;
  final VoidCallback onPrivacyPolicy;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              accountPromptText,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            TextButton(
              onPressed: onAccountAction,
              child: Text(accountActionText),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(onPressed: onTermsOfService, child: const Text('服务条款')),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              child: Text(
                '·',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
            TextButton(onPressed: onPrivacyPolicy, child: const Text('隐私政策')),
          ],
        ),
      ],
    );
  }
}

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.icon,
    required this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.suffix,
  });

  final String label;
  final String hintText;
  final IconData icon;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    final borderColor = _inputBorderColor(context);
    final secondaryTextColor = _secondaryTextColor(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.xxs, bottom: 6),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
              color: secondaryTextColor,
            ),
          ),
        ),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(icon, size: 20, color: secondaryTextColor),
            suffixIcon: suffix,
            filled: true,
            fillColor: _inputFillColor(context),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }
}

class AuthAgreementRow extends StatelessWidget {
  const AuthAgreementRow({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 22,
          height: 22,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              '我已阅读并同意《用户协议》《隐私政策》',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: _secondaryTextColor(context),
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AuthPrimaryActionButton extends StatelessWidget {
  const AuthPrimaryActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.loading,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: loading ? null : onPressed,
      icon: loading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(icon, size: 18),
      label: Text(label),
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        shape: const StadiumBorder(),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        textStyle: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class AuthDividerWithLabel extends StatelessWidget {
  const AuthDividerWithLabel({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final lineColor = _inputBorderColor(context);
    return Row(
      children: [
        Expanded(child: Divider(color: lineColor, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: _secondaryTextColor(context),
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
        ),
        Expanded(child: Divider(color: lineColor, thickness: 1)),
      ],
    );
  }
}

class AuthSocialButtonsRow extends StatelessWidget {
  const AuthSocialButtonsRow({
    super.key,
    this.onGooglePressed,
    this.onWechatPressed,
  });

  final VoidCallback? onGooglePressed;
  final VoidCallback? onWechatPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AuthSocialButton(
            label: 'Google',
            iconAsset: AuthIconAssets.google,
            onPressed: onGooglePressed,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: AuthSocialButton(
            label: '微信',
            iconAsset: AuthIconAssets.wechat,
            onPressed: onWechatPressed,
          ),
        ),
      ],
    );
  }
}

class AuthSocialButton extends StatelessWidget {
  const AuthSocialButton({
    super.key,
    required this.label,
    required this.iconAsset,
    this.onPressed,
  });

  final String label;
  final String iconAsset;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: SvgPicture.asset(iconAsset, width: 20, height: 20),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.24)),
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500),
      ),
    );
  }
}

Color _pageBackground(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF121212)
      : Colors.white;
}

Color _inputFillColor(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark
      ? const Color(0x80111827)
      : const Color(0xFFF8FAFC);
}

Color _inputBorderColor(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF1F2937)
      : const Color(0xFFE2E8F0);
}

Color _secondaryTextColor(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF9CA3AF)
      : const Color(0xFF64748B);
}

List<Widget> _optionalWidget(Widget? child) {
  if (child == null) {
    return const <Widget>[];
  }
  return <Widget>[child];
}
