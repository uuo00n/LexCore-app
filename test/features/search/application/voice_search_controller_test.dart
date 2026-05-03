import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'package:lexcore/features/search/application/voice_search_controller.dart';

void main() {
  test(
    'Android starts recognition after microphone permission is granted',
    () async {
      final permissionClient = _FakeVoiceSearchPermissionClient();
      final speechClient = _FakeVoiceSpeechClient();
      final controller = VoiceSearchController(
        permissionClient: permissionClient,
        speechClient: speechClient,
        targetPlatform: TargetPlatform.android,
      );

      await controller.start();

      expect(permissionClient.microphoneRequestCount, 1);
      expect(permissionClient.speechRequestCount, 0);
      expect(speechClient.initializeCount, 1);
      expect(speechClient.listenCount, 1);
      expect(speechClient.lastLocaleId, 'zh_CN');
      expect(controller.state.status, VoiceSearchStatus.listening);

      controller.dispose();
    },
  );

  test('iOS requests microphone and speech recognition permissions', () async {
    final permissionClient = _FakeVoiceSearchPermissionClient();
    final speechClient = _FakeVoiceSpeechClient();
    final controller = VoiceSearchController(
      permissionClient: permissionClient,
      speechClient: speechClient,
      targetPlatform: TargetPlatform.iOS,
    );

    await controller.start();

    expect(permissionClient.microphoneRequestCount, 1);
    expect(permissionClient.speechRequestCount, 1);
    expect(speechClient.listenCount, 1);
    expect(controller.state.status, VoiceSearchStatus.listening);

    controller.dispose();
  });

  test('partial and final results update effective transcript', () async {
    final speechClient = _FakeVoiceSpeechClient();
    final controller = VoiceSearchController(
      permissionClient: _FakeVoiceSearchPermissionClient(),
      speechClient: speechClient,
      targetPlatform: TargetPlatform.android,
    );

    await controller.start();
    speechClient.emitPartial('劳动合同');

    expect(controller.state.status, VoiceSearchStatus.listening);
    expect(controller.state.partialText, '劳动合同');
    expect(controller.state.effectiveText, '劳动合同');

    speechClient.emitFinal('劳动合同纠纷');

    expect(controller.state.status, VoiceSearchStatus.done);
    expect(controller.state.finalText, '劳动合同纠纷');
    expect(controller.state.effectiveText, '劳动合同纠纷');

    controller.dispose();
  });

  test('empty natural stop becomes retryable no-speech error', () async {
    final speechClient = _FakeVoiceSpeechClient();
    final controller = VoiceSearchController(
      permissionClient: _FakeVoiceSearchPermissionClient(),
      speechClient: speechClient,
      targetPlatform: TargetPlatform.android,
    );

    await controller.start();
    speechClient.emitStatus('notListening');

    expect(controller.state.status, VoiceSearchStatus.error);
    expect(controller.state.errorMessage, '未识别到语音，请靠近麦克风重试');

    controller.dispose();
  });

  test('speech errors are mapped to user-facing messages', () async {
    final speechClient = _FakeVoiceSpeechClient();
    final controller = VoiceSearchController(
      permissionClient: _FakeVoiceSearchPermissionClient(),
      speechClient: speechClient,
      targetPlatform: TargetPlatform.android,
    );

    await controller.start();
    speechClient.emitError('error_network');

    expect(controller.state.status, VoiceSearchStatus.error);
    expect(controller.state.errorMessage, '网络异常，无法完成在线识别');
    expect(controller.state.permissionPermanentlyDenied, isFalse);

    controller.dispose();
  });

  test('permission denial blocks recognition before initialization', () async {
    final permissionClient = _FakeVoiceSearchPermissionClient(
      microphoneStatus: PermissionStatus.denied,
    );
    final speechClient = _FakeVoiceSpeechClient();
    final controller = VoiceSearchController(
      permissionClient: permissionClient,
      speechClient: speechClient,
      targetPlatform: TargetPlatform.android,
    );

    await controller.start();

    expect(controller.state.status, VoiceSearchStatus.error);
    expect(controller.state.errorMessage, '需要麦克风权限才能使用语音搜索');
    expect(controller.state.permissionPermanentlyDenied, isFalse);
    expect(speechClient.initializeCount, 0);
    expect(speechClient.listenCount, 0);

    controller.dispose();
  });

  test('permanent permission denial enables settings recovery state', () async {
    final permissionClient = _FakeVoiceSearchPermissionClient(
      microphoneStatus: PermissionStatus.permanentlyDenied,
    );
    final controller = VoiceSearchController(
      permissionClient: permissionClient,
      speechClient: _FakeVoiceSpeechClient(),
      targetPlatform: TargetPlatform.android,
    );

    await controller.start();
    await controller.openSystemSettings();

    expect(controller.state.status, VoiceSearchStatus.error);
    expect(controller.state.errorMessage, '麦克风权限已被拒绝，请在系统设置中开启');
    expect(controller.state.permissionPermanentlyDenied, isTrue);
    expect(permissionClient.openSettingsCount, 1);

    controller.dispose();
  });

  test('iOS speech permission denial is handled separately', () async {
    final permissionClient = _FakeVoiceSearchPermissionClient(
      speechStatus: PermissionStatus.denied,
    );
    final speechClient = _FakeVoiceSpeechClient();
    final controller = VoiceSearchController(
      permissionClient: permissionClient,
      speechClient: speechClient,
      targetPlatform: TargetPlatform.iOS,
    );

    await controller.start();

    expect(permissionClient.microphoneRequestCount, 1);
    expect(permissionClient.speechRequestCount, 1);
    expect(controller.state.status, VoiceSearchStatus.error);
    expect(controller.state.errorMessage, '需要语音识别权限才能使用语音搜索');
    expect(speechClient.initializeCount, 0);

    controller.dispose();
  });

  test(
    'unsupported platforms do not request permissions or start speech',
    () async {
      final permissionClient = _FakeVoiceSearchPermissionClient();
      final speechClient = _FakeVoiceSpeechClient();
      final controller = VoiceSearchController(
        permissionClient: permissionClient,
        speechClient: speechClient,
        targetPlatform: TargetPlatform.macOS,
      );

      await controller.start();

      expect(controller.state.status, VoiceSearchStatus.unsupported);
      expect(controller.state.errorMessage, '当前平台暂不支持语音搜索');
      expect(permissionClient.microphoneRequestCount, 0);
      expect(speechClient.initializeCount, 0);
      expect(speechClient.listenCount, 0);

      controller.dispose();
    },
  );
}

class _FakeVoiceSearchPermissionClient implements VoiceSearchPermissionClient {
  _FakeVoiceSearchPermissionClient({
    this.microphoneStatus = PermissionStatus.granted,
    this.speechStatus = PermissionStatus.granted,
  });

  PermissionStatus microphoneStatus;
  PermissionStatus speechStatus;
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
    return speechStatus;
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
  int cancelCount = 0;
  String? lastLocaleId;
  bool initializeResult = true;

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
    return initializeResult;
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
    cancelCount += 1;
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
    resultListener?.call(_recognitionResult(text, finalResult: false));
  }

  void emitFinal(String text) {
    resultListener?.call(_recognitionResult(text, finalResult: true));
  }

  void emitStatus(String status) {
    if (status == 'notListening' || status == 'done') {
      isListening = false;
    }
    statusListener?.call(status);
  }

  void emitError(String code) {
    errorListener?.call(SpeechRecognitionError(code, true));
  }

  SpeechRecognitionResult _recognitionResult(
    String text, {
    required bool finalResult,
  }) {
    return SpeechRecognitionResult([
      SpeechRecognitionWords(text, null, 1),
    ], finalResult);
  }
}
