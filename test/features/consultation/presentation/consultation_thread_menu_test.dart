import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:lexcore/app/router/route_names.dart';
import 'package:lexcore/features/consultation/presentation/pages/consultation_list_page.dart';
import 'package:lexcore/features/consultation/presentation/pages/consultation_page.dart';

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

  Future<void> openThreadMenu(WidgetTester tester) async {
    await tester.tap(find.byKey(const ValueKey('consultation_more_button')));
    await tester.pumpAndSettle();
  }

  testWidgets('rename thread updates detail header and list title', (
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

    await openThreadMenu(tester);
    await tester.tap(find.text('重命名对话'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('consultation_rename_input')),
      '劳动合同争议咨询',
    );
    await tester.tap(find.byKey(const ValueKey('consultation_rename_confirm')));
    await tester.pumpAndSettle();

    expect(find.text('劳动合同争议咨询'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    expect(find.text('劳动合同争议咨询'), findsOneWidget);
    expect(find.text('LexCore 法律助手'), findsNothing);
  });

  testWidgets('clear thread keeps only welcome message', (tester) async {
    await setPhoneViewport(tester);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(routerConfig: buildConsultationRouter()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('LexCore 法律助手'));
    await tester.pumpAndSettle();

    await openThreadMenu(tester);
    await tester.tap(find.text('清空当前对话'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('consultation_clear_confirm')));
    await tester.pumpAndSettle();

    expect(find.text('公司拖欠工资两个月，我该如何维权？'), findsNothing);
    expect(
      find.text('您好，我是 LexCore 法律助手。请告诉我您的法律问题，我会给出分步骤建议。'),
      findsOneWidget,
    );
  });

  testWidgets('delete thread returns to list and removes the item', (
    tester,
  ) async {
    await setPhoneViewport(tester);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(routerConfig: buildConsultationRouter()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('房产买卖纠纷咨询'));
    await tester.pumpAndSettle();

    await openThreadMenu(tester);
    await tester.tap(find.text('删除对话'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('consultation_delete_confirm')));
    await tester.pumpAndSettle();

    expect(find.text('房产买卖纠纷咨询'), findsNothing);
    expect(find.text('搜索咨询记录或法律话题...'), findsOneWidget);
  });

  testWidgets('share failure shows snackbar', (tester) async {
    await setPhoneViewport(tester);
    const channel = MethodChannel('dev.fluttercommunity.plus/share');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          throw PlatformException(code: 'share_error');
        });
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(routerConfig: buildConsultationRouter()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('LexCore 法律助手'));
    await tester.pumpAndSettle();

    await openThreadMenu(tester);
    await tester.tap(find.text('分享对话'));
    await tester.pumpAndSettle();

    expect(find.text('分享失败，请稍后重试'), findsOneWidget);
  });
}
