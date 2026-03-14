import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lexcore/shared/widgets/app_searchable_dropdown_field.dart';

void main() {
  const options = ['劳动仲裁申请书', '律师函', '合同审查意见', '企业合规报告'];

  Future<void> pumpDropdown(
    WidgetTester tester, {
    String? initialValue = '劳动仲裁申请书',
  }) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 320,
              child: _DropdownHarness(
                initialValue: initialValue,
                options: options,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder findDropdown() => find.byType(AppSearchableDropdownField);

  Finder findDropdownTextField() =>
      find.descendant(of: findDropdown(), matching: find.byType(TextField));

  Future<void> openDropdown(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.keyboard_arrow_down_rounded));
    await tester.pumpAndSettle();
  }

  testWidgets('shows current value and all options after opening', (
    tester,
  ) async {
    await pumpDropdown(tester);

    expect(find.text('劳动仲裁申请书'), findsOneWidget);

    await openDropdown(tester);

    expect(find.text('劳动仲裁申请书'), findsAtLeastNWidgets(2));
    expect(find.text('律师函'), findsOneWidget);
    expect(find.text('合同审查意见'), findsOneWidget);
    expect(find.text('企业合规报告'), findsOneWidget);
  });

  testWidgets('filters options and commits selected result', (tester) async {
    await pumpDropdown(tester);
    await openDropdown(tester);

    await tester.enterText(findDropdownTextField(), '律师');
    await tester.pumpAndSettle();

    expect(find.text('律师函'), findsOneWidget);
    expect(find.text('劳动仲裁申请书'), findsNothing);
    expect(find.text('合同审查意见'), findsNothing);
    expect(find.text('企业合规报告'), findsNothing);

    await tester.tap(find.text('律师函').last);
    await tester.pumpAndSettle();

    expect(find.text('律师函'), findsOneWidget);
  });

  testWidgets('shows empty state and restores committed value after blur', (
    tester,
  ) async {
    await pumpDropdown(tester);
    await openDropdown(tester);

    await tester.enterText(findDropdownTextField(), '不存在');
    await tester.pumpAndSettle();

    expect(find.text('未找到匹配项'), findsOneWidget);

    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(find.text('未找到匹配项'), findsNothing);
    expect(find.text('劳动仲裁申请书'), findsOneWidget);
  });

  testWidgets('syncs when parent value changes externally', (tester) async {
    await pumpDropdown(tester);

    await tester.tap(find.byKey(const ValueKey<String>('change_value_button')));
    await tester.pumpAndSettle();

    expect(find.text('合同审查意见'), findsOneWidget);
  });
}

class _DropdownHarness extends StatefulWidget {
  const _DropdownHarness({required this.initialValue, required this.options});

  final String? initialValue;
  final List<String> options;

  @override
  State<_DropdownHarness> createState() => _DropdownHarnessState();
}

class _DropdownHarnessState extends State<_DropdownHarness> {
  late String? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppSearchableDropdownField(
          label: '文档类型',
          value: _selectedValue,
          options: widget.options,
          onChanged: (value) {
            setState(() {
              _selectedValue = value;
            });
          },
        ),
        const SizedBox(height: 12),
        TextButton(
          key: const ValueKey<String>('change_value_button'),
          onPressed: () {
            setState(() {
              _selectedValue = '合同审查意见';
            });
          },
          child: const Text('切换外部值'),
        ),
      ],
    );
  }
}
