import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:lexcore/app/router/route_names.dart';
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

  testWidgets('consultation list supports local search filtering', (
    tester,
  ) async {
    await setPhoneViewport(tester);
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: ConsultationListPage())),
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
      ProviderScope(
        child: MaterialApp.router(routerConfig: buildConsultationRouter()),
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
      ProviderScope(
        child: MaterialApp.router(routerConfig: buildConsultationRouter()),
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
    expect(
      find.text('您好，我是 LexCore 法律助手。请告诉我您的法律问题，我会给出分步骤建议。'),
      findsOneWidget,
    );
  });
}
