import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lexcore/core/error/app_exception.dart';
import 'package:lexcore/core/network/api_client.dart';
import 'package:lexcore/features/profile/data/repositories/profile_repository.dart';

class _FakeProfileApiClient extends ApiClient {
  _FakeProfileApiClient() : super(Dio());

  Map<String, dynamic> mePayload = {
    'email': 'lawyer@example.com',
    'profile': {
      'name': '张三律师',
      'job_title': '合伙人',
      'phone': '+8613800138000',
      'email': 'lawyer@example.com',
    },
  };
  Map<String, dynamic> subscriptionPayload = {
    'plan_code': 'pro',
    'status': 'active',
  };
  Map<String, dynamic> quotaPayload = {
    'document_remaining': 12,
    'pdf_remaining': 5,
  };
  List<Map<String, dynamic>> plansPayload = const [
    {'code': 'pro', 'name': '专业版'},
  ];

  bool throwMe = false;
  bool throwSubscription = false;
  bool throwQuota = false;
  bool throwPlans = false;

  @override
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    required T Function(Object? data) decoder,
  }) async {
    switch (path) {
      case '/users/me':
        if (throwMe) {
          throw AppException('me unavailable');
        }
        return decoder(mePayload);
      case '/subscriptions/me':
        if (throwSubscription) {
          throw AppException('subscription unavailable');
        }
        return decoder(subscriptionPayload);
      case '/subscriptions/quota':
        if (throwQuota) {
          throw AppException('quota unavailable');
        }
        return decoder(quotaPayload);
      case '/subscriptions/plans':
        if (throwPlans) {
          throw AppException('plans unavailable');
        }
        return decoder(plansPayload);
      default:
        throw UnimplementedError('Unhandled GET path: $path');
    }
  }
}

void main() {
  test('summary keeps page usable when subscription endpoints fail', () async {
    final apiClient = _FakeProfileApiClient()
      ..throwSubscription = true
      ..throwQuota = true
      ..throwPlans = true;
    final repository = ProfileRepository(apiClient);

    final summary = await repository.summary();

    expect(summary.name, '张三律师');
    expect(summary.role, '合伙人');
    expect(summary.phone, '+8613800138000');
    expect(summary.email, 'lawyer@example.com');
    expect(summary.membership, 'FREE');
    expect(summary.benefits, const ['文书剩余：0', 'PDF 剩余：0']);
  });

  test('summary falls back to defaults when all endpoints fail', () async {
    final apiClient = _FakeProfileApiClient()
      ..throwMe = true
      ..throwSubscription = true
      ..throwQuota = true
      ..throwPlans = true;
    final repository = ProfileRepository(apiClient);

    final summary = await repository.summary();

    expect(summary.name, '');
    expect(summary.role, '');
    expect(summary.phone, '');
    expect(summary.email, '');
    expect(summary.membership, 'FREE');
    expect(summary.benefits, const ['文书剩余：0', 'PDF 剩余：0']);
  });

  test('subscriptionSnapshot falls back to renderable defaults', () async {
    final apiClient = _FakeProfileApiClient()
      ..throwSubscription = true
      ..throwQuota = true
      ..throwPlans = true;
    final repository = ProfileRepository(apiClient);

    final snapshot = await repository.subscriptionSnapshot();

    expect(snapshot.planCode, 'FREE');
    expect(snapshot.status, 'active');
    expect(snapshot.documentRemaining, 0);
    expect(snapshot.pdfRemaining, 0);
  });
}
