import 'dart:convert';
import 'dart:io';

import 'package:alter_ego/ego_conflict.dart';
import 'package:alter_ego/ego_voice_mapper.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

class WhisperEngine {
  static final AudioPlayer _player = AudioPlayer();
  static const _apiKey = 'sk_880113cb0d15aea312593d7877257dfed34a37fc490af742';

  static bool get isConfigured => _apiKey.isNotEmpty;

  static Future<void> speakConflicts(List<EgoConflict> conflicts) async {
    if (!isConfigured) return;
    try {
      for (final conflict in conflicts) {
        final file = await _getOrCreateAudio(conflict);
        await _player.setFilePath(file.path);
        // Play and wait for it to finish
        await _player.play();
        // A short pause between different identities
        await Future.delayed(const Duration(milliseconds: 3500));
      }
    } catch (e) {
      debugPrint("WhisperEngine Error: $e");
    }
  }

  static Future<void> preloadConflicts(List<EgoConflict> conflicts) async {
    if (!isConfigured) return;
    for (final conflict in conflicts) {
      try {
        await _getOrCreateAudio(conflict);
        // Throttle preloads slightly
        await Future.delayed(const Duration(milliseconds: 800));
      } catch (e) {
        debugPrint("Preload Error: $e");
      }
    }
  }

  static Future<File> _getOrCreateAudio(EgoConflict conflict) async {
    final dir = await getApplicationDocumentsDirectory();
    final hash = md5.convert(utf8.encode('${conflict.identity.name}${conflict.message}')).toString();
    final file = File("${dir.path}/$hash.mp3");
    if (await file.exists()) return file;

    final bytes = await _downloadVoice(conflict);
    await file.writeAsBytes(bytes);
    return file;
  }

  static Future<List<int>> _downloadVoice(EgoConflict conflict) async {
    final voiceId = EgoVoiceMapper.voiceId(conflict.identity);
    final response = await http.post(
      Uri.parse('https://api.elevenlabs.io/v1/text-to-speech/$voiceId'),
      headers: {
        'xi-api-key': _apiKey,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'text': conflict.message,
        'voice_settings': {
          'stability': 0.4,
          'similarity_boost': 0.8,
          'style': 0.5,
          'use_speaker_boost': true,
        }
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Voice generation failed: ${response.statusCode}');
    }
    return response.bodyBytes;
  }
}
