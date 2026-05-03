import 'package:flutter/material.dart';

import 'package:lexcore/shared/widgets/app_sub_page_header.dart';

class AnalysisPageHeader extends StatelessWidget {
  const AnalysisPageHeader({
    super.key,
    required this.title,
    this.actions = const [],
  });

  final String title;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return AppSubPageHeader(title: title, actions: actions);
  }
}
