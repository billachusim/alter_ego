import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsService {
  static const _onboardedKey = 'hasOnboarded';
  static const _nicknameKey = 'nickname';
  static const _recentQuestionIds = 'recentQuestionIds';
  static const _firstLaunchKey = 'firstLaunchDate';
  static const _checkInCountKey = 'checkInCount';
  static const _hasWatchedReplayKey = 'hasWatchedReplay';
  static const _notificationEnabledKey = 'notificationEnabled';
  static const _notificationHourKey = 'notificationHour';

  Future<bool> hasOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardedKey) ?? false;
  }

  Future<void> setOnboarded(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardedKey, value);
  }

  Future<String?> nickname() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nicknameKey);
  }

  Future<void> setNickname(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nicknameKey, value);
  }

  Future<Set<String>> recentQuestionIds() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_recentQuestionIds) ?? []).toSet();
  }

  Future<void> rememberQuestionIds(List<String> ids, {int keep = 120}) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_recentQuestionIds) ?? [];
    final merged = {...existing, ...ids}.toList();
    if (merged.length > keep) {
      merged.removeRange(0, merged.length - keep);
    }
    await prefs.setStringList(_recentQuestionIds, merged);
  }

  Future<DateTime?> firstLaunchDate() async {
    final prefs = await SharedPreferences.getInstance();
    final iso = prefs.getString(_firstLaunchKey);
    return iso != null ? DateTime.parse(iso) : null;
  }

  Future<void> setFirstLaunchDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_firstLaunchKey, date.toIso8601String());
  }

  Future<int> checkInCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_checkInCountKey) ?? 0;
  }

  Future<void> incrementCheckInCount() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_checkInCountKey) ?? 0;
    await prefs.setInt(_checkInCountKey, current + 1);
  }

  Future<bool> hasWatchedReplay() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasWatchedReplayKey) ?? false;
  }

  Future<void> setHasWatchedReplay(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasWatchedReplayKey, value);
  }

  Future<bool> notificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationEnabledKey) ?? true;
  }

  Future<void> setNotificationsEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationEnabledKey, value);
  }

  Future<int> notificationHour() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_notificationHourKey) ?? 20; // Default 8 PM
  }

  Future<void> setNotificationHour(int hour) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_notificationHourKey, hour);
  }
}
