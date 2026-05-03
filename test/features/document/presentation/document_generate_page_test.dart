import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

import 'package:lexcore/core/network/api_client.dart';
import 'package:lexcore/features/document/data/repositories/document_repository.dart';
import 'package:lexcore/features/document/presentation/pages/document_generate_page.dart';
import 'package:lexcore/shared/models/legal_models.dart';
import 'package:lexcore/shared/widgets/app_page_scaffold.dart';
import 'package:lexcore/shared/widgets/app_searchable_dropdown_field.dart';
import 'package:lexcore/shared/widgets/app_shell_top_bar.dart';

class _NoopApiClient extends ApiClient {
  _NoopApiClient() : super(Dio());
}

class _GenerateFlowRepository extends DocumentRepository {
  _GenerateFlowRepository({required SharedPreferences preferences})
    : super(_NoopApiClient(), preferences);

  bool saveCalled = false;
  DocumentDraft? lastDraft;

  @override
  Future<DocumentSaveOutcome> saveDraft(DocumentDraft draft) async {
    saveCalled = true;
    lastDraft = draft;
    return const DocumentSaveOutcome(
      result: DocumentSaveResult.created,
      documentId: 'doc_generated_1',
      status: 'queued',
    );
  }

  @override
  Future<List<DocumentItem>> loadSaved() async {
    return [
      DocumentItem(
        id: 'doc_generated_1',
        name: '劳动仲裁申请书（拖欠工资纠纷）',
        updatedAt: DateTime.parse('2026-04-01T08:00:00.000Z'),
        type: '劳动仲裁',
        markdown: '',
        status: 'queued',
      ),
    ];
  }

  @override
  Future<DocumentItem?> loadById(String id) async {
    if (id != 'doc_generated_1') {
      return null;
    }
    return DocumentItem(
      id: 'doc_generated_1',
      name: '劳动仲裁申请书（拖欠工资纠纷）',
      updatedAt: DateTime.parse('2026-04-01T08:00:00.000Z'),
      type: '劳动仲裁',
      markdown: '',
      status: 'queued',
    );
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpDocumentGeneratePage(
    WidgetTester tester, {
    required Size size,
    _GenerateFlowRepository? repository,
  }) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    final preferences = await SharedPreferences.getInstance();
    final repo =
        repository ?? _GenerateFlowRepository(preferences: preferences);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [documentRepositoryProvider.overrideWithValue(repo)],
        child: const MaterialApp(home: DocumentGeneratePage()),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder findFormListViewWithPadding(EdgeInsets padding) {
    return find.byWidgetPredicate(
      (widget) => widget is ListView && widget.padding == padding,
      description: 'ListView with unified horizontal spacing',
    );
  }

  Finder findDocumentTypeDropdown() {
    return find.byWidgetPredicate(
      (widget) =>
          widget is AppSearchableDropdownField && widget.label == '文档类型',
      description: 'document type dropdown',
    );
  }

  Future<void> openDocumentTypeDropdown(WidgetTester tester) async {
    final toggle = find.descendant(
      of: findDocumentTypeDropdown(),
      matching: find.byIcon(Icons.keyboard_arrow_down_rounded),
    );
    await tester.tap(toggle.first);
    await tester.pumpAndSettle();
  }

  testWidgets('uses unified spacing in compact layout', (tester) async {
    await pumpDocumentGeneratePage(tester, size: const Size(390, 844));

    expect(find.byType(AppShellTopBar), findsOneWidget);
    expect(
      tester.widget<AppPageScaffold>(find.byType(AppPageScaffold)).bodyPadding,
      isNull,
    );
    expect(find.text('LexCore 文书生成'), findsOneWidget);
    expect(
      findFormListViewWithPadding(const EdgeInsets.fromLTRB(0, 10, 0, 28)),
      findsOneWidget,
    );
    expect(find.text('创建新文档'), findsOneWidget);
    expect(find.text('劳动仲裁申请书（拖欠工资纠纷）'), findsOneWidget);
    expect(find.text('李某'), findsOneWidget);
    expect(find.text('上海某某科技有限公司'), findsOneWidget);
  });

  testWidgets('uses unified spacing in split layout for both panels', (
    tester,
  ) async {
    await pumpDocumentGeneratePage(tester, size: const Size(1280, 900));

    expect(
      findFormListViewWithPadding(const EdgeInsets.fromLTRB(0, 10, 12, 28)),
      findsOneWidget,
    );
    expect(
      findFormListViewWithPadding(const EdgeInsets.fromLTRB(12, 10, 0, 28)),
      findsOneWidget,
    );
    expect(find.text('创建新文档'), findsOneWidget);
    expect(find.text('推荐模板'), findsOneWidget);
  });

  testWidgets('configures document type dropdown with filter and menu style', (
    tester,
  ) async {
    await pumpDocumentGeneratePage(tester, size: const Size(390, 844));

    final dropdown = tester.widget<AppSearchableDropdownField>(
      findDocumentTypeDropdown(),
    );
    expect(dropdown.value, '劳动仲裁');
    expect(dropdown.menuHeight, 280);
    expect(dropdown.options.length, 2);
  });

  testWidgets('shows all document type options and updates after selection', (
    tester,
  ) async {
    await pumpDocumentGeneratePage(tester, size: const Size(390, 844));
    await openDocumentTypeDropdown(tester);

    expect(find.text('劳动仲裁'), findsAtLeastNWidgets(2));
    expect(find.text('律师函'), findsOneWidget);

    await tester.tap(find.text('律师函').last);
    await tester.pumpAndSettle();

    expect(find.text('律师函'), findsOneWidget);
  });

  testWidgets('filters document type options and can select filtered result', (
    tester,
  ) async {
    await pumpDocumentGeneratePage(tester, size: const Size(390, 844));
    await openDocumentTypeDropdown(tester);

    final textFieldInDropdown = find.descendant(
      of: findDocumentTypeDropdown(),
      matching: find.byType(TextField),
    );

    await tester.enterText(textFieldInDropdown, '律师');
    await tester.pumpAndSettle();

    expect(find.text('律师函'), findsOneWidget);
    expect(find.text('劳动仲裁'), findsNothing);

    await tester.tap(find.text('律师函').last);
    await tester.pumpAndSettle();

    expect(find.text('律师函'), findsOneWidget);
  });

  testWidgets('switches dedicated section fields by doc type', (tester) async {
    await pumpDocumentGeneratePage(tester, size: const Size(390, 844));

    expect(find.text('劳动仲裁专属信息'), findsOneWidget);
    expect(find.text('申请人姓名'), findsOneWidget);
    expect(find.text('律师函专属信息'), findsNothing);

    await openDocumentTypeDropdown(tester);
    await tester.tap(find.text('律师函').last);
    await tester.pumpAndSettle();

    expect(find.text('律师函专属信息'), findsOneWidget);
    expect(find.text('受函方名称'), findsOneWidget);
    expect(find.text('某某企业管理有限公司'), findsOneWidget);
    expect(find.text('请于收到本函之日起7日内履行完毕'), findsOneWidget);
    expect(find.text('劳动仲裁专属信息'), findsNothing);
  });

  testWidgets('template tap fills sample fields and switches type', (
    tester,
  ) async {
    await pumpDocumentGeneratePage(tester, size: const Size(390, 844));

    await openDocumentTypeDropdown(tester);
    await tester.tap(find.text('律师函').last);
    await tester.pumpAndSettle();

    expect(find.text('律师函专属信息'), findsOneWidget);
    expect(find.text('关于拖欠服务费纠纷事项之律师函'), findsOneWidget);
    expect(find.text('某某企业管理有限公司'), findsOneWidget);
  });

  testWidgets('generate submits AI request with structured user input', (
    tester,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    final repository = _GenerateFlowRepository(preferences: preferences);

    await pumpDocumentGeneratePage(
      tester,
      size: const Size(390, 844),
      repository: repository,
    );

    final generateButton = find.text('立即生成文档');
    await tester.scrollUntilVisible(
      generateButton,
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(generateButton);
    await tester.pumpAndSettle();

    expect(repository.saveCalled, isTrue);
    expect(repository.lastDraft, isNotNull);
    expect(repository.lastDraft!.userInput.trim().isNotEmpty, isTrue);
  });
}
