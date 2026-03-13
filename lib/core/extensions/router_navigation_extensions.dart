import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:lexcore/app/router/route_names.dart';

extension RouterNavigationExtensions on BuildContext {
  static const Set<String> _shellRootRoutes = {
    RouteNames.homePath,
    RouteNames.legalSearchPath,
    RouteNames.historyPath,
    RouteNames.profilePath,
  };

  void navigateByRoute(String route) {
    if (_shellRootRoutes.contains(route)) {
      go(route);
      return;
    }
    push(route);
  }
}
