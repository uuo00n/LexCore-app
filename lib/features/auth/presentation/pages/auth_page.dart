import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lexcore/app/adaptive/app_breakpoints.dart';
import 'package:lexcore/app/router/route_names.dart';
import 'package:lexcore/app/theme/app_colors.dart';
import 'package:lexcore/features/auth/application/auth_controller.dart';
import 'package:lexcore/features/auth/domain/entities/auth_mode.dart';
import 'package:lexcore/shared/components/app_input_field.dart';
import 'package:lexcore/shared/components/app_primary_button.dart';
import 'package:lexcore/shared/components/app_surface_card.dart';
import 'package:lexcore/shared/widgets/app_mobile_canvas.dart';

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  final _accountController = TextEditingController();
  final _credentialController = TextEditingController();

  @override
  void dispose() {
    _accountController.dispose();
    _credentialController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final controller = ref.read(authControllerProvider.notifier);
    final isLogin = state.mode == AuthMode.login;

    return Scaffold(
      body: AppMobileCanvas(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final viewport = AppBreakpoints.fromWidth(constraints.maxWidth);
              final desktopLayout =
                  viewport == AppViewportSize.expanded ||
                  viewport == AppViewportSize.ultra;

              if (desktopLayout) {
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 980),
                    child: AppSurfaceCard(
                      padding: EdgeInsets.zero,
                      child: Row(
                        children: [
                          const Expanded(flex: 5, child: _BrandPanel()),
                          Expanded(
                            flex: 6,
                            child: _AuthForm(
                              state: state,
                              isLogin: isLogin,
                              accountController: _accountController,
                              credentialController: _credentialController,
                              onModeChange: controller.setMode,
                              onAgreeChanged: (value) =>
                                  controller.toggleAgreement(value ?? false),
                              onSubmit: () async {
                                final success = await controller.submit(
                                  account: _accountController.text.trim(),
                                  credential: _credentialController.text.trim(),
                                );
                                if (!context.mounted) return;
                                if (!success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('请先勾选用户协议')),
                                  );
                                  return;
                                }
                                context.go(RouteNames.homePath);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return Column(
                children: [
                  const SizedBox(height: 220, child: _BrandPanel()),
                  Expanded(
                    child: _AuthForm(
                      state: state,
                      isLogin: isLogin,
                      accountController: _accountController,
                      credentialController: _credentialController,
                      onModeChange: controller.setMode,
                      onAgreeChanged: (value) =>
                          controller.toggleAgreement(value ?? false),
                      onSubmit: () async {
                        final success = await controller.submit(
                          account: _accountController.text.trim(),
                          credential: _credentialController.text.trim(),
                        );
                        if (!context.mounted) return;
                        if (!success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('请先勾选用户协议')),
                          );
                          return;
                        }
                        context.go(RouteNames.homePath);
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1E293B), Color(0xFF0B50DA)],
            ),
          ),
        ),
        Positioned(
          top: -24,
          right: -18,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          left: -28,
          bottom: -24,
          child: Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                Theme.of(context).scaffoldBackgroundColor,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        Align(
          alignment: const Alignment(0, 0.76),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x330B50DA),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_stories_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ],
    );
  }
}

class _AuthForm extends StatelessWidget {
  const _AuthForm({
    required this.state,
    required this.isLogin,
    required this.accountController,
    required this.credentialController,
    required this.onModeChange,
    required this.onAgreeChanged,
    required this.onSubmit,
  });

  final AuthViewState state;
  final bool isLogin;
  final TextEditingController accountController;
  final TextEditingController credentialController;
  final ValueChanged<AuthMode> onModeChange;
  final ValueChanged<bool?> onAgreeChanged;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
      children: [
        Text(
          'LexiAI',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 6),
        Text(
          '您的智能阅读与学习助手，开启深度阅读的新篇章。',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(height: 18),
        SegmentedButton<AuthMode>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(value: AuthMode.login, label: Text('登录')),
            ButtonSegment(value: AuthMode.register, label: Text('注册')),
          ],
          selected: {state.mode},
          onSelectionChanged: (value) => onModeChange(value.first),
        ),
        const SizedBox(height: 16),
        AppInputField(
          label: '手机号 / 邮箱',
          hint: '请输入手机号或邮箱',
          controller: accountController,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        AppInputField(
          label: isLogin ? '密码 / 验证码' : '设置密码',
          hint: isLogin ? '请输入密码或验证码' : '至少 8 位，包含字母和数字',
          controller: credentialController,
          obscureText: !isLogin,
        ),
        const SizedBox(height: 10),
        CheckboxListTile(
          value: state.agreeTerms,
          onChanged: onAgreeChanged,
          title: const Text('已阅读并同意《用户协议》《隐私政策》'),
          contentPadding: EdgeInsets.zero,
          visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
          controlAffinity: ListTileControlAffinity.leading,
        ),
        const SizedBox(height: 8),
        AppPrimaryButton(
          label: isLogin ? '立即登录' : '创建账号',
          icon: Icons.mail_outline,
          onPressed: state.loading ? null : () => onSubmit(),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.g_mobiledata_rounded, size: 22),
          label: const Text('使用 Google 账号继续'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            shape: const StadiumBorder(),
          ),
        ),
      ],
    );
  }
}
