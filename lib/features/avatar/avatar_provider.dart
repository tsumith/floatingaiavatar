import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:pupz/api/voice_api.dart';
import 'package:pupz/api/voice_api_interface.dart';
import 'package:pupz/features/action_router/intent_router.dart';
import 'package:pupz/features/action_router/models/intent_response.dart';
import 'package:pupz/features/action_router/modules/overlay_module.dart';
import 'package:pupz/features/action_router/modules/timer_module.dart';
import 'package:pupz/features/action_router/modules/whatsapp_module.dart';
import 'package:pupz/features/avatar/avatar_mic.dart';
import 'package:pupz/features/tts/tts_service.dart';

import 'avatar_status.dart';

/// ------------------------------------------------------------
/// Avatar Provider
/// Controls microphone input, voice processing,
/// intent routing, and avatar state transitions
/// ------------------------------------------------------------
class AvatarProvider extends ChangeNotifier {
  final VoiceApiInterface _voiceApi = VoiceApi();
  final IntentRouter _intentRouter = IntentRouter();
  final TTSService _ttsService = TTSService.instance;

  late final AvatarMic _mic;

  AvatarStatus status = AvatarStatus.idle;
  String message = 'Tap to wake me up';

  Timer? _idleTimer;
  Timer? _maxSpeechTimer;

  AvatarProvider() {
    _registerIntentModules();
    _initializeMicrophone();
  }

  /// ------------------------------------------------------------
  /// Initialization
  /// ------------------------------------------------------------
  void _registerIntentModules() {
    _intentRouter
      ..registerModule(OverlayModule())
      ..registerModule(WhatsAppModule())
      ..registerModule(TimerModule());
  }

  void _initializeMicrophone() {
    _mic = AvatarMic(
      onStartedTalking: _onSpeechDetected,
      onStoppedTalking: _onSpeechEnded,
    );
  }

  /// ------------------------------------------------------------
  /// Microphone Callbacks
  /// ------------------------------------------------------------
  void _onSpeechDetected() {
    _cancelIdleTimer();

    if (status != AvatarStatus.hearing) {
      _updateState(AvatarStatus.hearing, 'Listening...');
    }

    _startMaxSpeechTimer();
  }

  Future<void> _onSpeechEnded(List<double> audioSamples) async {
    _clearAllTimers();
    await _mic.stop();

    _updateState(AvatarStatus.thinking, 'Processing...');
    await _processAudio(audioSamples);
  }

  /// ------------------------------------------------------------
  /// Public Actions
  /// ------------------------------------------------------------
  Future<void> toggleMic() async {
    _clearAllTimers();

    if (status == AvatarStatus.idle) {
      _updateState(AvatarStatus.listening, 'Listening...');
      try {
        await _mic.start();
        _startIdleTimer();
      } catch (_) {
        _updateState(AvatarStatus.error, 'Microphone unavailable');
      }
    } else {
      await _resetToIdle('Session ended');
    }
  }

  /// ------------------------------------------------------------
  /// Audio Processing Pipeline
  /// ------------------------------------------------------------
  Future<void> _processAudio(List<double> audioSamples) async {
    try {
      final Uint8List pcmBytes = _convertFloat32ToInt16(audioSamples);
      final responseJson = await _voiceApi.sendAudio(pcmBytes);
      final intent = IntentResponse.fromJson(responseJson);

      _updateState(AvatarStatus.speaking, intent.response);

      final speakTask = _ttsService.speak(intent.response);
      await _intentRouter.dispatch(intent);
      await speakTask;

      _updateState(AvatarStatus.idle, 'Tap to wake me up');
    } catch (_) {
      _updateState(AvatarStatus.error, 'Something went wrong');
      await Future.delayed(const Duration(seconds: 2));
      await _resetToIdle('Tap to wake me up');
    }
  }

  /// ------------------------------------------------------------
  /// Timers
  /// ------------------------------------------------------------
  void _startIdleTimer() {
    _idleTimer = Timer(
      const Duration(seconds: 5),
      () => _resetToIdle('Session timed out'),
    );
  }

  void _startMaxSpeechTimer() {
    _maxSpeechTimer ??= Timer(
      const Duration(seconds: 7),
      _handleSpeechOverflow,
    );
  }

  Future<void> _handleSpeechOverflow() async {
    await _mic.stop();
    _clearAllTimers();

    const message = 'Please keep responses under a few seconds';
    _updateState(AvatarStatus.speaking, message);
    await _ttsService.speak(message);

    _updateState(AvatarStatus.idle, 'Tap to wake me up');
  }

  /// ------------------------------------------------------------
  /// State Management
  /// ------------------------------------------------------------
  void _updateState(AvatarStatus newStatus, String newMessage) {
    status = newStatus;
    message = newMessage;
    notifyListeners();
  }

  Future<void> _resetToIdle(String message) async {
    _clearAllTimers();
    await _ttsService.stop();
    await _mic.stop();
    _updateState(AvatarStatus.idle, message);
  }

  void _cancelIdleTimer() {
    _idleTimer?.cancel();
    _idleTimer = null;
  }

  void _clearAllTimers() {
    _idleTimer?.cancel();
    _idleTimer = null;
    _maxSpeechTimer?.cancel();
    _maxSpeechTimer = null;
  }

  /// ------------------------------------------------------------
  /// Audio Utilities
  /// ------------------------------------------------------------
  Uint8List _convertFloat32ToInt16(List<double> samples) {
    final buffer = Int16List(samples.length);
    for (var i = 0; i < samples.length; i++) {
      final value = samples[i].clamp(-1.0, 1.0);
      buffer[i] = (value < 0 ? value * 32768 : value * 32767).toInt();
    }
    return Uint8List.view(buffer.buffer);
  }

  /// ------------------------------------------------------------
  /// Cleanup
  /// ------------------------------------------------------------
  @override
  void dispose() {
    _clearAllTimers();
    _ttsService.stop();
    _mic.stop();
    super.dispose();
  }
}
