import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lexcore/core/utils/app_share.dart';

void main() {
  const channel = MethodChannel('dev.fluttercommunity.plus/share');

  List<MethodCall> mockShareChannel() {
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          return '';
        });
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });
    return calls;
  }

  Future<void> pumpShareButton(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (pageContext) {
              return Center(
                child: Builder(
                  builder: (buttonContext) {
                    return FilledButton(
                      onPressed: () {
                        AppShare.shareText(
                          pageContext: pageContext,
                          anchorContext: buttonContext,
                          text: 'share text',
                          subject: 'share subject',
                        );
                      },
                      child: const Text('触发分享'),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'AppShare includes anchor rect on iOS',
    (tester) async {
      final calls = mockShareChannel();

      await pumpShareButton(tester);
      await tester.tap(find.text('触发分享'));
      await tester.pumpAndSettle();

      final arguments = calls.single.arguments as Map<Object?, Object?>;
      expect(arguments['text'], 'share text');
      expect(arguments['subject'], 'share subject');
      expect(arguments['originX'], isA<double>());
      expect(arguments['originY'], isA<double>());
      expect(arguments['originWidth'], greaterThan(0));
      expect(arguments['originHeight'], greaterThan(0));
    },
    variant: const TargetPlatformVariant(<TargetPlatform>{TargetPlatform.iOS}),
  );

  testWidgets(
    'AppShare keeps Android payload unchanged',
    (tester) async {
      final calls = mockShareChannel();

      await pumpShareButton(tester);
      await tester.tap(find.text('触发分享'));
      await tester.pumpAndSettle();

      final arguments = calls.single.arguments as Map<Object?, Object?>;
      expect(arguments['text'], 'share text');
      expect(arguments['subject'], 'share subject');
      expect(arguments.containsKey('originX'), isFalse);
      expect(arguments.containsKey('originY'), isFalse);
      expect(arguments.containsKey('originWidth'), isFalse);
      expect(arguments.containsKey('originHeight'), isFalse);
    },
    variant: const TargetPlatformVariant(<TargetPlatform>{
      TargetPlatform.android,
    }),
  );
}
