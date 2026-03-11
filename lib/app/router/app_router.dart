import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lexcore/app/motion/app_page_transitions.dart';
import 'package:lexcore/app/motion/app_tab_transition_container.dart';
import 'package:lexcore/app/navigation/main_shell_page.dart';
import 'package:lexcore/features/analysis/presentation/pages/analysis_detail_page.dart';
import 'package:lexcore/features/analysis/presentation/pages/analysis_result_page.dart';
import 'package:lexcore/features/auth/presentation/pages/auth_page.dart';
import 'package:lexcore/features/auth/presentation/pages/register_page.dart';
import 'package:lexcore/features/consultation/presentation/pages/consultation_page.dart';
import 'package:lexcore/features/consultation/presentation/pages/consultation_stitch_detail_page.dart';
import 'package:lexcore/features/dashboard/presentation/pages/case_dashboard_page.dart';
import 'package:lexcore/features/document/presentation/pages/document_generate_page.dart';
import 'package:lexcore/features/document/presentation/pages/document_preview_page.dart';
import 'package:lexcore/features/document/presentation/pages/saved_documents_page.dart';
import 'package:lexcore/features/history/presentation/pages/history_page.dart';
import 'package:lexcore/features/home/presentation/pages/home_page.dart';
import 'package:lexcore/features/profile/presentation/pages/profile_page.dart';
import 'package:lexcore/features/search/presentation/pages/legal_article_page.dart';
import 'package:lexcore/features/search/presentation/pages/legal_search_page.dart';
import 'package:lexcore/features/settings/presentation/pages/settings_page.dart';
import 'package:lexcore/shared/models/legal_models.dart';

import 'route_names.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'homeBranch');
final _searchNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'searchBranch',
);
final _historyNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'historyBranch',
);
final _profileNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'profileBranch',
);

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RouteNames.authPath,
    routes: [
      GoRoute(
        path: RouteNames.authPath,
        name: RouteNames.auth,
        pageBuilder: (context, state) => AppPageTransitions.build(
          context: context,
          state: state,
          kind: AppRouteTransitionKind.standard,
          child: const AuthPage(),
        ),
      ),
      GoRoute(
        path: RouteNames.registerPath,
        name: RouteNames.register,
        pageBuilder: (context, state) => AppPageTransitions.build(
          context: context,
          state: state,
          kind: AppRouteTransitionKind.standard,
          child: const RegisterPage(),
        ),
      ),
      StatefulShellRoute(
        builder: (context, state, navigationShell) =>
            MainShellPage(navigationShell: navigationShell),
        navigatorContainerBuilder: (context, navigationShell, children) =>
            AppTabTransitionContainer(
              currentIndex: navigationShell.currentIndex,
              children: children,
            ),
        branches: [
          StatefulShellBranch(
            navigatorKey: _homeNavigatorKey,
            routes: [
              GoRoute(
                path: RouteNames.homePath,
                name: RouteNames.home,
                pageBuilder: (context, state) => AppPageTransitions.build(
                  context: context,
                  state: state,
                  kind: AppRouteTransitionKind.none,
                  child: const HomePage(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _searchNavigatorKey,
            routes: [
              GoRoute(
                path: RouteNames.legalSearchPath,
                name: RouteNames.legalSearch,
                pageBuilder: (context, state) => AppPageTransitions.build(
                  context: context,
                  state: state,
                  kind: AppRouteTransitionKind.none,
                  child: const LegalSearchPage(),
                ),
                routes: [
                  GoRoute(
                    path: 'article',
                    name: RouteNames.legalArticle,
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) => AppPageTransitions.build(
                      context: context,
                      state: state,
                      kind: AppRouteTransitionKind.detail,
                      child: LegalArticlePage(
                        searchItem: state.extra is LawSearchItem
                            ? state.extra! as LawSearchItem
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _historyNavigatorKey,
            routes: [
              GoRoute(
                path: RouteNames.historyPath,
                name: RouteNames.history,
                pageBuilder: (context, state) => AppPageTransitions.build(
                  context: context,
                  state: state,
                  kind: AppRouteTransitionKind.none,
                  child: const HistoryPage(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _profileNavigatorKey,
            routes: [
              GoRoute(
                path: RouteNames.profilePath,
                name: RouteNames.profile,
                pageBuilder: (context, state) => AppPageTransitions.build(
                  context: context,
                  state: state,
                  kind: AppRouteTransitionKind.none,
                  child: const ProfilePage(),
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: RouteNames.consultationPath,
        name: RouteNames.consultation,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => AppPageTransitions.build(
          context: context,
          state: state,
          kind: AppRouteTransitionKind.modal,
          child: const ConsultationPage(),
        ),
      ),
      GoRoute(
        path: RouteNames.consultationStitchDetailPath,
        name: RouteNames.consultationStitchDetail,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => AppPageTransitions.build(
          context: context,
          state: state,
          kind: AppRouteTransitionKind.detail,
          child: ConsultationStitchDetailPage(
            summary: state.extra is String ? state.extra! as String : null,
          ),
        ),
      ),
      GoRoute(
        path: RouteNames.analysisDetailPath,
        name: RouteNames.analysisDetail,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => AppPageTransitions.build(
          context: context,
          state: state,
          kind: AppRouteTransitionKind.detail,
          child: const AnalysisDetailPage(),
        ),
      ),
      GoRoute(
        path: RouteNames.analysisResultPath,
        name: RouteNames.analysisResult,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => AppPageTransitions.build(
          context: context,
          state: state,
          kind: AppRouteTransitionKind.detail,
          child: const AnalysisResultPage(),
        ),
      ),
      GoRoute(
        path: RouteNames.dashboardPath,
        name: RouteNames.dashboard,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => AppPageTransitions.build(
          context: context,
          state: state,
          kind: AppRouteTransitionKind.detail,
          child: const CaseDashboardPage(),
        ),
      ),
      GoRoute(
        path: RouteNames.documentGeneratePath,
        name: RouteNames.documentGenerate,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => AppPageTransitions.build(
          context: context,
          state: state,
          kind: AppRouteTransitionKind.modal,
          child: const DocumentGeneratePage(),
        ),
      ),
      GoRoute(
        path: RouteNames.documentPreviewPath,
        name: RouteNames.documentPreview,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => AppPageTransitions.build(
          context: context,
          state: state,
          kind: AppRouteTransitionKind.detail,
          child: const DocumentPreviewPage(),
        ),
      ),
      GoRoute(
        path: RouteNames.savedDocumentsPath,
        name: RouteNames.savedDocuments,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => AppPageTransitions.build(
          context: context,
          state: state,
          kind: AppRouteTransitionKind.detail,
          child: const SavedDocumentsPage(),
        ),
      ),
      GoRoute(
        path: RouteNames.settingsPath,
        name: RouteNames.settings,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => AppPageTransitions.build(
          context: context,
          state: state,
          kind: AppRouteTransitionKind.detail,
          child: const SettingsPage(),
        ),
      ),
    ],
  );
});
