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
        },
      ],
      super(Dio());

  final List<Map<String, dynamic>> _documents;

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
      final now = DateTime.now().toUtc().toIso8601String();
      _documents.insert(0, {
        'document_id': 'doc_${_documents.length + 1}',
        'title': payload['title'] as String? ?? '未命名文档',
        'content_markdown': payload['prompt'] as String? ?? '',
        'doc_type': payload['doc_type'] as String? ?? '法律文书',
        'status': 'queued',
        'created_at': now,
      });
      return decoder({'queued': true});
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
    expect(documents.first.type, '仲裁文书');
  });

  test('saveDraft triggers generate and list reflects new document', () async {
    final repository = await _buildRepository();
    const draft = DocumentDraft(title: '新生成的民事起诉状', markdown: '# 新生成的民事起诉状');

    final result = await repository.saveDraft(draft);
    final documents = await repository.loadSaved();

    expect(result, DocumentSaveResult.created);
    expect(documents.first.name, draft.title);
    expect(documents.where((item) => item.name == draft.title), hasLength(1));
  });

  test('updateDocument stores local edits and reflects in loadById', () async {
    final repository = await _buildRepository();

    final updated = await repository.updateDocument(
      id: 'doc_1',
      title: '劳动仲裁申请书（本地编辑）',
      markdown: '# 劳动仲裁申请书（本地编辑）\n\n更新后的正文',
    );
    final detail = await repository.loadById('doc_1');

    expect(updated, isNotNull);
    expect(detail, isNotNull);
    expect(detail!.name, '劳动仲裁申请书（本地编辑）');
    expect(detail.markdown, contains('更新后的正文'));
  });
}
