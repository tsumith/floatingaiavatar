import 'package:flutter_tts/flutter_tts.dart';

/// ------------------------------------------------------------
/// Text-To-Speech Service
/// Singleton wrapper around FlutterTts
/// ------------------------------------------------------------
class TTSService {
  TTSService._();
  static final TTSService instance = TTSService._();

  final FlutterTts _tts = FlutterTts();
  bool _isInitialized = false;

  /// Default TTS configuration values
  static const String _defaultLanguage = 'en-US';
  static const double _defaultPitch = 0.5;
  static const double _defaultSpeechRate = 0.4;
  static const double _defaultVolume = 1.0;

  /// Ensures the TTS engine is configured once per app lifecycle
  Future<void> _initialize() async {
    if (_isInitialized) return;

    await _tts.setLanguage(_defaultLanguage);
    await _tts.setPitch(_defaultPitch);
    await _tts.setSpeechRate(_defaultSpeechRate);
    await _tts.setVolume(_defaultVolume);
    await _tts.awaitSpeakCompletion(true);

    _isInitialized = true;
  }

  /// Speaks the provided text, interrupting any active speech
  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;

    await _initialize();
    await _tts.stop();
    await _tts.speak(text);
  }

  /// Stops any active speech
  Future<void> stop() async {
    await _tts.stop();
  }
}
