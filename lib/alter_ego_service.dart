import 'dart:convert';
import 'package:alter_ego/alter_ego.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlterEgoSnapshot {
  final DateTime timestamp;
  final List<AlterEgo> egos;

  AlterEgoSnapshot({required this.timestamp, required this.egos});

  // Serialization methods
  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'egos': egos.map((e) => e.toJson()).toList(),
      };

  factory AlterEgoSnapshot.fromJson(Map<String, dynamic> json) => AlterEgoSnapshot(
        timestamp: DateTime.parse(json['timestamp']),
        egos: (json['egos'] as List).map((e) => AlterEgo.fromJson(e)).toList(),
      );
}

class AlterEgoService {
  static const _key = 'alter_egos';
  static const _historyKey = 'alter_ego_history';

  Future<void> saveAlterEgos(List<AlterEgo> egos) async {
    final prefs = await SharedPreferences.getInstance();
    final egoList = egos.map((ego) => jsonEncode(ego.toJson())).toList();
    await prefs.setStringList(_key, egoList);
    await _saveHistoricalSnapshot(egos); // Also save a snapshot
  }

  Future<List<AlterEgo>> loadAlterEgos() async {
    final prefs = await SharedPreferences.getInstance();
    final egoList = prefs.getStringList(_key);
    if (egoList == null) {
      return [];
    }
    return egoList.map((egoString) {
      final egoMap = jsonDecode(egoString);
      return AlterEgo.fromJson(egoMap);
    }).toList();
  }

  Future<void> _saveHistoricalSnapshot(List<AlterEgo> egos) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await loadHistory();
    history.add(AlterEgoSnapshot(timestamp: DateTime.now(), egos: egos));

    // Keep history to a reasonable size, e.g., last 30 entries
    if (history.length > 30) {
      history.removeRange(0, history.length - 30);
    }

    final historyList = history.map((snapshot) => jsonEncode(snapshot.toJson())).toList();
    await prefs.setStringList(_historyKey, historyList);
  }

  Future<List<AlterEgoSnapshot>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyList = prefs.getStringList(_historyKey);
    if (historyList == null) {
      return [];
    }
    return historyList.map((snapshotString) {
      final snapshotMap = jsonDecode(snapshotString);
      return AlterEgoSnapshot.fromJson(snapshotMap);
    }).toList();
  }
}

// Add serialization to AlterEgo model
extension on AlterEgo {
  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'icon': icon,
        'leaning': leaning,
      };

  static AlterEgo fromJson(Map<String, dynamic> json) => AlterEgo(
        name: json['name'],
        description: json['description'],
        icon: json['icon'],
        leaning: json['leaning'],
      );
}
