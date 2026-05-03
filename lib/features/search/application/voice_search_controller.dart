import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

bool isVoiceSearchSupportedPlatform([TargetPlatform? targetPlatform]) {
  if (kIsWeb) {
    return false;
  }
  final platform = targetPlatform ?? defaultTargetPlatform;
  return platform == TargetPlatform.android || platform == TargetPlatform.iOS;
}

abstract class VoiceSearchPermissionClient {
  Future<PermissionStatus> requestMicrophone();

  Future<PermissionStatus> requestSpeechRecognition();

  Future<void> openSystemSettings();
}

class PermissionHandlerVoiceSearchPermissionClient
    implements VoiceSearchPermissionClient {
  const PermissionHandlerVoiceSearchPermissionClient();

  @override
  Future<PermissionStatus> requestMicrophone() {
    return Permission.microphone.request();
  }

  @override
  Future<PermissionStatus> requestSpeechRecognition() {
    return Permission.speech.request();
  }

  @override
  Future<void> openSystemSettings() async {
    await openAppSettings();
  }
}

abstract class VoiceSpeechClient {
  bool get isListening;

  Future<bool> initialize({
    required SpeechStatusListener onStatus,
    required SpeechErrorListener onError,
  });

  Future<void> listen({
    required SpeechResultListener onResult,
    required SpeechSoundLevelChange onSoundLevelChange,
    required Duration listenFor,
    required Duration pauseFor,
    required String? localeId,
  });

  Future<void> stop();

  Future<void> cancel();

  Future<List<LocaleName>> locales();

  Future<LocaleName?> systemLocale();
}

class SpeechToTextVoiceSpeechClient implements VoiceSpeechClient {
  SpeechToTextVoiceSpeechClient({SpeechToText? speech})
    : _speech = speech ?? SpeechToText();

  final SpeechToText _speech;

  @override
  bool get isListening => _speech.isListening;

  @override
  Future<bool> initialize({
    required SpeechStatusListener onStatus,
    required SpeechErrorListener onError,
  }) {
    return _speech.initialize(
      onStatus: onStatus,
      onError: onError,
      debugLogging: false,
    );
  }

  @override
  Future<void> listen({
    required SpeechResultListener onResult,
    required SpeechSoundLevelChange onSoundLevelChange,
    required Duration listenFor,
    required Duration pauseFor,
    required String? localeId,
  }) async {
    await _speech.listen(
      onResult: onResult,
      onSoundLevelChange: onSoundLevelChange,
      listenFor: listenFor,
      pauseFor: pauseFor,
      localeId: localeId,
      listenOptions: SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
        listenMode: ListenMode.search,
        autoPunctuation: false,
      ),
    );
  }

  @override
  Future<void> stop() => _speech.stop();

  @override
  Future<void> cancel() => _speech.cancel();

  @override
  Future<List<LocaleName>> locales() => _speech.locales();

  @override
  Future<LocaleName?> systemLocale() => _speech.systemLocale();
}

/// 语音搜索的状态机阶段。
enum VoiceSearchStatus {
  idle, // 未开始
  initializing, // 正在初始化或请求权限
  listening, // 正在采集
  processing, // 收尾，等待最终识别结果
  done, // 已收到 final result
  error, // 出错（识别异常 / 拒权 / 网络）
  unsupported, // 平台或设备不支持
}

class VoiceSearchState {
  const VoiceSearchState({
    required this.status,
    required this.partialText,
    required this.finalText,
    required this.soundLevel,
    this.errorMessage,
    this.permissionPermanentlyDenied = false,
  });

  factory VoiceSearchState.idle() => const VoiceSearchState(
    status: VoiceSearchStatus.idle,
    partialText: '',
    finalText: '',
    soundLevel: 0,
  );

  final VoiceSearchStatus status;
  final String partialText;
  final String finalText;
  final double soundLevel;
  final String? errorMessage;
  final bool permissionPermanentlyDenied;

  /// 当前可被外部使用的最佳文本：终稿优先，否则用 partial。
  String get effectiveText {
    if (finalText.trim().isNotEmpty) {
      return finalText.trim();
    }
    return partialText.trim();
  }

  bool get hasAnyText => effectiveText.isNotEmpty;

  bool get isBusy =>
      status == VoiceSearchStatus.initializing ||
      status == VoiceSearchStatus.listening ||
      status == VoiceSearchStatus.processing;

  VoiceSearchState copyWith({
    VoiceSearchStatus? status,
    String? partialText,
    String? finalText,
    double? soundLevel,
    String? errorMessage,
    bool clearErrorMessage = false,
    bool? permissionPermanentlyDenied,
  }) {
    return VoiceSearchState(
      status: status ?? this.status,
      partialText: partialText ?? this.partialText,
      finalText: finalText ?? this.finalText,
      soundLevel: soundLevel ?? this.soundLevel,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      permissionPermanentlyDenied:
          permissionPermanentlyDenied ?? this.permissionPermanentlyDenied,
    );
  }
}

/// 语音搜索控制器：把 speech_to_text 的回调式 API 包装成 Riverpod StateNotifier。
class VoiceSearchController extends StateNotifier<VoiceSearchState> {
  VoiceSearchController({
    VoiceSpeechClient? speechClient,
    VoiceSearchPermissionClient? permissionClient,
    TargetPlatform? targetPlatform,
  }) : _speechClient = speechClient ?? SpeechToTextVoiceSpeechClient(),
       _permissionClient =
           permissionClient ??
           const PermissionHandlerVoiceSearchPermissionClient(),
       _targetPlatform = targetPlatform,
       super(VoiceSearchState.idle());

  final VoiceSpeechClient _speechClient;
  final VoiceSearchPermissionClient _permissionClient;
  final TargetPlatform? _targetPlatform;
  bool _initialized = false;
  String? _resolvedLocaleId;

  @override
  void dispose() {
    if (_speechClient.isListening) {
      _speechClient.cancel();
    }
    super.dispose();
  }

  /// 初始化平台语音引擎，结果做一次缓存。
  Future<bool> ensureInitialized() async {
    if (_initialized) {
      return true;
    }
    if (!isVoiceSearchSupportedPlatform(_currentPlatform)) {
      state = state.copyWith(
        status: VoiceSearchStatus.unsupported,
        errorMessage: '当前平台暂不支持语音搜索',
        permissionPermanentlyDenied: false,
      );
      return false;
    }
    state = state.copyWith(
      status: VoiceSearchStatus.initializing,
      clearErrorMessage: true,
      permissionPermanentlyDenied: false,
    );
    try {
      final available = await _speechClient.initialize(
        onStatus: _onStatus,
        onError: _onError,
      );
      if (!mounted) {
        return false;
      }
      if (!available) {
        state = state.copyWith(
          status: VoiceSearchStatus.unsupported,
          errorMessage: '当前设备不支持语音识别',
        );
        return false;
      }
      _initialized = true;
      _resolvedLocaleId = await _resolveZhLocaleId();
      state = state.copyWith(status: VoiceSearchStatus.idle);
      return true;
    } catch (error) {
      state = state.copyWith(
        status: VoiceSearchStatus.error,
        errorMessage: '语音识别初始化失败：$error',
        permissionPermanentlyDenied: false,
      );
      return false;
    }
  }

  /// 申请语音搜索所需权限并开始监听。
  Future<void> start() async {
    if (!isVoiceSearchSupportedPlatform(_currentPlatform)) {
      state = state.copyWith(
        status: VoiceSearchStatus.unsupported,
        errorMessage: '当前平台暂不支持语音搜索',
        permissionPermanentlyDenied: false,
      );
      return;
    }

    final permissionGranted = await _ensureVoicePermissions();
    if (!mounted) {
      return;
    }
    if (!permissionGranted) {
      return; // 错误状态已由 _ensureVoicePermissions 设置
    }

    final ready = await ensureInitialized();
    if (!mounted || !ready) {
      return;
    }

    state = state.copyWith(
      status: VoiceSearchStatus.listening,
      partialText: '',
      finalText: '',
      soundLevel: 0,
      clearErrorMessage: true,
      permissionPermanentlyDenied: false,
    );

    try {
      await _speechClient.listen(
        onResult: _onResult,
        onSoundLevelChange: _onSoundLevel,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        localeId: _resolvedLocaleId,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      state = state.copyWith(
        status: VoiceSearchStatus.error,
        errorMessage: '无法启动语音识别：$error',
        permissionPermanentlyDenied: false,
      );
    }
  }

  /// 主动收尾：让平台返回最终结果。
  Future<void> stop() async {
    if (!_speechClient.isListening) {
      return;
    }
    state = state.copyWith(status: VoiceSearchStatus.processing);
    try {
      await _speechClient.stop();
    } catch (_) {
      // stop 失败不影响业务，最终状态由回调推动
    }
  }

  /// 丢弃这次识别。
  Future<void> cancel() async {
    if (_speechClient.isListening) {
      try {
        await _speechClient.cancel();
      } catch (_) {
        // 忽略
      }
    }
    if (!mounted) {
      return;
    }
    state = VoiceSearchState.idle();
  }

  /// 让 sheet 重新打开时回到干净状态。
  void reset() {
    if (!mounted) {
      return;
    }
    state = VoiceSearchState.idle();
  }

  Future<void> openSystemSettings() {
    return _permissionClient.openSystemSettings();
  }

  TargetPlatform get _currentPlatform =>
      _targetPlatform ?? defaultTargetPlatform;

  Future<bool> _ensureVoicePermissions() async {
    final microphoneStatus = await _permissionClient.requestMicrophone();
    if (!mounted) {
      return false;
    }
    if (!_isPermissionGranted(microphoneStatus)) {
      _setPermissionError(
        microphoneStatus,
        deniedMessage: '需要麦克风权限才能使用语音搜索',
        permanentlyDeniedMessage: '麦克风权限已被拒绝，请在系统设置中开启',
      );
      return false;
    }

    if (_currentPlatform == TargetPlatform.iOS) {
      final speechStatus = await _permissionClient.requestSpeechRecognition();
      if (!mounted) {
        return false;
      }
      if (!_isPermissionGranted(speechStatus)) {
        _setPermissionError(
          speechStatus,
          deniedMessage: '需要语音识别权限才能使用语音搜索',
          permanentlyDeniedMessage: '语音识别权限已被拒绝，请在系统设置中开启',
        );
        return false;
      }
    }

    return true;
  }

  bool _isPermissionGranted(PermissionStatus status) {
    if (status.isGranted || status.isLimited) {
      return true;
    }
    return false;
  }

  void _setPermissionError(
    PermissionStatus status, {
    required String deniedMessage,
    required String permanentlyDeniedMessage,
  }) {
    final isSettingsRecoverable =
        status.isPermanentlyDenied || status.isRestricted;
    state = state.copyWith(
      status: VoiceSearchStatus.error,
      errorMessage: isSettingsRecoverable
          ? permanentlyDeniedMessage
          : deniedMessage,
      permissionPermanentlyDenied: isSettingsRecoverable,
    );
  }

  Future<String?> _resolveZhLocaleId() async {
    try {
      final locales = await _speechClient.locales();
      const preferred = ['zh_CN', 'zh-Hans-CN', 'zh_Hans_CN', 'zh-CN'];
      for (final tag in preferred) {
        final hit = locales.firstWhere(
          (locale) =>
              locale.localeId.toLowerCase() == tag.toLowerCase() ||
              locale.localeId.replaceAll('-', '_').toLowerCase() ==
                  tag.replaceAll('-', '_').toLowerCase(),
          orElse: () => _emptyLocale,
        );
        if (identical(hit, _emptyLocale)) {
          continue;
        }
        return hit.localeId;
      }
      final anyZh = locales.firstWhere(
        (locale) => locale.localeId.toLowerCase().startsWith('zh'),
        orElse: () => _emptyLocale,
      );
      if (!identical(anyZh, _emptyLocale)) {
        return anyZh.localeId;
      }
      final system = await _speechClient.systemLocale();
      return system?.localeId;
    } catch (_) {
      return null;
    }
  }

  void _onResult(SpeechRecognitionResult result) {
    if (!mounted) {
      return;
    }
    final text = result.recognizedWords;
    if (result.finalResult) {
      state = state.copyWith(
        status: VoiceSearchStatus.done,
        finalText: text,
        partialText: text,
      );
    } else {
      state = state.copyWith(
        status: VoiceSearchStatus.listening,
        partialText: text,
      );
    }
  }

  void _onSoundLevel(double level) {
    if (!mounted) {
      return;
    }
    state = state.copyWith(soundLevel: level);
  }

  void _onError(SpeechRecognitionError error) {
    if (!mounted) {
      return;
    }
    final message = _mapErrorMessage(error.errorMsg);
    state = state.copyWith(
      status: VoiceSearchStatus.error,
      errorMessage: message,
      permissionPermanentlyDenied: false,
    );
  }

  void _onStatus(String status) {
    if (!mounted) {
      return;
    }
    // 当 speech 自然结束（pauseFor 触发或 stop 完成）会回调 'notListening' / 'done'。
    // 若我们仍处于 listening 而没有任何文本，标记成可重试错误；
    // 若已经有文本但还没收到 final result，过渡为 processing。
    if (status == 'notListening' || status == 'done') {
      if (state.status == VoiceSearchStatus.listening) {
        if (state.partialText.trim().isEmpty &&
            state.finalText.trim().isEmpty) {
          state = state.copyWith(
            status: VoiceSearchStatus.error,
            errorMessage: '未识别到语音，请靠近麦克风重试',
          );
        } else {
          state = state.copyWith(status: VoiceSearchStatus.processing);
        }
      }
    }
  }

  static String _mapErrorMessage(String code) {
    switch (code) {
      case 'error_no_match':
      case 'error_speech_timeout':
      case 'error_no_speech':
        return '未识别到语音，请重试';
      case 'error_network':
      case 'error_network_timeout':
        return '网络异常，无法完成在线识别';
      case 'error_audio':
      case 'error_audio_error':
        return '麦克风无法正常采集，请检查设备';
      case 'error_busy':
        return '识别引擎繁忙，请稍后再试';
      case 'error_permission':
        return '需要麦克风权限才能使用语音搜索';
      case 'error_language_not_supported':
      case 'error_language_unavailable':
        return '当前设备暂不支持中文语音识别';
      default:
        return code.trim().isEmpty ? '语音识别失败' : '语音识别失败（$code）';
    }
  }
}

/// 用作 firstWhere 的哨兵，避免抛异常。
final LocaleName _emptyLocale = LocaleName('', '');

final voiceSearchControllerProvider =
    StateNotifierProvider.autoDispose<VoiceSearchController, VoiceSearchState>(
      (ref) => VoiceSearchController(),
    );
