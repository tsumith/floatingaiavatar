import 'dart:typed_data';

abstract class VoiceApiInterface {
  Future<Map<String, dynamic>> sendAudio(Uint8List pcm16Bytes);
}
