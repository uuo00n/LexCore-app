import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lexcore/core/network/api_client.dart';
import 'package:lexcore/features/document/data/repositories/document_repository.dart';
import 'package:lexcore/shared/models/legal_models.dart';

class _FakeDocumentApiClient extends ApiClient {
  _FakeDocumentApiClient()
    : _documents = [
        {
          'document_id': 'doc_1',
          'title': '劳动仲裁申请书-2026-03-06',
          'content_markdown': '# 劳动仲裁申请书-2026-03-06',
          'doc_type': '仲裁文书',
          'status': 'completed',
          'created_at': '2026-03-06T10:00:00.000Z',
          'updated_at': '2026-03-07T10:00:00.000Z',
        },
        {
          'document_id': 'doc_2',
          'title': '仅 content 字段文档',
          'content': '# 仅 content 字段文档\n\n正文来自 content',
          'doc_type': '律师函',
          'status': 'completed',
          'created_at': '2026-03-05T10:00:00.000Z',
        },
        {
          'document_id': 'doc_3',
          'title': '失败文书',
          'content_markdown': '',
          'doc_type': '仲裁文书',
          'status': 'failed',
          'error_message': 'yuanqi business error: 400',
          'created_at': '2026-03-04T10:00:00.000Z',
        },
      ],
      super(Dio());

  final List<Map<String, dynamic>> _documents;
  Map<String, dynamic>? lastGeneratePayload;

  @override
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    required T Function(Object? data) decoder,
  }) async {
    if (path == '/documents') {
      return decoder({'items': _documents});
    }

    if (path.startsWith('/documents/')) {
      final id = path.split('/').last;
      final item = _documents.firstWhere(
        (value) => value['document_id'] == id,
        orElse: () => const {},
      );
      return decoder(item);
    }

    return decoder(const {});
  }

  @override
  Future<T> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    required T Function(Object? data) decoder,
  }) async {
    if (path == '/documents/generate') {
      final payload = (data as Map?)?.cast<String, dynamic>() ?? const {};
      lastGeneratePayload = payload;
      final now = DateTime.now().toUtc().toIso8601String();
      final docId = 'doc_${_documents.length + 1}';
      _documents.insert(0, {
        'document_id': docId,
        'title': payload['title'] as String? ?? '未命名文档',
        'content_markdown': payload['user_input'] as String? ?? '',
        'doc_type': payload['doc_type'] as String? ?? '法律文书',
        'status': 'queued',
        'created_at': now,
        'updated_at': now,
      });
      return decoder({'document_id': docId, 'status': 'queued'});
    }
    return decoder(const {});
  }

  @override
  Future<T> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    required T Function(Object? data) decoder,
  }) async {
    if (path.startsWith('/documents/')) {
      final id = path.split('/').last;
      final payload = (data as Map?)?.cast<String, dynamic>() ?? const {};
      final index = _documents.indexWhere((item) => item['document_id'] == id);
      if (index < 0) {
        return decoder(const {});
      }
      final now = DateTime.now().toUtc().toIso8601String();
      _documents[index] = {
        ..._documents[index],
        'title': payload['title'] as String? ?? _documents[index]['title'],
        'content_markdown':
            payload['content_markdown'] as String? ??
            _documents[index]['content_markdown'],
        'updated_at': now,
      };
      return decoder(_documents[index]);
    }
    return decoder(const {});
  }
}

Future<DocumentRepository> _buildRepository() async {
  final preferences = await SharedPreferences.getInstance();
  return DocumentRepository(_FakeDocumentApiClient(), preferences);
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('loadSaved returns seeded documents from api', () async {
    final repository = await _buildRepository();

    final documents = await repository.loadSaved();

    expect(documents, isNotEmpty);
    expect(documents.first.name, '劳动仲裁申请书-2026-03-06');
    expect(documents.first.type, '劳动仲裁');
    expect(
      documents.first.updatedAt,
      DateTime.parse('2026-03-07T10:00:00.000Z'),
    );
  });

  test('saveDraft triggers generate and list reflects new document', () async {
    final repository = await _buildRepository();
    const draft = DocumentDraft(title: '新生成的民事起诉状', markdown: '# 新生成的民事起诉状');

    final result = await repository.saveDraft(draft);
    final documents = await repository.loadSaved();

    expect(result.result, DocumentSaveResult.created);
    expect(result.documentId, isNotEmpty);
    expect(documents.first.name, draft.title);
    expect(documents.where((item) => item.name == draft.title), hasLength(1));
  });

  test('saveDraft prefers user_input when provided', () async {
    final repository = await _buildRepository();
    const draft = DocumentDraft(
      title: '律师函-样例',
      markdown: '# 预览文本',
      docType: '律师函',
      userInput: '收函方：某某公司\\n具体要求：3日内支付',
    );

    await repository.saveDraft(draft);
    final documents = await repository.loadSaved();

    expect(documents.first.name, '律师函-样例');
    expect(documents.first.markdown, contains('收函方：某某公司'));
    expect(documents.first.markdown, isNot(contains('# 预览文本')));
  });

  test(
    'saveDraft submits canonical doc_type with full user_input payload',
    () async {
      final api = _FakeDocumentApiClient();
      final preferences = await SharedPreferences.getInstance();
      final repository = DocumentRepository(api, preferences);
      const draft = DocumentDraft(
        title: '劳动仲裁申请书（工资争议）',
        markdown: '# 劳动仲裁申请书（工资争议）',
        docType: '劳动仲裁申请书',
        userInput: '类型：劳动仲裁\n申请人姓名：李某\n被申请人名称：某科技公司',
      );

      await repository.saveDraft(draft);

      expect(api.lastGeneratePayload, isNotNull);
      expect(api.lastGeneratePayload!['doc_type'], '劳动仲裁');
      expect(
        api.lastGeneratePayload!['user_input'],
        '类型：劳动仲裁\n申请人姓名：李某\n被申请人名称：某科技公司',
      );
    },
  );

  test('updateDocument calls backend patch and reflects in loadById', () async {
    final repository = await _buildRepository();

    final updated = await repository.updateDocument(
      id: 'doc_2',
      title: '劳动仲裁申请书（本地编辑）',
      markdown: '# 劳动仲裁申请书（本地编辑）\n\n更新后的正文',
    );
    final detail = await repository.loadById('doc_2');

    expect(updated, isNotNull);
    expect(detail, isNotNull);
    expect(detail!.name, '劳动仲裁申请书（本地编辑）');
    expect(detail.markdown, contains('更新后的正文'));
  });

  test(
    'loadSaved and loadById map content field when content_markdown is missing',
    () async {
      final repository = await _buildRepository();

      final documents = await repository.loadSaved();
      final fromList = documents.firstWhere((item) => item.id == 'doc_2');
      final detail = await repository.loadById('doc_2');

      expect(fromList.markdown, contains('正文来自 content'));
      expect(detail, isNotNull);
      expect(detail!.markdown, contains('正文来自 content'));
    },
  );

  test('loadSaved and loadById map backend error_message', () async {
    final repository = await _buildRepository();

    final documents = await repository.loadSaved();
    final failed = documents.firstWhere((item) => item.id == 'doc_3');
    final detail = await repository.loadById('doc_3');

    expect(failed.status, 'failed');
    expect(failed.errorMessage, 'yuanqi business error: 400');
    expect(detail, isNotNull);
    expect(detail!.errorMessage, 'yuanqi business error: 400');
  });
}
