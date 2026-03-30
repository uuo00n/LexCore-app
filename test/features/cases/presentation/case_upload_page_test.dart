import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:lexcore/app/router/route_names.dart';
import 'package:lexcore/features/cases/presentation/pages/case_upload_page.dart';
import 'package:lexcore/shared/widgets/app_page_scaffold.dart';

void main() {
  Future<void> setPhoneViewport(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });
  }

  GoRouter buildRouter({CaseUploadFilePicker? filePicker}) {
    return GoRouter(
      initialLocation: RouteNames.caseUploadPath,
      routes: [
        GoRoute(
          path: RouteNames.caseUploadPath,
          builder: (context, state) => CaseUploadPage(filePicker: filePicker),
        ),
        GoRoute(
          path: RouteNames.analysisDetailPath,
          builder: (context, state) => const _LabelPage(title: '分析详情占位'),
        ),
      ],
    );
  }

  Future<void> pumpCaseUploadPage(
    WidgetTester tester, {
    CaseUploadFilePicker? filePicker,
  }) async {
    await setPhoneViewport(tester);
    await tester.pumpWidget(
      MaterialApp.router(routerConfig: buildRouter(filePicker: filePicker)),
    );
    await tester.pumpAndSettle();
  }

  Future<void> selectCause(WidgetTester tester, String cause) async {
    await tester.tap(find.byIcon(Icons.keyboard_arrow_down_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text(cause).last);
    await tester.pumpAndSettle();
  }

  testWidgets('renders upload form sections and actions', (tester) async {
    await pumpCaseUploadPage(tester);

    expect(find.text('上传案件'), findsOneWidget);
    expect(
      tester.widget<AppPageScaffold>(find.byType(AppPageScaffold)).bodyPadding,
      isNull,
    );
    expect(find.text('基本信息'), findsOneWidget);
    expect(find.text('案件文档'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('case_upload_title_field')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('case_upload_cause_field')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('case_upload_description_field')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('case_upload_pick_files_button')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('case_upload_submit_button')),
      findsOneWidget,
    );
  });

  testWidgets('shows validation feedback when required fields are empty', (
    tester,
  ) async {
    await pumpCaseUploadPage(tester);

    await tester.tap(
      find.byKey(const ValueKey<String>('case_upload_submit_button')),
    );
    await tester.pumpAndSettle();

    expect(find.text('请输入案件名称'), findsOneWidget);
    expect(find.text('请选择案由'), findsOneWidget);
    expect(find.text('请输入案件描述'), findsOneWidget);
  });

  testWidgets('adds selected files to the attachment list', (tester) async {
    var pickCount = 0;

    await setPhoneViewport(tester);

    await tester.pumpWidget(
      MaterialApp(
        home: CaseUploadPage(
          filePicker: () async {
            pickCount += 1;
            return const [
              CaseUploadAttachment(
                name: '起诉状.pdf',
                extension: 'pdf',
                sizeBytes: 1024 * 1024,
              ),
            ];
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    final uploadButton = tester.widget<FilledButton>(
      find.byKey(const ValueKey<String>('case_upload_pick_files_button')),
    );
    uploadButton.onPressed?.call();
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    expect(pickCount, 1);
    await tester.scrollUntilVisible(
      find.text('起诉状.pdf'),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('起诉状.pdf'), findsOneWidget);
    expect(find.text('PDF · 1.0 MB'), findsOneWidget);
  });

  testWidgets('submits valid form and opens analysis detail page', (
    tester,
  ) async {
    await pumpCaseUploadPage(tester);

    await tester.enterText(
      find.byKey(const ValueKey<String>('case_upload_title_field')),
      '张三与李四房屋纠纷',
    );
    await selectCause(tester, '民事纠纷');
    await tester.enterText(
      find.byKey(const ValueKey<String>('case_upload_description_field')),
      '房屋买卖合同签订后，被告未按约办理过户。',
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('case_upload_submit_button')),
    );
    await tester.pumpAndSettle();

    expect(find.text('分析详情占位'), findsOneWidget);
  });
}

class _LabelPage extends StatelessWidget {
  const _LabelPage({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text(title)));
  }
}
