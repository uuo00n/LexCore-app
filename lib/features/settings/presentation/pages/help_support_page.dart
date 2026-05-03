import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:lexcore/shared/components/app_surface_card.dart';
import 'package:lexcore/shared/widgets/app_page_scaffold.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  static const supportEmail = 'support@lexcore.cn';

  Future<void> _contactSupport(BuildContext context) async {
    final uri = Uri(
      scheme: 'mailto',
      path: supportEmail,
      queryParameters: const {'subject': 'LexCore 帮助与支持'},
    );
    final launched = await launchUrl(uri);
    if (launched || !context.mounted) {
      return;
    }

    await Clipboard.setData(const ClipboardData(text: supportEmail));
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('已复制支持邮箱')));
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      title: '帮助与支持',
      body: ListView(
        children: [
          AppSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('常见问题', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 10),
                const _FaqItem(
                  question: '文书生成后可以修改吗？',
                  answer: '可以。在文档详情页进入编辑模式后，可直接修改标题和 Markdown 正文并保存。',
                ),
                const _FaqItem(
                  question: 'PDF 导出失败怎么办？',
                  answer: '系统会优先使用云端导出，失败时自动切换为本地 PDF 导出。',
                ),
                const _FaqItem(
                  question: '缓存清理会删除登录状态吗？',
                  answer: '不会。缓存管理只清理临时导出文件和系统缓存，不删除账号、主题、历史记录等数据。',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('联系支持', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Text(
                  '邮箱：$supportEmail\n工作日支持时间：09:30 - 18:30',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(height: 1.6),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => _contactSupport(context),
                  icon: const Icon(Icons.mail_outline),
                  label: const Text('联系支持'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqItem extends StatelessWidget {
  const _FaqItem({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            answer,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
