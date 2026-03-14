import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lexcore/features/document/presentation/pages/saved_documents_page.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpSavedDocumentsPage(
    WidgetTester tester, {
    required Size size,
    double textScale = 1.0,
  }) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              final mediaQuery = MediaQuery.of(context);
              return MediaQuery(
                data: mediaQuery.copyWith(
                  textScaler: TextScaler.linear(textScale),
                ),
                child: const SavedDocumentsPage(),
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders without overflow on compact viewport', (tester) async {
    await pumpSavedDocumentsPage(tester, size: const Size(320, 640));

    expect(tester.takeException(), isNull);
    expect(find.text('已保存的文档'), findsOneWidget);
    expect(find.text('劳动仲裁申请书-2026-03-06'), findsOneWidget);
    expect(find.text('查看'), findsWidgets);
    expect(find.text('编辑'), findsWidgets);
  });

  testWidgets('renders without overflow on compact viewport with larger text', (
    tester,
  ) async {
    await pumpSavedDocumentsPage(
      tester,
      size: const Size(320, 640),
      textScale: 1.3,
    );

    expect(tester.takeException(), isNull);
    expect(find.text('已保存的文档'), findsOneWidget);
    expect(find.text('劳动仲裁申请书-2026-03-06'), findsOneWidget);
  });

  testWidgets('renders persisted saved document from local storage', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'saved_documents_v1': '''
[
  {
    "id": "doc_1",
    "name": "本地保存的合同审查报告",
    "updatedAt": "2026-03-14T08:00:00.000",
    "type": "审查意见"
  }
]
''',
    });

    await pumpSavedDocumentsPage(tester, size: const Size(390, 844));

    expect(find.text('本地保存的合同审查报告'), findsOneWidget);
    expect(find.textContaining('审查意见 · 更新于'), findsOneWidget);
  });
}
