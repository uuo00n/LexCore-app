import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:lexcore/app/adaptive/app_adaptive_frame.dart';
import 'package:lexcore/app/adaptive/app_adaptive_split_view.dart';
import 'package:lexcore/app/adaptive/app_breakpoints.dart';
import 'package:lexcore/app/router/route_names.dart';

class DocumentGeneratePage extends StatefulWidget {
  const DocumentGeneratePage({super.key});

  @override
  State<DocumentGeneratePage> createState() => _DocumentGeneratePageState();
}

class _DocumentGeneratePageState extends State<DocumentGeneratePage> {
  String _documentType = '劳动仲裁申请书';

  final _titleController = TextEditingController();
  final _claimController = TextEditingController();
  final _factController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _claimController.dispose();
    _factController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _GenerateTopBar(
              onBackTap: () {
                if (Navigator.of(context).canPop()) {
                  context.pop();
                }
              },
            ),
            Expanded(
              child: AppAdaptiveFrame(
                maxContentWidth: 1120,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final viewport = AppBreakpoints.fromWidth(
                      constraints.maxWidth,
                    );
                    final splitLayout =
                        viewport == AppViewportSize.expanded ||
                        viewport == AppViewportSize.ultra;

                    if (!splitLayout) {
                      return _GenerateForm(
                        titleController: _titleController,
                        claimController: _claimController,
                        factController: _factController,
                        documentType: _documentType,
                        onTypeChanged: (value) => setState(
                          () => _documentType = value ?? _documentType,
                        ),
                        showTemplateSection: true,
                      );
                    }

                    return AppAdaptiveSplitView(
                      splitMinWidth: 980,
                      secondaryMaxWidth: 360,
                      primary: _GenerateForm(
                        titleController: _titleController,
                        claimController: _claimController,
                        factController: _factController,
                        documentType: _documentType,
                        onTypeChanged: (value) => setState(
                          () => _documentType = value ?? _documentType,
                        ),
                        showTemplateSection: false,
                      ),
                      secondary: const _GenerateSidePanel(),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GenerateTopBar extends StatelessWidget {
  const _GenerateTopBar({required this.onBackTap});

  final VoidCallback onBackTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBackTap,
            icon: const Icon(Icons.arrow_back),
            tooltip: '返回',
          ),
          Expanded(
            child: Text(
              'LexiAI 文档生成器',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _GenerateForm extends StatelessWidget {
  const _GenerateForm({
    required this.titleController,
    required this.claimController,
    required this.factController,
    required this.documentType,
    required this.onTypeChanged,
    required this.showTemplateSection,
  });

  final TextEditingController titleController;
  final TextEditingController claimController;
  final TextEditingController factController;
  final String documentType;
  final ValueChanged<String?> onTypeChanged;
  final bool showTemplateSection;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 18, 0, 28),
      children: [
        Text(
          '创建新文档',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '填写以下信息，让 AI 为您生成专业文档。',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 22),
        _Md3TextField(
          label: '文档标题',
          helperText: '例如：劳动仲裁申请书（拖欠工资纠纷）',
          controller: titleController,
        ),
        const SizedBox(height: 14),
        _Md3DropdownField(
          label: '文档类型',
          value: documentType,
          items: const [
            DropdownMenuItem(value: '劳动仲裁申请书', child: Text('劳动仲裁申请书')),
            DropdownMenuItem(value: '律师函', child: Text('律师函')),
            DropdownMenuItem(value: '合同审查意见', child: Text('合同审查意见')),
            DropdownMenuItem(value: '企业合规报告', child: Text('企业合规报告')),
          ],
          onChanged: onTypeChanged,
        ),
        const SizedBox(height: 14),
        _Md3TextField(
          label: '核心诉求',
          helperText: '例如：支付拖欠工资并承担经济补偿',
          controller: claimController,
        ),
        const SizedBox(height: 14),
        _Md3TextField(
          label: '详细描述 / 大纲',
          controller: factController,
          minLines: 4,
          maxLines: 4,
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => context.push(RouteNames.documentPreviewPath),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
              shape: const StadiumBorder(),
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
            icon: const Icon(Icons.auto_awesome),
            label: const Text(
              '立即生成文档',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
        if (showTemplateSection) ...[
          const SizedBox(height: 28),
          const _TemplateSection(),
          const SizedBox(height: 16),
          const _GenerateHintsCard(),
        ],
      ],
    );
  }
}

class _GenerateSidePanel extends StatelessWidget {
  const _GenerateSidePanel();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 18, 0, 28),
      children: const [
        _TemplateSection(),
        SizedBox(height: 16),
        _GenerateHintsCard(),
      ],
    );
  }
}

class _TemplateSection extends StatelessWidget {
  const _TemplateSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '推荐模板',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        Row(
          children: const [
            Expanded(
              child: _TemplateCard(
                icon: Icons.description_outlined,
                title: '日报/周报',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _TemplateCard(
                icon: Icons.lightbulb_outline,
                title: '创意文案',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 94,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: colorScheme.primary),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _GenerateHintsCard extends StatelessWidget {
  const _GenerateHintsCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '填写建议',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 10),
          const _Hint(text: '按时间顺序描述事实，便于模型抽取证据链'),
          const _Hint(text: '明确诉求优先级，便于生成结构化文书'),
          const _Hint(text: '引用具体条款可提升输出精度'),
        ],
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Icon(
              Icons.circle,
              size: 6,
              color: colorScheme.primary.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Md3TextField extends StatelessWidget {
  const _Md3TextField({
    required this.label,
    required this.controller,
    this.helperText,
    this.minLines,
    this.maxLines = 1,
  });

  final String label;
  final String? helperText;
  final TextEditingController controller;
  final int? minLines;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      decoration: _md3Decoration(context, label: label, helperText: helperText),
    );
  }
}

class _Md3DropdownField extends StatelessWidget {
  const _Md3DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      items: items,
      onChanged: onChanged,
      decoration: _md3Decoration(context, label: label),
    );
  }
}

InputDecoration _md3Decoration(
  BuildContext context, {
  required String label,
  String? helperText,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  final fillColor = colorScheme.surfaceContainerHigh;
  final borderColor = colorScheme.outlineVariant;

  final baseBorder = UnderlineInputBorder(
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(12),
      topRight: Radius.circular(12),
    ),
    borderSide: BorderSide(color: borderColor, width: 1.8),
  );

  return InputDecoration(
    labelText: label,
    helperText: helperText,
    helperStyle: TextStyle(color: colorScheme.onSurfaceVariant),
    filled: true,
    fillColor: fillColor,
    contentPadding: const EdgeInsets.fromLTRB(14, 22, 14, 10),
    border: baseBorder,
    enabledBorder: baseBorder,
    focusedBorder: baseBorder.copyWith(
      borderSide: BorderSide(color: colorScheme.primary, width: 2),
    ),
  );
}
