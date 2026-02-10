import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';

import 'ego_voice_mapper.dart';
import 'secrets.dart';

class WhisperEngine {

  static final AudioPlayer _player = AudioPlayer();

  ////////////////////////////////////////////////////////

  /// PUBLIC — call this after simulation
  static Future<void> speakConflicts(
      List<Map<String, String>> conflicts) async {

    for (final conflict in conflicts) {

      final ego = conflict['ego']!;
      final message = conflict['message']!;

      final file = await _getOrCreateAudio(ego, message);

      await _player.setFilePath(file.path);

      await _player.play();

      /// tiny silence between voices
      await Future.delayed(const Duration(milliseconds: 450));
    }
  }

  static Future<void> preloadConflicts(
      List<Map<String, String>> conflicts) async {

    // Run downloads in parallel (VERY important)
    await Future.wait(
      conflicts.map((conflict) =>
          _getOrCreateAudio(
            conflict['ego']!,
            conflict['message']!,
          ),
      ),
    );
  }


  ////////////////////////////////////////////////////////

  static Future<File> _getOrCreateAudio(
      String ego,
      String text,
      ) async {

    final dir = await getApplicationDocumentsDirectory();

    final hash = md5.convert(utf8.encode("$ego$text")).toString();

    final file = File("${dir.path}/$hash.mp3");

    if (await file.exists()) {
      return file;
    }

    final bytes = await _downloadVoice(ego, text);

    await file.writeAsBytes(bytes);

    return file;
  }

  ////////////////////////////////////////////////////////

  static Future<List<int>> _downloadVoice(
      String ego,
      String text,
      ) async {

    final voiceId = EgoVoiceMapper.voiceId(ego);

    final url =
        "https://api.elevenlabs.io/v1/text-to-speech/$voiceId";

    final response = await http.post(
      Uri.parse(url),
      headers: {
        "xi-api-key": elevenLabsApiKey,
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "text": text,

        /// whisper-style tuning
        "voice_settings": {
          "stability": 0.35,
          "similarity_boost": 0.75,
          "style": 0.6,
          "use_speaker_boost": true,
        }
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Voice generation failed");
    }

    return response.bodyBytes;
  }
}
