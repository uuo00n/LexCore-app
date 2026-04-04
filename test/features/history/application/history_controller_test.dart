import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lexcore/features/history/application/history_controller.dart';
import 'package:lexcore/shared/models/legal_models.dart';

void main() {
  test(
    'historySearchItemsProvider supports keyword, category and time range filtering',
    () async {
      final now = DateTime.now();
      final items = [
        HistoryItem(
          id: 'h1',
          title: '工资拖欠咨询会话',
          category: HistoryCategory.consultation,
          time: now.subtract(const Duration(hours: 4)),
        ),
        HistoryItem(
          id: 'h2',
          title: '劳动仲裁风险分析',
          category: HistoryCategory.analysis,
          time: now.subtract(const Duration(days: 1)),
        ),
        HistoryItem(
          id: 'h3',
          title: '劳动仲裁申请书草稿',
          category: HistoryCategory.document,
          time: now.subtract(const Duration(days: 2)),
        ),
      ];
      final container = ProviderContainer(
        overrides: [historyAllItemsProvider.overrideWith((ref) async => items)],
      );
      addTearDown(container.dispose);

      await container.read(historyAllItemsProvider.future);

      var results = container.read(historySearchItemsProvider).requireValue;
      expect(results.map((item) => item.title).toList(), [
        '工资拖欠咨询会话',
        '劳动仲裁风险分析',
        '劳动仲裁申请书草稿',
      ]);

      container.read(historySearchKeywordProvider.notifier).state = '仲裁';
      results = container.read(historySearchItemsProvider).requireValue;
      expect(results.map((item) => item.title).toList(), [
        '劳动仲裁风险分析',
        '劳动仲裁申请书草稿',
      ]);

      container.read(historyFilterProvider.notifier).state =
          HistoryCategory.analysis;
      results = container.read(historySearchItemsProvider).requireValue;
      expect(results.map((item) => item.title).toList(), ['劳动仲裁风险分析']);

      container.read(historySearchStartTimeProvider.notifier).state = now
          .subtract(const Duration(days: 1, hours: 6));
      container.read(historySearchEndTimeProvider.notifier).state = now
          .subtract(const Duration(hours: 18));
      results = container.read(historySearchItemsProvider).requireValue;
      expect(results.map((item) => item.title).toList(), ['劳动仲裁风险分析']);

      container.read(historySearchStartTimeProvider.notifier).state = now
          .subtract(const Duration(hours: 1));
      container.read(historySearchEndTimeProvider.notifier).state = now
          .subtract(const Duration(days: 2));
      results = container.read(historySearchItemsProvider).requireValue;
      expect(results, isEmpty);
    },
  );

  test('historySearchItemsProvider restores full list after reset', () async {
    final now = DateTime.now();
    final container = ProviderContainer(
      overrides: [
        historyAllItemsProvider.overrideWith((ref) async {
          return [
            HistoryItem(
              id: 'h1',
              title: '工资拖欠咨询会话',
              category: HistoryCategory.consultation,
              time: now.subtract(const Duration(hours: 4)),
            ),
            HistoryItem(
              id: 'h2',
              title: '劳动仲裁风险分析',
              category: HistoryCategory.analysis,
              time: now.subtract(const Duration(days: 1)),
            ),
            HistoryItem(
              id: 'h3',
              title: '劳动仲裁申请书草稿',
              category: HistoryCategory.document,
              time: now.subtract(const Duration(days: 2)),
            ),
          ];
        }),
      ],
    );
    addTearDown(container.dispose);
    await container.read(historyAllItemsProvider.future);

    container.read(historySearchKeywordProvider.notifier).state = '工资';
    container.read(historyFilterProvider.notifier).state =
        HistoryCategory.consultation;
    container.read(historySearchStartTimeProvider.notifier).state =
        DateTime.now().subtract(const Duration(days: 1));
    container.read(historySearchEndTimeProvider.notifier).state =
        DateTime.now();

    container.read(historySearchKeywordProvider.notifier).state = '';
    container.read(historyFilterProvider.notifier).state = null;
    container.read(historySearchStartTimeProvider.notifier).state = null;
    container.read(historySearchEndTimeProvider.notifier).state = null;

    final results = container.read(historySearchItemsProvider).requireValue;
    expect(results.length, 3);
  });
}
