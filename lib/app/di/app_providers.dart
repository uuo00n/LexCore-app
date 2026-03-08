import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

final appLoggerProvider = Provider<Logger>((ref) {
  return Logger();
});
