import 'package:lexcore/features/history/data/repositories/history_repository.dart';
import 'package:lexcore/features/home/domain/entities/home_entity.dart';
import 'package:lexcore/core/network/api_client.dart';
import 'package:lexcore/shared/config/static_ui_config.dart';
import 'package:lexcore/shared/models/legal_models.dart';

class HomeRepository {
  const HomeRepository(this._apiClient, [this._historyRepository]);

  static const int _recentActivityLimit = 5;

  final ApiClient _apiClient;
  final HistoryRepository? _historyRepository;

  Future<HomeEntity> fetchHomeData() async {
    final activities = await _loadRecentActivities();
    return HomeEntity(
      actions: StaticUiConfig.quickActions,
      activities: activities,
    );
  }

  Future<List<ActivityRecord>> _loadRecentActivities() async {
    final historyRepository = _historyRepository;
    if (historyRepository != null) {
      try {
        final items = await historyRepository.loadAll();
        final mapped = items
            .map(
              (item) => ActivityRecord(
                title: item.title,
                time: item.time,
                tag: _tagFromCategory(item.category),
              ),
            )
            .toList(growable: false);
        mapped.sort((a, b) => b.time.compareTo(a.time));
        return mapped.take(_recentActivityLimit).toList(growable: false);
      } catch (_) {
        // Fall through to legacy remote-only loading.
      }
    }

    try {
      final result = await _apiClient.get<Map<String, dynamic>>(
        '/history',
        queryParameters: const {'offset': 0, 'limit': 20},
        decoder: (data) => (data as Map?)?.cast<String, dynamic>() ?? const {},
      );
      final items = (result['items'] as List?) ?? const [];
      final mapped = items
          .whereType<Map>()
          .map((item) {
            final map = item.cast<String, dynamic>();
            return ActivityRecord(
              title: map['event_summary'] as String? ?? '',
              time:
                  DateTime.tryParse(map['created_at'] as String? ?? '') ??
                  DateTime.fromMillisecondsSinceEpoch(0),
              tag: _tagFromEventType(map['event_type'] as String? ?? ''),
            );
          })
          .where((item) => item.title.trim().isNotEmpty)
          .toList();
      mapped.sort((a, b) => b.time.compareTo(a.time));
      return mapped.take(_recentActivityLimit).toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  String _tagFromEventType(String eventType) {
    if (eventType.contains('document') || eventType.contains('pdf')) {
      return '文档';
    }
    if (eventType.contains('search') || eventType.contains('analysis')) {
      return '分析';
    }
    return '咨询';
  }

  String _tagFromCategory(HistoryCategory category) {
    return switch (category) {
      HistoryCategory.consultation => '咨询',
      HistoryCategory.analysis => '分析',
      HistoryCategory.document => '文档',
    };
  }
}
