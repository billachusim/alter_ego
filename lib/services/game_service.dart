import 'package:shared_preferences/shared_preferences.dart';

class Rank {
  final String title;
  final String glyph;
  final int minXp;
  const Rank(this.title, this.glyph, this.minXp);
}

class GameState {
  final int xp;
  final int streak;
  final int bestStreak;
  final bool omenRevealedToday;
  final bool checkedInToday;

  const GameState({
    required this.xp,
    required this.streak,
    required this.bestStreak,
    required this.omenRevealedToday,
    required this.checkedInToday,
  });

  Rank get rank => GameService.rankFor(xp);
  Rank? get nextRank => GameService.nextRankFor(xp);

  /// Progress (0..1) from the current rank to the next.
  double get progress {
    final next = nextRank;
    if (next == null) return 1;
    return ((xp - rank.minXp) / (next.minXp - rank.minXp)).clamp(0.0, 1.0);
  }
}

class Reward {
  final int xpGained;
  final int streak;
  final Rank? rankUp;
  final bool streakGrew;
  const Reward({required this.xpGained, required this.streak, this.rankUp, this.streakGrew = false});
}

/// Streaks, energy (XP) and ranks. Stored only on the phone.
class GameService {
  GameService._();
  static final GameService instance = GameService._();

  static const ranks = [
    Rank('Initiate', '☽', 0),
    Rank('Seeker', '✧', 150),
    Rank('Wanderer', '☿', 400),
    Rank('Adept', '✶', 800),
    Rank('Mystic', '☯', 1400),
    Rank('Seer', '◉', 2200),
    Rank('Oracle', '✺', 3300),
    Rank('Ascended', '❂', 5000),
  ];

  static const checkInXp = 60;
  static const councilXp = 25;
  static const omenXp = 15;
  static const streakBonusPerDay = 10; // capped below

  static const _xpKey = 'game_xp';
  static const _streakKey = 'game_streak';
  static const _bestKey = 'game_best_streak';
  static const _lastCheckInKey = 'game_last_checkin_day';
  static const _omenDayKey = 'game_omen_day';

  static Rank rankFor(int xp) => ranks.lastWhere((r) => xp >= r.minXp);
  static Rank? nextRankFor(int xp) {
    for (final r in ranks) {
      if (r.minXp > xp) return r;
    }
    return null;
  }

  static String _day(DateTime d) => '${d.year}-${d.month}-${d.day}';

  Future<GameState> load() async {
    final p = await SharedPreferences.getInstance();
    final today = _day(DateTime.now());
    final yesterday = _day(DateTime.now().subtract(const Duration(days: 1)));
    final last = p.getString(_lastCheckInKey);
    var streak = p.getInt(_streakKey) ?? 0;
    // A missed day breaks the streak.
    if (last != null && last != today && last != yesterday) streak = 0;
    return GameState(
      xp: p.getInt(_xpKey) ?? 0,
      streak: streak,
      bestStreak: p.getInt(_bestKey) ?? 0,
      omenRevealedToday: p.getString(_omenDayKey) == today,
      checkedInToday: last == today,
    );
  }

  Future<Reward> _addXp(int amount, {int streak = 0, bool streakGrew = false}) async {
    final p = await SharedPreferences.getInstance();
    final before = p.getInt(_xpKey) ?? 0;
    final after = before + amount;
    await p.setInt(_xpKey, after);
    final oldRank = rankFor(before);
    final newRank = rankFor(after);
    return Reward(
      xpGained: amount,
      streak: streak,
      streakGrew: streakGrew,
      rankUp: newRank.minXp > oldRank.minXp ? newRank : null,
    );
  }

  Future<Reward> recordCheckIn() async {
    final p = await SharedPreferences.getInstance();
    final today = _day(DateTime.now());
    final yesterday = _day(DateTime.now().subtract(const Duration(days: 1)));
    final last = p.getString(_lastCheckInKey);
    var streak = p.getInt(_streakKey) ?? 0;
    var grew = false;
    if (last == today) {
      // Second check-in today: smaller reward, streak unchanged.
      return _addXp(checkInXp ~/ 3, streak: streak);
    }
    streak = (last == yesterday) ? streak + 1 : 1;
    grew = true;
    await p.setInt(_streakKey, streak);
    await p.setString(_lastCheckInKey, today);
    final best = p.getInt(_bestKey) ?? 0;
    if (streak > best) await p.setInt(_bestKey, streak);
    final bonus = (streak - 1).clamp(0, 7) * streakBonusPerDay;
    return _addXp(checkInXp + bonus, streak: streak, streakGrew: grew);
  }

  Future<Reward> recordCouncil() async {
    final s = await load();
    return _addXp(councilXp, streak: s.streak);
  }

  Future<Reward?> revealOmen() async {
    final p = await SharedPreferences.getInstance();
    final today = _day(DateTime.now());
    if (p.getString(_omenDayKey) == today) return null;
    await p.setString(_omenDayKey, today);
    final s = await load();
    return _addXp(omenXp, streak: s.streak);
  }
}
