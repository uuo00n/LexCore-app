import 'package:lexcore/core/network/api_client.dart';
import 'package:lexcore/features/profile/domain/entities/profile_summary.dart';
import 'package:lexcore/shared/models/legal_models.dart';

class ProfileRepository {
  const ProfileRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<ProfileSummary> summary() async {
    final me = await _safeGetMap('/users/me');
    final subscription = await _safeGetMap('/subscriptions/me');
    final quota = await _safeGetMap('/subscriptions/quota');
    final plans = await _safeLoadPlans();

    final profile =
        (me['profile'] as Map?)?.cast<String, dynamic>() ?? const {};
    final docRemaining = _toInt(quota['document_remaining']);
    final pdfRemaining = _toInt(quota['pdf_remaining']);
    final planCode = (subscription['plan_code'] as String? ?? 'free')
        .toLowerCase();

    return ProfileSummary(
      name: profile['name'] as String? ?? '',
      role: profile['job_title'] as String? ?? '',
      phone: profile['phone'] as String? ?? '',
      email: profile['email'] as String? ?? me['email'] as String? ?? '',
      membership: _resolvePlanName(planCode, plans),
      nextBillingDate: '以套餐规则为准',
      benefits: <String>['文书剩余：$docRemaining', 'PDF 剩余：$pdfRemaining'],
    );
  }

  Future<ProfileSubscriptionSnapshot> subscriptionSnapshot() async {
    final subscription = await _safeGetMap('/subscriptions/me');
    final quota = await _safeGetMap('/subscriptions/quota');
    final plans = await _safeLoadPlans();
    final planCode = (subscription['plan_code'] as String? ?? 'free')
        .toLowerCase();
    return ProfileSubscriptionSnapshot(
      planCode: _resolvePlanName(planCode, plans),
      status: subscription['status'] as String? ?? 'active',
      documentRemaining: _toInt(quota['document_remaining']),
      pdfRemaining: _toInt(quota['pdf_remaining']),
    );
  }

  List<ProfileMenuItem> menus() {
    return const [
      ProfileMenuItem(
        title: '我的文档',
        icon: 'folder_open',
        route: '/document/saved',
      ),
      ProfileMenuItem(title: '历史记录', icon: 'history', route: '/history'),
    ];
  }

  Future<List<Map<String, dynamic>>> _loadPlans() async {
    return _apiClient.get<List<Map<String, dynamic>>>(
      '/subscriptions/plans',
      decoder: (data) {
        final list = (data as List?) ?? const [];
        return list
            .whereType<Map>()
            .map((item) => item.cast<String, dynamic>())
            .toList();
      },
    );
  }

  Future<Map<String, dynamic>> _safeGetMap(String path) async {
    try {
      return await _apiClient.get<Map<String, dynamic>>(
        path,
        decoder: (data) => (data as Map?)?.cast<String, dynamic>() ?? const {},
      );
    } catch (_) {
      return const {};
    }
  }

  Future<List<Map<String, dynamic>>> _safeLoadPlans() async {
    try {
      return await _loadPlans();
    } catch (_) {
      return const [];
    }
  }

  int _toInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value.trim()) ?? 0;
    }
    return 0;
  }

  String _resolvePlanName(String planCode, List<Map<String, dynamic>> plans) {
    for (final plan in plans) {
      final code = (plan['code'] as String? ?? '').toLowerCase();
      if (code == planCode) {
        final name = plan['name'] as String?;
        if (name != null && name.trim().isNotEmpty) {
          return name;
        }
      }
    }
    return planCode.toUpperCase();
  }
}
