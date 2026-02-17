import 'dart:convert';

import 'package:alter_ego/alter_ego.dart';
import 'package:alter_ego/models/identity.dart';
import 'package:alter_ego/services/local_data_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlterEgoSnapshot {
  final DateTime timestamp;
  final List<AlterEgo> egos;

  AlterEgoSnapshot({required this.timestamp, required this.egos});

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
  static const _legacyKey = 'alter_egos';
  static const _legacyHistoryKey = 'alter_ego_history';

  final LocalDataStore _store = LocalDataStore.instance;
  bool _migrationDone = false;

  Future<void> _ensureMigrated() async {
    if (_migrationDone) return;
    final prefs = await SharedPreferences.getInstance();

    final legacyEgos = prefs.getStringList(_legacyKey);
    if (legacyEgos != null && legacyEgos.isNotEmpty) {
      final parsed = legacyEgos
          .map((e) => AlterEgo.fromJson(jsonDecode(e)))
          .map(_normalizeName)
          .toList();
      await _store.saveCurrentEgos(parsed);
    }

    final legacyHistory = prefs.getStringList(_legacyHistoryKey);
    if (legacyHistory != null && legacyHistory.isNotEmpty) {
      for (final item in legacyHistory) {
        final snap = AlterEgoSnapshot.fromJson(jsonDecode(item));
        await _store.appendSnapshot(snap.egos.map(_normalizeName).toList());
      }
    }

    await prefs.remove(_legacyKey);
    await prefs.remove(_legacyHistoryKey);
    _migrationDone = true;
  }

  Future<void> saveAlterEgos(List<AlterEgo> egos) async {
    await _ensureMigrated();
    final normalized = egos.map(_normalizeName).toList();
    await _store.saveCurrentEgos(normalized);
    await _store.appendSnapshot(normalized);
    await _store.pruneAndRollupSnapshots();
    await _store.appendEvent('checkin', {'count': normalized.length});
  }

  Future<List<AlterEgo>> loadAlterEgos() async {
    await _ensureMigrated();
    return _store.loadCurrentEgos();
  }

  Future<List<AlterEgoSnapshot>> loadHistory() async {
    await _ensureMigrated();
    final rows = await _store.loadSnapshots();
    return rows.map((row) {
      final timestamp = DateTime.parse(row['created_at']! as String);
      final payload = jsonDecode(row['payload']! as String) as List<dynamic>;
      final egos = payload.map((e) => AlterEgo.fromJson(e)).toList();
      return AlterEgoSnapshot(timestamp: timestamp, egos: egos);
    }).toList();
  }

  AlterEgo _normalizeName(AlterEgo ego) {
    final id = identityIdFromAny(ego.name);
    if (id == null) return ego;
    return AlterEgo(
      name: identityStorageLabel(id),
      description: ego.description,
      icon: ego.icon,
      leaning: ego.leaning,
    );
  }
}
