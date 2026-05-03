import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'package:lexcore/core/storage/local_storage.dart';
import 'package:lexcore/features/search/application/search_controller.dart';
import 'package:lexcore/features/search/application/voice_search_controller.dart';
import 'package:lexcore/features/search/presentation/pages/legal_search_page.dart';
import 'package:lexcore/shared/components/app_list_tile_item.dart';
import 'package:lexcore/shared/models/legal_models.dart';

void main() {
  const mockResults = <LawSearchItem>[
    LawSearchItem(
      title: '中华人民共和国劳动合同法 第三十条',
      snippet: '用人单位应当及时足额支付劳动报酬。',
      articleCode: 'LCL-30',
    ),
    LawSearchItem(
      title: '中华人民共和国劳动合同法 第四十七条',
      snippet: '经济补偿按劳动者在本单位工作的年限计算。',
      articleCode: 'LCL-47',
    ),
    LawSearchItem(
      title: '中华人民共和国民法典 第一百六十五条',
      snippet: '民事法律行为可以基于意思表示一致成立。',
      articleCode: 'CC-165',
    ),
  ];

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpSearchPage(
    WidgetTester tester, {
    required _FakeVoiceSpeechClient speechClient,
    required _FakeVoiceSearchPermissionClient permissionClient,
  }) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    final preferences = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          voiceSearchControllerProvider.overrideWith(
            (ref) => VoiceSearchController(
              permissionClient: permissionClient,
              speechClient: speechClient,
              targetPlatform: TargetPlatform.android,
            ),
          ),
          filteredHotSearchArticlesProvider.overrideWith((ref) {
            final keyword = ref.watch(searchControllerProvider).trim();
            if (keyword.isEmpty) {
              return const AsyncValue.data(mockResults);
            }
            final matched = mockResults
                .where(
                  (item) =>
                      item.title.contains(keyword) ||
                      item.snippet.contains(keyword),
                )
                .toList();
            return AsyncValue.data(matched);
          }),
          searchNoticeProvider.overrideWith(
            (ref) => const AsyncValue.data(null),
          ),
          searchScenarioGroupsProvider.overrideWith((ref) => const []),
        ],
        child: const MaterialApp(home: LegalSearchPage()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 900));
  }

  testWidgets('voice button opens sheet and writes transcript into search', (
    tester,
  ) async {
    final speechClient = _FakeVoiceSpeechClient();
    final permissionClient = _FakeVoiceSearchPermissionClient();
    await pumpSearchPage(
      tester,
      speechClient: speechClient,
      permissionClient: permissionClient,
    );

    expect(
      find.byKey(const ValueKey<String>('legal_search_voice_button')),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('legal_search_voice_button')),
    );
    await tester.pumpAndSettle();

    expect(find.text('语音搜索'), findsOneWidget);
    expect(find.text('正在聆听，请说话...'), findsOneWidget);
    expect(speechClient.listenCount, 1);

    speechClient.emitPartial('劳动合同');
    await tester.pump();

    expect(
      find.byKey(const ValueKey<String>('voice_search_transcript')),
      findsOneWidget,
    );
    expect(find.text('劳动合同'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey<String>('voice_search_finish_button')),
    );
    await tester.pumpAndSettle();

    final searchField = tester.widget<TextField>(find.byType(TextField));
    expect(searchField.controller?.text, '劳动合同');
    expect(find.text('搜索结果'), findsOneWidget);
    expect(find.byType(AppListTileItem), findsNWidgets(2));
    expect(speechClient.stopCount, 1);
  });

  testWidgets('permanent permission denial shows settings recovery action', (
    tester,
  ) async {
    final speechClient = _FakeVoiceSpeechClient();
    final permissionClient = _FakeVoiceSearchPermissionClient(
      microphoneStatus: PermissionStatus.permanentlyDenied,
    );
    await pumpSearchPage(
      tester,
      speechClient: speechClient,
      permissionClient: permissionClient,
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('legal_search_voice_button')),
    );
    await tester.pumpAndSettle();

    expect(find.text('麦克风权限已被拒绝，请在系统设置中开启'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('voice_search_open_settings_button')),
      findsOneWidget,
    );
    expect(speechClient.listenCount, 0);

    await tester.tap(
      find.byKey(const ValueKey<String>('voice_search_open_settings_button')),
    );
    await tester.pump();

    expect(permissionClient.openSettingsCount, 1);
  });
}

class _FakeVoiceSearchPermissionClient implements VoiceSearchPermissionClient {
  _FakeVoiceSearchPermissionClient({
    this.microphoneStatus = PermissionStatus.granted,
  });

  PermissionStatus microphoneStatus;
  int microphoneRequestCount = 0;
  int speechRequestCount = 0;
  int openSettingsCount = 0;

  @override
  Future<PermissionStatus> requestMicrophone() async {
    microphoneRequestCount += 1;
    return microphoneStatus;
  }

  @override
  Future<PermissionStatus> requestSpeechRecognition() async {
    speechRequestCount += 1;
    return PermissionStatus.granted;
  }

  @override
  Future<void> openSystemSettings() async {
    openSettingsCount += 1;
  }
}

class _FakeVoiceSpeechClient implements VoiceSpeechClient {
  SpeechStatusListener? statusListener;
  SpeechErrorListener? errorListener;
  SpeechResultListener? resultListener;
  SpeechSoundLevelChange? soundLevelListener;
  int initializeCount = 0;
  int listenCount = 0;
  int stopCount = 0;
  String? lastLocaleId;

  @override
  bool isListening = false;

  @override
  Future<bool> initialize({
    required SpeechStatusListener onStatus,
    required SpeechErrorListener onError,
  }) async {
    initializeCount += 1;
    statusListener = onStatus;
    errorListener = onError;
    return true;
  }

  @override
  Future<void> listen({
    required SpeechResultListener onResult,
    required SpeechSoundLevelChange onSoundLevelChange,
    required Duration listenFor,
    required Duration pauseFor,
    required String? localeId,
  }) async {
    listenCount += 1;
    resultListener = onResult;
    soundLevelListener = onSoundLevelChange;
    lastLocaleId = localeId;
    isListening = true;
  }

  @override
  Future<void> stop() async {
    stopCount += 1;
    isListening = false;
  }

  @override
  Future<void> cancel() async {
    isListening = false;
  }

  @override
  Future<List<LocaleName>> locales() async {
    return [LocaleName('zh_CN', '中文（中国）')];
  }

  @override
  Future<LocaleName?> systemLocale() async {
    return LocaleName('en_US', 'English');
  }

  void emitPartial(String text) {
    resultListener?.call(
      SpeechRecognitionResult([SpeechRecognitionWords(text, null, 1)], false),
    );
  }
}
