import 'package:alter_ego/ego_conflict.dart';
import 'package:alter_ego/models/identity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Speaks council voices with the phone's built-in text-to-speech.
/// Fully offline: nothing is sent anywhere. Each identity gets its own
/// pitch and pace so the voices feel distinct.
class WhisperEngine {
  static final FlutterTts _tts = FlutterTts();
  static bool _ready = false;
  static bool _stopped = false;

  static const _voiceShape = <IdentityId, (double pitch, double rate)>{
    IdentityId.strategist: (0.95, 0.47),
    IdentityId.rebel: (1.05, 0.55),
    IdentityId.caretaker: (1.15, 0.44),
    IdentityId.achiever: (1.0, 0.56),
    IdentityId.romantic: (1.2, 0.42),
    IdentityId.protector: (0.8, 0.45),
    IdentityId.analyst: (0.9, 0.5),
    IdentityId.escapist: (1.1, 0.4),
    IdentityId.shadow: (0.6, 0.38),
  };

  static bool get isConfigured => true;

  static Future<void> _init() async {
    if (_ready) return;
    try {
      await _tts.awaitSpeakCompletion(true);
      await _tts.setSharedInstance(true);
      await _tts.setLanguage('en-US');
      await _tts.setVolume(1.0);
    } catch (e) {
      debugPrint('TTS init: $e');
    }
    _ready = true;
  }

  static Future<void> preloadConflicts(List<EgoConflict> conflicts) => _init();

  static Future<void> speakConflicts(List<EgoConflict> conflicts) async {
    await _init();
    _stopped = false;
    for (final conflict in conflicts) {
      if (_stopped) break;
      try {
        final shape = _voiceShape[conflict.identity] ?? (1.0, 0.48);
        await _tts.setPitch(shape.$1);
        await _tts.setSpeechRate(shape.$2);
        await _tts.speak(conflict.message);
        await Future.delayed(const Duration(milliseconds: 600));
      } catch (e) {
        debugPrint('TTS speak: $e');
      }
    }
  }

  static Future<void> stop() async {
    _stopped = true;
    try {
      await _tts.stop();
    } catch (_) {}
  }
}
