import 'package:alter_ego/services/game_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('check-in starts a streak, gives energy, second check-in gives less', () async {
    SharedPreferences.setMockInitialValues({});
    final g = GameService.instance;
    final r1 = await g.recordCheckIn();
    expect(r1.streak, 1);
    expect(r1.xpGained, GameService.checkInXp);
    final r2 = await g.recordCheckIn();
    expect(r2.xpGained, lessThan(r1.xpGained));
    final s = await g.load();
    expect(s.checkedInToday, isTrue);
    expect(s.xp, r1.xpGained + r2.xpGained);
  });

  test('yesterday check-in grows the streak; rank up is reported', () async {
    final now = DateTime.now().subtract(const Duration(days: 1));
    SharedPreferences.setMockInitialValues({
      'game_last_checkin_day': '${now.year}-${now.month}-${now.day}',
      'game_streak': 3,
      'game_xp': 140,
    });
    final r = await GameService.instance.recordCheckIn();
    expect(r.streak, 4);
    expect(r.rankUp?.title, 'Seeker');
  });

  test('omen can be revealed once per day', () async {
    SharedPreferences.setMockInitialValues({});
    expect(await GameService.instance.revealOmen(), isNotNull);
    expect(await GameService.instance.revealOmen(), isNull);
  });
}
