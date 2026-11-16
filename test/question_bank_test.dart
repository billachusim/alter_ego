import 'package:alter_ego/content/offline_content_repository.dart';
import 'package:alter_ego/content/question_bank.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('bank is large, unique and well-formed', () {
    final bank = questionBank();
    expect(bank.length, greaterThan(80));
    expect(bank.map((q) => q.text).toSet().length, bank.length);
    for (final q in bank) {
      expect(q.answers.length, 4, reason: q.text);
      for (final a in q.answers) {
        expect(a.scores, isNotEmpty, reason: '${q.text} / ${a.text}');
      }
    }
  });

  test('daily pick has no repeats, includes a mystic one, and avoids recent ids', () {
    final day1 = OfflineContentRepository.selectDailyQuestions(day: DateTime(2026, 11, 16), excludedIds: {});
    expect(day1.length, 6);
    expect(day1.map((q) => q.text).toSet().length, 6);
    expect(day1.where((q) => q.category == 'mystic'), isNotEmpty);
    final day2 = OfflineContentRepository.selectDailyQuestions(day: DateTime(2026, 11, 17), excludedIds: day1.map((q) => q.id).toSet());
    expect(day2.map((q) => q.id).toSet().intersection(day1.map((q) => q.id).toSet()), isEmpty);
    final all = OfflineContentRepository.selectDailyQuestions(day: DateTime(2026, 11, 18), excludedIds: questionBank().map((q) => q.id).toSet());
    expect(all.length, 6);
  });
}
