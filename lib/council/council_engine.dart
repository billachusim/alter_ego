import 'dart:math';

import 'package:alter_ego/council/council_themes.dart';
import 'package:alter_ego/council/council_voices.dart';
import 'package:alter_ego/ego_conflict.dart';
import 'package:alter_ego/models/identity.dart';

/// The council's overall read on a situation.
class CouncilVerdict {
  final String tension;
  final String nextStep;
  final String reflection;
  final String? truth;
  final bool isCrisis;

  const CouncilVerdict({
    required this.tension,
    required this.nextStep,
    required this.reflection,
    this.truth,
    this.isCrisis = false,
  });
}

class CouncilResult {
  final List<EgoConflict> voices;
  final CouncilVerdict verdict;
  final List<String> themes;

  const CouncilResult({required this.voices, required this.verdict, required this.themes});
}

/// Offline Inner Council. Builds replies from the person's own words, the
/// themes in their situation, how they asked, and the voices that are
/// strongest in their identity map. Nothing leaves the phone.
class CouncilEngine {
  CouncilEngine._();

  static const _counterweight = {
    IdentityId.strategist: IdentityId.rebel,
    IdentityId.rebel: IdentityId.protector,
    IdentityId.caretaker: IdentityId.shadow,
    IdentityId.achiever: IdentityId.escapist,
    IdentityId.romantic: IdentityId.analyst,
    IdentityId.protector: IdentityId.rebel,
    IdentityId.analyst: IdentityId.romantic,
    IdentityId.escapist: IdentityId.achiever,
    IdentityId.shadow: IdentityId.caretaker,
  };

  static const _names = {
    IdentityId.strategist: 'Strategist',
    IdentityId.rebel: 'Rebel',
    IdentityId.caretaker: 'Caretaker',
    IdentityId.achiever: 'Achiever',
    IdentityId.romantic: 'Romantic',
    IdentityId.protector: 'Protector',
    IdentityId.analyst: 'Analyst',
    IdentityId.escapist: 'Escapist',
    IdentityId.shadow: 'Shadow',
  };

  static const _fallbackTheme = CouncilTheme('open', 'what is on your mind', ThemeGroup.meaning, [], {
    IdentityId.strategist: .8, IdentityId.analyst: .7, IdentityId.romantic: .6, IdentityId.shadow: .6,
  }, [
    'Naming what you feel is already half the work.',
    'The question you keep returning to is usually the important one.',
    'You know more than you think. Give yourself quiet to hear it.',
  ]);

  static String nameOf(IdentityId id) => _names[id]!;

  /// [situation] is what the person typed. [leanings] are their current
  /// identity strengths (0 to 1); they shape who speaks. [nickname] is used
  /// now and then so it feels personal. [salt] changes the wording when the
  /// same question is asked again.
  static CouncilResult consult(
    String situation, {
    Map<IdentityId, double> leanings = const {},
    String? nickname,
    int salt = 0,
  }) {
    final text = situation.trim();
    final lowered = ' ${text.toLowerCase().replaceAll('’', '\'')} ';
    final rng = Random(text.toLowerCase().hashCode ^ (salt * 7919));

    if (crisisWords.any(lowered.contains)) {
      return _crisis(text);
    }

    final scored = <(CouncilTheme, int)>[];
    for (final t in councilThemes) {
      final hits = t.words.where((w) => _containsWord(lowered, w)).length;
      if (hits > 0) scored.add((t, hits));
    }
    scored.sort((a, b) => b.$2.compareTo(a.$2));
    final themes = scored.isEmpty ? [_fallbackTheme] : scored.map((e) => e.$1).take(3).toList();
    final mode = _askMode(lowered);

    // Score every voice by theme fit plus the person's own leanings.
    final scores = <IdentityId, double>{for (final id in IdentityId.values) id: rng.nextDouble() * .2};
    for (final (i, t) in themes.indexed) {
      final weight = i == 0 ? 1.0 : .55;
      t.affinity.forEach((id, v) => scores[id] = scores[id]! + v * weight);
    }
    leanings.forEach((id, v) => scores[id] = scores[id]! + v * .9);

    final ranked = IdentityId.values.toList()..sort((a, b) => scores[b]!.compareTo(scores[a]!));
    final council = <IdentityId>[ranked[0], ranked[1]];
    final counter = _counterweight[ranked[0]]!;
    if (!council.contains(counter)) council.add(counter);
    for (final id in ranked) {
      if (council.length >= 4) break;
      if (!council.contains(id)) council.add(id);
    }

    final quote = _quote(text);
    final usedTruths = <String>{};
    final voices = <EgoConflict>[];
    for (final (i, id) in council.indexed) {
      final theme = themes[i % themes.length];
      final opener = _pick(VoiceLibrary.openers[id]![mode]!, rng).replaceAll('{q}', quote);
      final lens = _pick(VoiceLibrary.lenses[id]![theme.group]!, rng).replaceAll('{topic}', theme.topic);
      final step = _pick(VoiceLibrary.steps[id]!, rng);

      // Sometimes a voice carries a theme truth instead of its lens.
      String middle = lens;
      if (rng.nextDouble() < .35 && theme.truths.isNotEmpty) {
        final truth = _pick(theme.truths, rng);
        if (usedTruths.add(truth)) middle = truth;
      }
      final address = (nickname != null && nickname.isNotEmpty && i == 0 && rng.nextBool()) ? '$nickname, ' : '';
      final message = '$address${_lowerFirstIfAddressed(opener, address)} $middle $step';

      final reason = id == counter && i == 2
          ? 'The counterweight to your ${_names[council[0]]}.'
          : (leanings[id] ?? 0) > .5
              ? 'One of your strongest voices, reacting to ${theme.topic}.'
              : 'Drawn in by ${theme.topic}.';
      voices.add(EgoConflict(identity: id, message: message, rationale: reason));
    }

    final truthPool = themes.expand((t) => t.truths).where((t) => !usedTruths.contains(t)).toList();
    final verdict = CouncilVerdict(
      tension: 'Your ${_names[council[0]]} wants to ${VoiceLibrary.wants[council[0]]}, while your ${_names[council[1]]} wants to ${VoiceLibrary.wants[council[1]]}. '
          'Both are trying to help you with ${themes.first.topic}.',
      nextStep: _pick(VoiceLibrary.steps[council[0]]!, Random(rng.nextInt(1 << 30))).replaceFirst('Next step: ', ''),
      reflection: _pick(VoiceLibrary.reflections, rng),
      truth: truthPool.isEmpty ? null : _pick(truthPool, rng),
    );

    return CouncilResult(voices: voices, verdict: verdict, themes: themes.map((t) => t.id).toList());
  }

  static CouncilResult _crisis(String text) {
    const voices = [IdentityId.caretaker, IdentityId.protector];
    return CouncilResult(
      voices: [
        EgoConflict(identity: voices[0], message: VoiceLibrary.crisisReply, rationale: 'Your council is putting your safety first.'),
        EgoConflict(
          identity: voices[1],
          message: 'Right now the most important thing is that you are safe. If you are in danger, please call your local emergency number. If you can, stay near someone you trust tonight.',
          rationale: 'Your safety comes before anything else.',
        ),
      ],
      verdict: const CouncilVerdict(
        tension: 'Every part of you that is still reaching out wants you to be okay.',
        nextStep: 'Contact someone you trust, or a local crisis line, right now.',
        reflection: 'You matter, and this feeling can change with support.',
        isCrisis: true,
      ),
      themes: const ['crisis'],
    );
  }

  static AskMode _askMode(String lowered) {
    if (RegExp(r'\bwhy\b').hasMatch(lowered)) return AskMode.why;
    if (RegExp(r'\b(should i|shall i|is it better|or not|which one|whether)\b').hasMatch(lowered) || lowered.contains(' or ')) {
      return AskMode.decision;
    }
    if (RegExp(r'\b(how|what can i|what do i do|what should i do)\b').hasMatch(lowered)) return AskMode.how;
    if (RegExp(r"\b(i feel|i'm feeling|im feeling|i am feeling|feel so|feeling)\b").hasMatch(lowered)) return AskMode.feeling;
    return AskMode.statement;
  }

  static bool _containsWord(String lowered, String word) {
    if (word.contains(' ')) return lowered.contains(word);
    return RegExp('(^|[^a-z])${RegExp.escape(word)}(s|es|ed|ing)?([^a-z]|\$)').hasMatch(lowered);
  }

  static String _lowerFirstIfAddressed(String s, String address) {
    if (address.isEmpty || s.isEmpty || s.startsWith('"') || s.startsWith('I ') || s.startsWith('I\'')) return s;
    return s[0].toLowerCase() + s.substring(1);
  }

  static String _quote(String text) {
    var t = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    t = t.replaceAll(RegExp(r'[?.!]+$'), '');
    if (t.length <= 70) return t;
    final firstSentence = t.split(RegExp(r'(?<=[.!?])\s')).first;
    if (firstSentence.length <= 70) return firstSentence.replaceAll(RegExp(r'[?.!]+$'), '');
    final cut = t.substring(0, 67);
    final lastSpace = cut.lastIndexOf(' ');
    return '${cut.substring(0, lastSpace > 40 ? lastSpace : 67)}…';
  }

  static String _pick(List<String> list, Random rng) => list[rng.nextInt(list.length)];
}
