import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:lexcore/app/motion/app_motion_widgets.dart';
import 'package:lexcore/app/router/route_names.dart';
import 'package:lexcore/features/consultation/application/consultation_controller.dart';
import 'package:lexcore/shared/models/legal_models.dart';
import 'package:lexcore/shared/widgets/app_page_scaffold.dart';

class ConsultationListPage extends ConsumerStatefulWidget {
  const ConsultationListPage({super.key});

  @override
  ConsumerState<ConsultationListPage> createState() =>
      _ConsultationListPageState();
}

class _ConsultationListPageState extends ConsumerState<ConsultationListPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onQueryChanged);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onQueryChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sessions = ref.watch(consultationSessionsProvider);
    final filteredSessions = _filterSessions(
      sessions,
      _searchController.text.trim(),
    );

    return AppPageScaffold(
      title: '法律咨询',
      actions: [
        IconButton(
          key: const ValueKey('consultation_new_thread_button'),
          onPressed: _createConversation,
          icon: const Icon(Icons.add_comment_outlined),
          tooltip: '新建对话',
        ),
      ],
      body: Column(
        children: [
          AppFadeSlideIn(
            delay: const Duration(milliseconds: 60),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TextField(
                key: const ValueKey('consultation_list_search_field'),
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: '搜索咨询记录或法律话题...',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
            ),
          ),
          Expanded(
            child: filteredSessions.isEmpty
                ? _EmptyState(query: _searchController.text.trim())
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: filteredSessions.length,
                    itemBuilder: (context, index) {
                      final session = filteredSessions[index];
                      return AppFadeSlideIn(
                        delay: Duration(milliseconds: 90 + (index * 30)),
                        child: _SessionTile(
                          key: ValueKey(
                            'consultation_session_item_${session.id}',
                          ),
                          session: session,
                          showBottomDivider:
                              index != filteredSessions.length - 1,
                          onTap: () => _openSession(session),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _onQueryChanged() {
    if (!mounted) return;
    setState(() {});
  }

  List<ConsultationSession> _filterSessions(
    List<ConsultationSession> sessions,
    String query,
  ) {
    if (query.isEmpty) return sessions;
    final normalized = query.toLowerCase();
    return sessions.where((session) {
      return session.title.toLowerCase().contains(normalized) ||
          session.preview.toLowerCase().contains(normalized);
    }).toList();
  }

  void _createConversation() {
    final threadId = 'thread_new_${DateTime.now().millisecondsSinceEpoch}';
    ref
        .read(consultationStateControllerProvider.notifier)
        .createThread(threadId: threadId, title: '新建咨询会话');
    context.pushNamed(
      RouteNames.consultationChat,
      pathParameters: {RouteNames.consultationChatThreadIdParam: threadId},
      extra: '新建咨询会话',
    );
  }

  void _openSession(ConsultationSession session) {
    ref
        .read(consultationStateControllerProvider.notifier)
        .selectThread(session.id);
    context.pushNamed(
      RouteNames.consultationChat,
      pathParameters: {RouteNames.consultationChatThreadIdParam: session.id},
      extra: session.title,
    );
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({
    super.key,
    required this.session,
    required this.showBottomDivider,
    required this.onTap,
  });

  final ConsultationSession session;
  final bool showBottomDivider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final titleColor = session.isActive ? colorScheme.primary : null;

    return Material(
      color: colorScheme.surface.withValues(alpha: 0),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border(
              bottom: BorderSide(
                color: showBottomDivider
                    ? colorScheme.outline.withValues(alpha: 0.14)
                    : colorScheme.surface.withValues(alpha: 0),
              ),
            ),
          ),
          child: Row(
            children: [
              _SessionAvatar(session: session),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: titleColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      session.preview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatUpdatedAt(session.updatedAt),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: session.isActive
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatUpdatedAt(DateTime updatedAt) {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final startOfDay = DateTime(updatedAt.year, updatedAt.month, updatedAt.day);
    final dayDiff = startOfToday.difference(startOfDay).inDays;

    if (dayDiff == 0) return DateFormat('HH:mm').format(updatedAt);
    if (dayDiff == 1) return '昨天';
    if (dayDiff < 7) {
      return switch (updatedAt.weekday) {
        DateTime.monday => '周一',
        DateTime.tuesday => '周二',
        DateTime.wednesday => '周三',
        DateTime.thursday => '周四',
        DateTime.friday => '周五',
        DateTime.saturday => '周六',
        DateTime.sunday => '周日',
        _ => DateFormat('M月d日').format(updatedAt),
      };
    }
    return DateFormat('M月d日').format(updatedAt);
  }
}

class _SessionAvatar extends StatelessWidget {
  const _SessionAvatar({required this.session});

  final ConsultationSession session;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final highlighted = session.isActive;
    final backgroundColor = highlighted
        ? colorScheme.primary
        : colorScheme.surfaceContainerHighest;
    final foregroundColor = highlighted
        ? colorScheme.onPrimary
        : colorScheme.onSurfaceVariant;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
          ),
          child: Icon(_iconFor(session.icon), color: foregroundColor),
        ),
        if (highlighted)
          Positioned(
            right: -1,
            bottom: -1,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.tertiary,
                border: Border.all(color: colorScheme.surface, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  IconData _iconFor(String icon) {
    return switch (icon) {
      'home_work' => Icons.home_work_outlined,
      'work' => Icons.work_outline_rounded,
      'gavel' => Icons.gavel_rounded,
      'family_restroom' => Icons.family_restroom_rounded,
      _ => Icons.smart_toy_outlined,
    };
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history_toggle_off_rounded,
              size: 40,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              query.isEmpty ? '暂无咨询记录' : '没有匹配的咨询记录',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 6),
            Text(
              query.isEmpty ? '点击右上角可新建对话。' : '请尝试其他关键词。',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
