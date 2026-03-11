import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lexcore/app/app.dart';

void main() {
  testWidgets('App boots', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: LexCoreApp()));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.text('LexiAI'), findsOneWidget);
  });
}
