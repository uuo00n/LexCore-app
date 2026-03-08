import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
      body: ListView(
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
            controller: _titleController,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _documentType,
            decoration: const InputDecoration(labelText: '文档类型'),
            items: const [
              DropdownMenuItem(value: '劳动仲裁申请书', child: Text('劳动仲裁申请书')),
              DropdownMenuItem(value: '律师函', child: Text('律师函')),
              DropdownMenuItem(value: '合同审查意见', child: Text('合同审查意见')),
              DropdownMenuItem(value: '企业合规报告', child: Text('企业合规报告')),
            ],
            onChanged: (value) =>
                setState(() => _documentType = value ?? _documentType),
          ),
          const SizedBox(height: 12),
          AppInputField(
            label: '核心诉求',
            hint: '例如：支付拖欠工资与经济补偿',
            controller: _claimController,
          ),
          const SizedBox(height: 12),
          AppInputField(
            label: '详细描述 / 大纲',
            hint: '输入关键事实、证据、时间线、争议焦点',
            maxLines: 6,
            controller: _factController,
          ),
          const SizedBox(height: 18),
          AppPrimaryButton(
            label: '立即生成文档',
            icon: Icons.auto_awesome,
            onPressed: () => context.push(RouteNames.documentPreviewPath),
          ),
          const SizedBox(height: 24),
          Text('推荐模板', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 10),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.4,
            children: const [
              _TemplateCard(icon: Icons.description_outlined, title: '日报/周报'),
              _TemplateCard(icon: Icons.lightbulb_outline, title: '创意文案'),
            ],
          ),
          const SizedBox(height: 8),
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
