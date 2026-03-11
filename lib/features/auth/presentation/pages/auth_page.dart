import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:lexcore/core/constants/app_constants.dart';
import 'package:lexcore/app/router/route_names.dart';
import 'package:lexcore/app/theme/app_colors.dart';
import 'package:lexcore/app/theme/app_spacing.dart';
import 'package:lexcore/features/auth/application/auth_controller.dart';
import 'package:lexcore/features/auth/domain/entities/auth_mode.dart';
import 'package:lexcore/features/auth/presentation/widgets/auth_shared_widgets.dart';
import 'package:lexcore/shared/widgets/app_mobile_canvas.dart';

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  static const _footerReservedHeight = 136.0;
  static const _topAlignmentSpacerHeight = 54.0;

  final _accountController = TextEditingController();
  final _credentialController = TextEditingController();
  bool _passwordVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(authControllerProvider.notifier).setMode(AuthMode.login);
    });
  }

  @override
  void dispose() {
    _accountController.dispose();
    _credentialController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final controller = ref.read(authControllerProvider.notifier);
    final account = _accountController.text.trim();
    final credential = _credentialController.text.trim();

    if (account.isEmpty || credential.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入邮箱和密码')));
      return;
    }

    final success = await controller.submit(
      account: account,
      credential: credential,
    );
    if (!mounted) return;
    if (!success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请先阅读并同意服务条款与隐私政策')));
      return;
    }

    context.go(RouteNames.homePath);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final controller = ref.read(authControllerProvider.notifier);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.surface,
      body: AppMobileCanvas(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const SizedBox(height: _topAlignmentSpacerHeight),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final bottomSafeArea = MediaQuery.viewPaddingOf(
                      context,
                    ).bottom;

                    return Stack(
                      children: [
                        SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(
                            AppSpacing.xl,
                            AppSpacing.xl,
                            AppSpacing.xl,
                            AppSpacing.xl +
                                _footerReservedHeight +
                                bottomSafeArea,
                          ),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 420),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const _BrandSection(),
                                  const SizedBox(height: 44),
                                  _MinimalInputField(
                                    label: '电子邮件',
                                    controller: _accountController,
                                    icon: Icons.mail_outline_rounded,
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  _MinimalInputField(
                                    label: '密码',
                                    controller: _credentialController,
                                    icon: Icons.lock_outline_rounded,
                                    obscureText: !_passwordVisible,
                                    suffix: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _passwordVisible = !_passwordVisible;
                                        });
                                      },
                                      icon: Icon(
                                        _passwordVisible
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        size: 20,
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                      tooltip: _passwordVisible
                                          ? '隐藏密码'
                                          : '显示密码',
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: Checkbox(
                                          value: state.agreeTerms,
                                          onChanged: state.loading
                                              ? null
                                              : (value) =>
                                                    controller.toggleAgreement(
                                                      value ?? false,
                                                    ),
                                          visualDensity: const VisualDensity(
                                            horizontal: -4,
                                            vertical: -4,
                                          ),
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.xs),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            top: 2,
                                          ),
                                          child: Text(
                                            '已阅读并同意《服务条款》《隐私政策》',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: AppColors
                                                      .onSurfaceVariant,
                                                  height: 1.35,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  FilledButton.icon(
                                    onPressed: state.loading ? null : _submit,
                                    icon: state.loading
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.mail_outline_rounded,
                                            size: 20,
                                          ),
                                    label: const Text('使用邮箱登录'),
                                    style: FilledButton.styleFrom(
                                      minimumSize: const Size.fromHeight(56),
                                      shape: const StadiumBorder(),
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: AppColors.onPrimary,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                  const _OrDivider(),
                                  const SizedBox(height: AppSpacing.lg),
                                  OutlinedButton.icon(
                                    onPressed: () {},
                                    icon: SvgPicture.asset(
                                      AuthIconAssets.google,
                                      width: 20,
                                      height: 20,
                                    ),
                                    label: const Text('使用 Google 账号继续'),
                                    style: OutlinedButton.styleFrom(
                                      minimumSize: const Size.fromHeight(56),
                                      shape: const StadiumBorder(),
                                      side: BorderSide(
                                        color: AppColors.primary.withValues(
                                          alpha: 0.24,
                                        ),
                                      ),
                                      foregroundColor: AppColors.onSurface,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                AppSpacing.xl,
                                0,
                                AppSpacing.xl,
                                AppSpacing.sm + bottomSafeArea,
                              ),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 420,
                                ),
                                child: _AuthFooter(
                                  onRegister: () =>
                                      context.go(RouteNames.registerPath),
                                  onTermsOfService: () => context.push(
                                    RouteNames.termsOfServicePath,
                                  ),
                                  onPrivacyPolicy: () => context.push(
                                    RouteNames.privacyPolicyPath,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrandSection extends StatelessWidget {
  const _BrandSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.all(Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Color(0x220B50DA),
                blurRadius: 14,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: SvgPicture.asset(
            AuthIconAssets.brandLogo,
            width: 36,
            height: 36,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          AppConstants.appName,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '${AppConstants.appSubtitle}\n${AppConstants.appSlogan}',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.onSurfaceVariant,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _MinimalInputField extends StatelessWidget {
  const _MinimalInputField({
    required this.label,
    required this.controller,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.suffix,
  });

  final String label;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(color: AppColors.onSurface),
        decoration: InputDecoration(
          labelText: label,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          alignLabelWithHint: false,
          prefixIcon: Icon(icon, size: 20, color: AppColors.onSurfaceVariant),
          prefixIconConstraints: const BoxConstraints(minWidth: 48),
          suffixIcon: suffix,
          filled: true,
          fillColor: AppColors.surfaceVariant,
          contentPadding: const EdgeInsets.fromLTRB(12, 20, 16, 10),
          border: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.outline),
          ),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.outline),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          labelStyle: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: AppColors.onSurfaceVariant),
          floatingLabelStyle: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.primary),
          floatingLabelAlignment: FloatingLabelAlignment.start,
          isDense: true,
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Divider(color: AppColors.surfaceVariant, thickness: 1),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Text(
            '或',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Expanded(
          child: Divider(color: AppColors.surfaceVariant, thickness: 1),
        ),
      ],
    );
  }
}

class _AuthFooter extends StatelessWidget {
  const _AuthFooter({
    required this.onRegister,
    required this.onTermsOfService,
    required this.onPrivacyPolicy,
  });

  final VoidCallback onRegister;
  final VoidCallback onTermsOfService;
  final VoidCallback onPrivacyPolicy;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '还没有账号？',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            TextButton(onPressed: onRegister, child: const Text('立即注册')),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(onPressed: onTermsOfService, child: const Text('服务条款')),
            Text(
              '·',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            TextButton(onPressed: onPrivacyPolicy, child: const Text('隐私政策')),
          ],
        ),
      ],
    );
  }
}
