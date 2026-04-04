import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import 'package:lexcore/features/profile/application/profile_personal_info_controller.dart';
import 'package:lexcore/features/profile/application/profile_providers.dart';
import 'package:lexcore/features/profile/domain/entities/profile_personal_info.dart';
import 'package:lexcore/features/profile/presentation/widgets/profile_avatar.dart';
import 'package:lexcore/shared/widgets/app_page_scaffold.dart';

class ProfilePersonalInfoPage extends ConsumerWidget {
  const ProfilePersonalInfoPage({super.key});

  static const _languageOptions = ['简体中文', '繁體中文', 'English'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<String?>(
      profilePersonalInfoControllerProvider.select(
        (state) => state.feedbackMessage,
      ),
      (previous, message) {
        if (message == null || message.isEmpty) {
          return;
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) {
            return;
          }
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
          ref
              .read(profilePersonalInfoControllerProvider.notifier)
              .clearFeedbackMessage();
        });
      },
    );

    final state = ref.watch(profilePersonalInfoControllerProvider);
    final controller = ref.read(profilePersonalInfoControllerProvider.notifier);

    if (state.loading) {
      return AppPageScaffold(
        title: '个人信息',
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final info = state.info;

    return AppPageScaffold(
      title: '个人信息',
      body: ListView(
        children: [
          _ProfileHeader(
            name: _displayOrUnset(info.name),
            email: _displayOrUnset(info.email),
            avatarPath: info.avatarPath,
            onAvatarEditTap: () => _showAvatarActionSheet(context, controller),
          ),
          const SizedBox(height: 14),
          _CompletenessCard(
            completionPercent: state.completionPercent,
            missingPriorityFields: state.missingPriorityFields,
          ),
          const SizedBox(height: 20),
          const _SectionHeader(text: '基础资料'),
          const SizedBox(height: 8),
          _InfoActionRow(
            icon: Icons.person_outline,
            title: '姓名',
            subtitle: _displayOrUnset(info.name),
            onTap: () => _showTextEditSheet(
              context: context,
              title: '修改姓名',
              label: '姓名',
              icon: Icons.person_outline,
              hintText: '请输入姓名',
              initialValue: info.name,
              keyboardType: TextInputType.name,
              validator: _validateName,
              onSaved: controller.updateName,
            ),
          ),
          _InfoActionRow(
            icon: Icons.phone_outlined,
            title: '手机号',
            subtitle: _displayOrUnset(info.phone),
            onTap: () => _showPhoneEditSheet(
              context: context,
              currentPhone: info.phone,
              onSaved: controller.updatePhone,
            ),
          ),
          _InfoActionRow(
            icon: Icons.email_outlined,
            title: '邮箱',
            subtitle: _displayOrUnset(info.email),
            onTap: () => _showTextEditSheet(
              context: context,
              title: '修改邮箱',
              label: '邮箱',
              icon: Icons.email_outlined,
              hintText: '请输入邮箱地址',
              initialValue: info.email,
              keyboardType: TextInputType.emailAddress,
              validator: _validateEmail,
              onSaved: controller.updateEmail,
            ),
          ),
          const SizedBox(height: 18),
          const _SectionHeader(text: '职业信息'),
          const SizedBox(height: 8),
          _InfoActionRow(
            icon: Icons.work_outline,
            title: '职位角色',
            subtitle: _displayOrUnset(info.role),
            onTap: () => _showTextEditSheet(
              context: context,
              title: '修改职位角色',
              label: '职位角色',
              icon: Icons.work_outline,
              hintText: '请输入职位角色',
              initialValue: info.role,
              keyboardType: TextInputType.text,
              validator: _validateRequired,
              onSaved: controller.updateRole,
            ),
          ),
          _InfoActionRow(
            icon: Icons.business_outlined,
            title: '所属机构',
            subtitle: _displayOrUnset(info.organization),
            onTap: () => _showTextEditSheet(
              context: context,
              title: '修改所属机构',
              label: '所属机构',
              icon: Icons.business_outlined,
              hintText: '请输入所属机构',
              initialValue: info.organization,
              keyboardType: TextInputType.text,
              validator: _validateRequired,
              onSaved: controller.updateOrganization,
            ),
          ),
          _InfoActionRow(
            icon: Icons.category_outlined,
            title: '业务领域',
            subtitle: _formatPracticeAreas(info.practiceAreas),
            onTap: () => _showTextEditSheet(
              context: context,
              title: '修改业务领域',
              label: '业务领域',
              icon: Icons.category_outlined,
              hintText: '使用 / 或 , 分隔多个领域',
              initialValue: _formatPracticeAreas(info.practiceAreas),
              keyboardType: TextInputType.text,
              validator: _validatePracticeAreas,
              maxLines: 2,
              onSaved: (value) =>
                  controller.updatePracticeAreas(_splitPracticeAreas(value)),
            ),
          ),
          const SizedBox(height: 18),
          const _SectionHeader(text: '偏好设置'),
          const SizedBox(height: 8),
          _InfoActionRow(
            icon: Icons.language_outlined,
            title: '语言偏好',
            subtitle: _displayOrUnset(info.language),
            onTap: () => _showLanguageActionSheet(
              context: context,
              controller: controller,
              currentLanguage: info.language,
            ),
          ),
          _InfoSwitchRow(
            icon: Icons.notifications_outlined,
            title: '通知设置',
            subtitle: info.notificationsEnabled ? '已开启' : '已关闭',
            value: info.notificationsEnabled,
            onChanged: controller.updateNotifications,
          ),
        ],
      ),
    );
  }

  Future<void> _showAvatarActionSheet(
    BuildContext context,
    ProfilePersonalInfoController controller,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  Icons.photo_library_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text('从相册选择'),
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  await controller.pickAvatarFromGallery();
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.refresh_outlined,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                title: const Text('移除头像'),
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  await controller.resetAvatar();
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.close,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                title: const Text('取消'),
                onTap: () => Navigator.of(sheetContext).pop(),
              ),
              const SizedBox(height: 6),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showLanguageActionSheet({
    required BuildContext context,
    required ProfilePersonalInfoController controller,
    required String currentLanguage,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final option in _languageOptions)
                ListTile(
                  title: Text(option),
                  trailing: option == currentLanguage
                      ? Icon(
                          Icons.check,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    await controller.updateLanguage(option);
                  },
                ),
              const SizedBox(height: 6),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showPhoneEditSheet({
    required BuildContext context,
    required String currentPhone,
    required Future<void> Function(String value) onSaved,
  }) async {
    final initialNumber = await _resolveInitialPhoneNumber(currentPhone);
    if (!context.mounted) {
      return;
    }
    PhoneNumber editingNumber = initialNumber;
    var isValid = ProfilePersonalInfo.isValidE164Phone(currentPhone);
    String? errorText;

    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Theme.of(
        context,
      ).colorScheme.surface.withValues(alpha: 0),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (statefulContext, setModalState) {
            final theme = Theme.of(statefulContext);
            final bottomInset = MediaQuery.viewInsetsOf(
              statefulContext,
            ).bottom.clamp(0.0, 320.0);
            return Padding(
              padding: EdgeInsets.only(bottom: bottomInset),
              child: Material(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                clipBehavior: Clip.antiAlias,
                child: SafeArea(
                  top: false,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            key: const ValueKey('phone-edit-sheet-handle'),
                            width: 42,
                            height: 4,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.outlineVariant,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '修改手机号',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '支持国际区号，号码将以国际标准保存',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          key: const ValueKey('phone-edit-sheet-card'),
                          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: InternationalPhoneNumberInput(
                            selectorConfig: const SelectorConfig(
                              selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                              setSelectorButtonAsPrefixIcon: false,
                              useBottomSheetSafeArea: true,
                              useEmoji: false,
                              leadingPadding: 0,
                              trailingSpace: false,
                            ),
                            spaceBetweenSelectorAndTextField: 16,
                            selectorTextStyle: theme.textTheme.bodyMedium
                                ?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                            initialValue: initialNumber,
                            keyboardType: TextInputType.phone,
                            autoValidateMode: AutovalidateMode.disabled,
                            formatInput: true,
                            ignoreBlank: false,
                            hintText: '请输入手机号',
                            onInputChanged: (number) {
                              editingNumber = number;
                            },
                            onInputValidated: (validated) {
                              isValid = validated;
                              if (validated && errorText != null) {
                                setModalState(() {
                                  errorText = null;
                                });
                              }
                            },
                            inputDecoration: _buildProfileInputDecoration(
                              theme,
                              label: '手机号',
                              hintText: '请输入手机号',
                              alignLabelWithHint: false,
                            ),
                          ),
                        ),
                        if (errorText != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            errorText!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ],
                        const SizedBox(height: 14),
                        Divider(
                          height: 1,
                          color: theme.colorScheme.outlineVariant,
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () async {
                              final phone =
                                  editingNumber.phoneNumber?.trim() ?? '';
                              if (!isValid ||
                                  !ProfilePersonalInfo.isValidE164Phone(
                                    phone,
                                  )) {
                                setModalState(() {
                                  errorText = '请输入有效手机号';
                                });
                                return;
                              }
                              await onSaved(phone);
                              if (sheetContext.mounted) {
                                Navigator.of(sheetContext).pop();
                              }
                            },
                            child: const Text('保存'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<PhoneNumber> _resolveInitialPhoneNumber(String currentPhone) async {
    final value = currentPhone.trim();
    if (ProfilePersonalInfo.isValidE164Phone(value)) {
      try {
        return await PhoneNumber.getRegionInfoFromPhoneNumber(value);
      } catch (_) {
        return PhoneNumber(phoneNumber: value, isoCode: 'CN');
      }
    }

    if (RegExp(r'^1\d{10}$').hasMatch(value)) {
      final cnValue = '+86$value';
      try {
        return await PhoneNumber.getRegionInfoFromPhoneNumber(cnValue);
      } catch (_) {
        return PhoneNumber(phoneNumber: cnValue, isoCode: 'CN');
      }
    }

    return PhoneNumber(isoCode: 'CN', dialCode: '+86');
  }

  Future<void> _showTextEditSheet({
    required BuildContext context,
    required String title,
    required String label,
    required IconData icon,
    required String hintText,
    required String initialValue,
    required TextInputType keyboardType,
    required String? Function(String value) validator,
    required Future<void> Function(String value) onSaved,
    int maxLines = 1,
  }) async {
    final controller = TextEditingController(text: initialValue);
    String? errorText;

    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (statefulContext, setModalState) {
            final bottomInset = MediaQuery.viewInsetsOf(
              statefulContext,
            ).bottom.clamp(0.0, 320.0);
            return Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(statefulContext).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    _ProfileMinimalInputField(
                      label: label,
                      icon: icon,
                      controller: controller,
                      keyboardType: keyboardType,
                      hintText: hintText,
                      maxLines: maxLines,
                    ),
                    if (errorText != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        errorText!,
                        style: Theme.of(statefulContext).textTheme.bodySmall
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.error,
                            ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () async {
                          final value = controller.text.trim();
                          final validationError = validator(value);
                          if (validationError != null) {
                            setModalState(() {
                              errorText = validationError;
                            });
                            return;
                          }
                          await onSaved(value);
                          if (sheetContext.mounted) {
                            Navigator.of(sheetContext).pop();
                          }
                        },
                        child: const Text('保存'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatPracticeAreas(List<String> areas) {
    if (areas.isEmpty) {
      return '未设置';
    }
    return areas.join(' / ');
  }

  List<String> _splitPracticeAreas(String source) {
    return source
        .split(RegExp(r'[，,/、]'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  String _displayOrUnset(String value) {
    return value.trim().isEmpty ? '未设置' : value.trim();
  }

  String? _validateName(String value) {
    if (value.isEmpty) {
      return '请输入姓名';
    }
    if (value.length > 32) {
      return '姓名长度不能超过32个字符';
    }
    return null;
  }

  String? _validateEmail(String value) {
    if (value.isEmpty) {
      return '请输入邮箱';
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
      return '请输入有效的邮箱地址';
    }
    return null;
  }

  String? _validatePracticeAreas(String value) {
    final areas = _splitPracticeAreas(value);
    if (areas.isEmpty) {
      return '请至少输入一个业务领域';
    }
    return null;
  }

  String? _validateRequired(String value) {
    if (value.isEmpty) {
      return '请输入内容';
    }
    return null;
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.name,
    required this.email,
    required this.avatarPath,
    required this.onAvatarEditTap,
  });

  final String name;
  final String email;
  final String? avatarPath;
  final VoidCallback onAvatarEditTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;

    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              ProfileAvatar(
                size: 72,
                borderWidth: 3,
                iconSize: 36,
                avatarPath: avatarPath,
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: onAvatarEditTap,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: dark
                            ? theme.colorScheme.surface
                            : theme.colorScheme.surfaceContainerLowest,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.edit,
                      size: 14,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            name,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            email,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompletenessCard extends StatelessWidget {
  const _CompletenessCard({
    required this.completionPercent,
    required this.missingPriorityFields,
  });

  final int completionPercent;
  final List<String> missingPriorityFields;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: theme.colorScheme.surfaceContainerLow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '资料完整度',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '$completionPercent%',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: completionPercent / 100,
              minHeight: 8,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            missingPriorityFields.isEmpty
                ? '资料已完整，可保持当前信息'
                : '建议优先补全：${missingPriorityFields.join('、')}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Text(
        text,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _InfoActionRow extends StatelessWidget {
  const _InfoActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
          ),
          child: Icon(icon, color: theme.colorScheme.primary),
        ),
        title: Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _InfoSwitchRow extends StatelessWidget {
  const _InfoSwitchRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        onTap: () => onChanged(!value),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
          ),
          child: Icon(icon, color: theme.colorScheme.primary),
        ),
        title: Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Switch(value: value, onChanged: onChanged),
      ),
    );
  }
}

class _ProfileMinimalInputField extends StatelessWidget {
  const _ProfileMinimalInputField({
    required this.label,
    required this.icon,
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.maxLines = 1,
  });

  final String label;
  final IconData icon;
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurface,
        ),
        decoration: _buildProfileInputDecoration(
          theme,
          label: label,
          hintText: hintText,
          alignLabelWithHint: maxLines > 1,
          prefixIcon: Icon(
            icon,
            size: 20,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

InputDecoration _buildProfileInputDecoration(
  ThemeData theme, {
  required String label,
  required String hintText,
  required bool alignLabelWithHint,
  Widget? prefixIcon,
}) {
  return InputDecoration(
    hintText: hintText,
    labelText: label,
    floatingLabelBehavior: FloatingLabelBehavior.auto,
    alignLabelWithHint: alignLabelWithHint,
    prefixIcon: prefixIcon,
    prefixIconConstraints: const BoxConstraints(minWidth: 48),
    filled: true,
    fillColor: theme.colorScheme.surfaceContainerHighest,
    contentPadding: const EdgeInsets.fromLTRB(12, 20, 16, 10),
    border: UnderlineInputBorder(
      borderSide: BorderSide(color: theme.colorScheme.outline),
    ),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: theme.colorScheme.outline),
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
    ),
    labelStyle: theme.textTheme.bodyLarge?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    ),
    floatingLabelStyle: theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.primary,
    ),
    floatingLabelAlignment: FloatingLabelAlignment.start,
    isDense: true,
  );
}
