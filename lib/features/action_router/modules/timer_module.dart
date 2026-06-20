import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/foundation.dart';

import '../feature_module.dart';

/// ------------------------------------------------------------
/// Timer Feature Module
/// Triggers system timer actions via platform intents
/// ------------------------------------------------------------
class TimerModule implements FeatureModule {
  @override
  String get moduleType => 'TIMER_ACTION';

  @override
  Future<bool> execute(Map<String, dynamic> payload) async {
    final String action = payload['action']?.toString() ?? 'start';
    final int? durationSeconds = payload['duration_seconds'];

    if (!Platform.isAndroid) {
      debugPrint('[TimerModule] Timer intents are Android-only');
      return false;
    }

    try {
      if (action == 'start' && durationSeconds != null) {
        return await _startTimer(durationSeconds);
      }

      return await _showTimers();
    } catch (error) {
      debugPrint('[TimerModule] Execution failed: $error');
      return false;
    }
  }

  /// ------------------------------------------------------------
  /// Timer Actions
  /// ------------------------------------------------------------
  Future<bool> _startTimer(int seconds) async {
    final intent = AndroidIntent(
      action: 'android.intent.action.SET_TIMER',
      arguments: <String, dynamic>{
        'android.intent.extra.alarm.LENGTH': seconds,
        'android.intent.extra.alarm.SKIP_UI': true,
        'android.intent.extra.alarm.MESSAGE': 'Floating Avatar Timer',
      },
    );

    await intent.launch();
    return true;
  }

  Future<bool> _showTimers() async {
    const intent = AndroidIntent(action: 'android.intent.action.SHOW_TIMERS');

    await intent.launch();
    return true;
  }
}
