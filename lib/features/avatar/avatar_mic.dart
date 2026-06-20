import 'dart:async';

import 'package:record/record.dart';
import 'package:vad/vad.dart';

/// ------------------------------------------------------------
/// Avatar Microphone
/// Handles audio capture and voice activity detection
/// ------------------------------------------------------------
class AvatarMic {
  AvatarMic({required this.onStartedTalking, required this.onStoppedTalking}) {
    _vad = VadHandler.create(isDebug: false);
  }

  final AudioRecorder _recorder = AudioRecorder();
  late final VadHandler _vad;

  final VoidCallback onStartedTalking;
  final void Function(List<double> audioSamples) onStoppedTalking;

  StreamSubscription<void>? _speechStartSubscription;
  StreamSubscription<List<double>>? _speechEndSubscription;

  static const int _sampleRate = 16000;
  static const int _channels = 1;

  /// ------------------------------------------------------------
  /// Start listening to microphone input
  /// ------------------------------------------------------------
  Future<void> start() async {
    await stop();

    _speechStartSubscription = _vad.onSpeechStart.listen(
      (_) => onStartedTalking(),
    );

    _speechEndSubscription = _vad.onSpeechEnd.listen(
      (audioSamples) => onStoppedTalking(audioSamples),
    );

    final micStream = await _recorder.startStream(
      const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: _sampleRate,
        numChannels: _channels,
      ),
    );

    await _vad.startListening(audioStream: micStream);
  }

  /// ------------------------------------------------------------
  /// Stop listening and release resources
  /// ------------------------------------------------------------
  Future<void> stop() async {
    await _speechStartSubscription?.cancel();
    _speechStartSubscription = null;

    await _speechEndSubscription?.cancel();
    _speechEndSubscription = null;

    await _vad.stopListening();
    await _recorder.stop();
  }
}
