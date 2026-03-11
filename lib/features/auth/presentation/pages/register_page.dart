import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:lexcore/app/router/route_names.dart';
import 'package:lexcore/app/theme/app_colors.dart';
import 'package:lexcore/app/theme/app_spacing.dart';
import 'package:lexcore/features/auth/application/auth_controller.dart';
import 'package:lexcore/features/auth/domain/entities/auth_mode.dart';
import 'package:lexcore/features/auth/presentation/widgets/auth_shared_widgets.dart';
import 'package:lexcore/shared/widgets/app_mobile_canvas.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  static const _footerReservedHeight = 136.0;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(authControllerProvider.notifier).setMode(AuthMode.register);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final controller = ref.read(authControllerProvider.notifier);
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请完整填写注册信息')));
      return;
    }

    if (password != confirm) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('两次输入的密码不一致')));
      return;
    }

    controller.setMode(AuthMode.register);
    final success = await controller.submit(
      account: email,
      credential: password,
    );

    if (!mounted) return;
    if (!success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请先勾选用户协议')));
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
              AuthTopBar(
                title: '注册 LexiAI',
                onBack: () => context.go(RouteNames.authPath),
              ),
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
                            AppSpacing.md,
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
                                  Text(
                                    '创建您的账户',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: -0.3,
                                        ),
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    '加入 LexiAI，开启高效智能法律服务体验',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: AppColors.onSurfaceVariant,
                                        ),
                                  ),
                                  const SizedBox(height: 28),
                                  _RegisterInputField(
                                    label: '用户名',
                                    controller: _nameController,
                                    icon: Icons.person_outline_rounded,
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  _RegisterInputField(
                                    label: '电子邮箱',
                                    controller: _emailController,
                                    icon: Icons.mail_outline_rounded,
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  _RegisterInputField(
                                    label: '设置密码',
                                    controller: _passwordController,
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
                                  const SizedBox(height: AppSpacing.md),
                                  _RegisterInputField(
                                    label: '确认密码',
                                    controller: _confirmPasswordController,
                                    icon: Icons.lock_reset_outlined,
                                    obscureText: !_confirmPasswordVisible,
                                    suffix: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _confirmPasswordVisible =
                                              !_confirmPasswordVisible;
                                        });
                                      },
                                      icon: Icon(
                                        _confirmPasswordVisible
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        size: 20,
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                      tooltip: _confirmPasswordVisible
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
                                            '已阅读并同意《用户协议》《隐私政策》',
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
                                            Icons.person_add_alt_1_rounded,
                                            size: 20,
                                          ),
                                    label: const Text('立即注册'),
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
                                  const _RegisterSocialButtons(),
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
                                child: _RegisterFooter(
                                  onLogin: () =>
                                      context.go(RouteNames.authPath),
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

class _RegisterInputField extends StatelessWidget {
  const _RegisterInputField({
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

class _RegisterSocialButtons extends StatelessWidget {
  const _RegisterSocialButtons();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _RegisterSocialButton(
            label: 'Google',
            iconAsset: AuthIconAssets.google,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _RegisterSocialButton(
            label: '微信',
            iconAsset: AuthIconAssets.wechat,
          ),
        ),
      ],
    );
  }
}

class _RegisterSocialButton extends StatelessWidget {
  const _RegisterSocialButton({required this.label, required this.iconAsset});

  final String label;
  final String iconAsset;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: SvgPicture.asset(iconAsset, width: 20, height: 20),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        shape: const StadiumBorder(),
        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.24)),
        foregroundColor: AppColors.onSurface,
        textStyle: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _RegisterFooter extends StatelessWidget {
  const _RegisterFooter({required this.onLogin});

  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '已经有账户了？',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            TextButton(onPressed: onLogin, child: const Text('登录')),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(onPressed: () {}, child: const Text('服务条款')),
            Text(
              '·',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            TextButton(onPressed: () {}, child: const Text('隐私政策')),
          ],
        ),
      ],
    );
  }
}
