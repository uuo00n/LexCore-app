import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lexcore/app/router/route_names.dart';
import 'package:lexcore/core/storage/local_storage.dart';
import 'package:lexcore/features/consultation/presentation/pages/consultation_list_page.dart';
import 'package:lexcore/features/consultation/presentation/pages/consultation_page.dart';
import 'package:lexcore/shared/widgets/app_page_scaffold.dart';
import 'package:lexcore/shared/widgets/app_shell_top_bar.dart';

void main() {
  Future<void> setPhoneViewport(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });
  }

  GoRouter buildConsultationRouter() {
    return GoRouter(
      initialLocation: RouteNames.consultationPath,
      routes: [
        GoRoute(
          path: RouteNames.consultationPath,
          name: RouteNames.consultation,
          builder: (context, state) => const ConsultationListPage(),
        ),
        GoRoute(
          path: RouteNames.consultationChatPath,
          name: RouteNames.consultationChat,
          builder: (context, state) => ConsultationPage(
            threadId:
                state.pathParameters[RouteNames
                    .consultationChatThreadIdParam] ??
                'thread_new',
            threadTitle: state.extra is String ? state.extra! as String : null,
          ),
        ),
      ],
    );
  }

  Future<ProviderScope> buildProviderScope(Widget child) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('consultation_state_local_v1', '''
{
  "schemaVersion": 1,
  "sessions": [
    {
      "id": "thread_legal_assistant",
      "title": "LexCore 法律助手",
      "preview": "您好，我是 LexCore 法律助手。请告诉我您的法律问题，我会给出分步骤建议。",
      "updatedAt": "2026-05-04T09:00:00.000",
      "icon": "smart_toy",
      "isActive": true
    },
    {
      "id": "thread_real_estate",
      "title": "房产买卖纠纷咨询",
      "preview": "房屋买卖合同履行争议",
      "updatedAt": "2026-05-04T08:00:00.000",
      "icon": "home",
      "isActive": false
    },
    {
      "id": "thread_startup_equity",
      "title": "初创企业股权架构",
      "preview": "创始团队股权分配",
      "updatedAt": "2026-05-04T07:00:00.000",
      "icon": "business",
      "isActive": false
    }
  ],
  "threads": {
    "thread_legal_assistant": {
      "id": "thread_legal_assistant",
      "title": "LexCore 法律助手",
      "messages": [
        {
          "id": "a_welcome",
          "role": "assistant",
          "content": "您好，我是 LexCore 法律助手。请告诉我您的法律问题，我会给出分步骤建议。",
          "references": []
        }
      ]
    }
  },
  "remoteConversationIds": {}
}
''');
    return ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
      child: child,
    );
  }

  testWidgets('consultation list supports local search filtering', (
    tester,
  ) async {
    await setPhoneViewport(tester);
    await tester.pumpWidget(
      await buildProviderScope(
        const MaterialApp(home: ConsultationListPage()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 800));

    expect(
      tester.widget<AppPageScaffold>(find.byType(AppPageScaffold)).bodyPadding,
      isNull,
    );
    expect(find.text('房产买卖纠纷咨询'), findsOneWidget);
    expect(find.text('初创企业股权架构'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('consultation_list_search_field')),
      '房产',
    );
    await tester.pump();

    expect(find.text('房产买卖纠纷咨询'), findsOneWidget);
    expect(find.text('初创企业股权架构'), findsNothing);
    expect(find.text('首页'), findsNothing);
  });

  testWidgets('tapping a session opens consultation detail page', (
    tester,
  ) async {
    await setPhoneViewport(tester);
    await tester.pumpWidget(
      await buildProviderScope(
        MaterialApp.router(routerConfig: buildConsultationRouter()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('LexCore 法律助手'));
    await tester.pumpAndSettle();

    expect(find.byType(AppShellTopBar), findsOneWidget);
    expect(
      tester.widget<AppPageScaffold>(find.byType(AppPageScaffold)).bodyPadding,
      const EdgeInsets.fromLTRB(12, 10, 12, 12),
    );
    expect(find.text('LexCore 法律助手'), findsOneWidget);
    expect(find.text('请输入您的问题...'), findsOneWidget);
  });

  testWidgets('tapping new conversation opens a new detail thread', (
    tester,
  ) async {
    await setPhoneViewport(tester);
    await tester.pumpWidget(
      await buildProviderScope(
        MaterialApp.router(routerConfig: buildConsultationRouter()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey('consultation_new_thread_button')),
    );
    await tester.pumpAndSettle();

    expect(
      tester.widget<AppPageScaffold>(find.byType(AppPageScaffold)).bodyPadding,
      const EdgeInsets.fromLTRB(12, 10, 12, 12),
    );
    expect(find.text('新建咨询会话'), findsOneWidget);
    expect(find.text('请输入您的问题...'), findsOneWidget);
  });
}
