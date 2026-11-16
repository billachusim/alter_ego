import 'package:alter_ego/council/council_engine.dart';
import 'package:alter_ego/models/identity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('council replies reflect the situation and differ between questions', () {
    final a = CouncilEngine.consult('Should I quit my job to start a business?');
    final b = CouncilEngine.consult('My sister keeps borrowing money and never pays back');
    final c = CouncilEngine.consult('Why do I feel stuck?', leanings: {IdentityId.romantic: .9});
    for (final r in [a, b, c]) {
      print('--- themes ${r.themes}');
      for (final v in r.voices) {
        print('[${v.identity.name}] ${v.message}\n   (${v.rationale})');
      }
      print('VERDICT: ${r.verdict.tension}\n  -> ${r.verdict.nextStep}\n  ? ${r.verdict.reflection}');
    }
    expect(a.voices.length, 4);
    expect(a.voices.first.message, contains('quit my job'));
    expect(a.themes, containsAll(['work', 'risk']));
    expect(b.themes, containsAll(['money', 'family']));
    expect(a.voices.map((v) => v.message).toSet().intersection(b.voices.map((v) => v.message).toSet()), isEmpty);
    expect(c.voices.map((v) => v.identity), contains(IdentityId.romantic));
    expect(a.voices.map((v) => v.identity).toSet().length, 4);
  });
}
