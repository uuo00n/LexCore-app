import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:lexcore/app/adaptive/app_adaptive_split_view.dart';
import 'package:lexcore/app/adaptive/app_breakpoints.dart';
import 'package:lexcore/app/router/route_names.dart';
import 'package:lexcore/app/theme/app_colors.dart';
import 'package:lexcore/shared/components/app_input_field.dart';
import 'package:lexcore/shared/components/app_primary_button.dart';
import 'package:lexcore/shared/components/app_surface_card.dart';
import 'package:lexcore/shared/widgets/app_page_scaffold.dart';

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
    return AppPageScaffold(
      title: 'LexiAI 文档生成器',
      body: LayoutBuilder(
        builder: (context, constraints) {
          final viewport = AppBreakpoints.fromWidth(constraints.maxWidth);
          final splitLayout =
              viewport == AppViewportSize.expanded ||
              viewport == AppViewportSize.ultra;

          if (!splitLayout) {
            return _GenerateForm(
              titleController: _titleController,
              claimController: _claimController,
              factController: _factController,
              documentType: _documentType,
              onTypeChanged: (value) =>
                  setState(() => _documentType = value ?? _documentType),
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
              onTypeChanged: (value) =>
                  setState(() => _documentType = value ?? _documentType),
            ),
            secondary: const _GenerateSidePanel(),
          );
        },
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
  });

  final TextEditingController titleController;
  final TextEditingController claimController;
  final TextEditingController factController;
  final String documentType;
  final ValueChanged<String?> onTypeChanged;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Text('创建新文档', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(
          '填写以下信息，让 AI 为您生成专业文档。',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        AppInputField(
          label: '文档标题',
          hint: '例如：2024年度劳动争议处理计划',
          controller: titleController,
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: documentType,
          decoration: const InputDecoration(labelText: '文档类型'),
          items: const [
            DropdownMenuItem(value: '劳动仲裁申请书', child: Text('劳动仲裁申请书')),
            DropdownMenuItem(value: '律师函', child: Text('律师函')),
            DropdownMenuItem(value: '合同审查意见', child: Text('合同审查意见')),
            DropdownMenuItem(value: '企业合规报告', child: Text('企业合规报告')),
          ],
          onChanged: onTypeChanged,
        ),
        const SizedBox(height: 12),
        AppInputField(
          label: '核心诉求',
          hint: '例如：支付拖欠工资与经济补偿',
          controller: claimController,
        ),
        const SizedBox(height: 12),
        AppInputField(
          label: '详细描述 / 大纲',
          hint: '输入关键事实、证据、时间线、争议焦点',
          maxLines: 6,
          controller: factController,
        ),
        const SizedBox(height: 18),
        AppPrimaryButton(
          label: '立即生成文档',
          icon: Icons.auto_awesome,
          onPressed: () => context.push(RouteNames.documentPreviewPath),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _GenerateSidePanel extends StatelessWidget {
  const _GenerateSidePanel();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Text('推荐模板', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 10),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 1,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.8,
          children: const [
            _TemplateCard(icon: Icons.description_outlined, title: '日报/周报'),
            _TemplateCard(icon: Icons.lightbulb_outline, title: '创意文案'),
          ],
        ),
        const SizedBox(height: 12),
        AppSurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('填写建议', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              _Hint(text: '按时间顺序描述事实，便于模型抽取证据链'),
              _Hint(text: '明确诉求优先级，便于生成结构化文书'),
              _Hint(text: '引用具体条款可提升输出精度'),
            ],
          ),
        ),
      ],
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 6, color: AppColors.primary),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      backgroundColor: AppColors.primary.withValues(alpha: 0.07),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primary),
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
