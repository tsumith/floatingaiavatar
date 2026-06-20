import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:pupz/api/voice_api_interface.dart';
import 'package:pupz/core/network/dio_client.dart';

class VoiceApi extends VoiceApiInterface {
  final Dio _dio = HttpClient().instance;

  static const String _voiceEndpoint = '/voice';
  static const String _contentType = 'audio/wav';

  @override
  Future<Map<String, dynamic>> sendAudio(Uint8List pcm16Bytes) async {
    final wavBytes = _createWavBytes(pcm16Bytes);

    try {
      final response = await _dio.post(
        _voiceEndpoint,
        data: wavBytes,
        options: const Options(headers: {'Content-Type': _contentType}),
      );

      return (response.data as Map<String, dynamic>?) ?? <String, dynamic>{};
    } on DioException {
      throw Exception('Voice request failed');
    } catch (_) {
      throw Exception('Unexpected voice error');
    }
  }

  Uint8List _createWavBytes(Uint8List pcmBytes, {int sampleRate = 16000}) {
    const int channels = 1;
    const int bitsPerSample = 16;
    final int byteRate = sampleRate * channels * (bitsPerSample ~/ 8);

    final header = ByteData(44)
      ..setUint32(0, 0x46464952, Endian.little) // RIFF
      ..setUint32(4, 36 + pcmBytes.length, Endian.little)
      ..setUint32(8, 0x45564157, Endian.little) // WAVE
      ..setUint32(12, 0x20746D66, Endian.little) // fmt
      ..setUint32(16, 16, Endian.little)
      ..setUint16(20, 1, Endian.little)
      ..setUint16(22, channels, Endian.little)
      ..setUint32(24, sampleRate, Endian.little)
      ..setUint32(28, byteRate, Endian.little)
      ..setUint16(32, channels * (bitsPerSample ~/ 8), Endian.little)
      ..setUint16(34, bitsPerSample, Endian.little)
      ..setUint32(36, 0x61746164, Endian.little) // data
      ..setUint32(40, pcmBytes.length, Endian.little);

    return BytesBuilder()
      ..add(header.buffer.asUint8List())
      ..add(pcmBytes)
      ..toBytes();
  }
}
