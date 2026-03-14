import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import 'package:lexcore/core/export/app_export_service.dart';

final appLoggerProvider = Provider<Logger>((ref) {
  return Logger();
});

final appExportServiceProvider = Provider<AppExportService>((ref) {
  return LocalAppExportService();
});
