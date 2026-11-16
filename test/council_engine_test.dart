// ignore_for_file: avoid_print
import 'package:alter_ego/council/council_engine.dart';
import 'package:alter_ego/council/council_themes.dart';
import 'package:alter_ego/council/council_voices.dart';
import 'package:alter_ego/models/identity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every identity has lines for every ask mode and theme group', () {
    for (final id in IdentityId.values) {
      for (final m in AskMode.values) {
        expect(VoiceLibrary.openers[id]![m], isNotEmpty, reason: '$id $m');
      }
      for (final g in ThemeGroup.values) {
        expect(VoiceLibrary.lenses[id]![g], isNotEmpty, reason: '$id $g');
      }
      expect(VoiceLibrary.steps[id], isNotEmpty);
    }
  });

  test('council replies reflect the situation and differ between questions', () {
    final a = CouncilEngine.consult('Should I quit my job to start a business?', nickname: 'Bill');
    final b = CouncilEngine.consult('My sister keeps borrowing money and never pays back');
    final c = CouncilEngine.consult('Why do I feel stuck?', leanings: {IdentityId.romantic: .9});
    final d = CouncilEngine.consult('I feel so anxious about my exams next week');
    for (final r in [a, b, c, d]) {
      print('--- themes ${r.themes}');
      for (final v in r.voices) {
        print('[${v.identity.name}] ${v.message}');
      }
      print('VERDICT: ${r.verdict.tension} -> ${r.verdict.nextStep} | ${r.verdict.truth}');
    }
    expect(a.voices.length, 4);
    expect(a.voices.first.message, contains('quit my job'));
    expect(a.themes, contains('business'));
    expect(b.themes, containsAll(['money', 'family']));
    expect(d.themes, containsAll(['anxiety', 'study']));
    expect(c.voices.map((v) => v.identity), contains(IdentityId.romantic));
    expect(a.voices.map((v) => v.identity).toSet().length, 4);
  });

  test('asking again gives different wording', () {
    final first = CouncilEngine.consult('Should I move abroad?', salt: 1);
    final second = CouncilEngine.consult('Should I move abroad?', salt: 2);
    expect(first.voices.map((v) => v.message).join() == second.voices.map((v) => v.message).join(), isFalse);
  });

  test('crisis language gets a safety-first reply', () {
    final r = CouncilEngine.consult('I want to end my life');
    expect(r.verdict.isCrisis, isTrue);
    expect(r.voices.first.message, contains('crisis line'));
  });
}
