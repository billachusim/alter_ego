import 'dart:convert';

import 'package:alter_ego/alter_ego.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalDataStore {
  static final LocalDataStore instance = LocalDataStore._();
  LocalDataStore._();

  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    final root = await getDatabasesPath();
    _db = await openDatabase(
      join(root, 'alter_ego.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('CREATE TABLE ego_state(name TEXT PRIMARY KEY, payload TEXT NOT NULL)');
        await db.execute('CREATE TABLE snapshots(id INTEGER PRIMARY KEY AUTOINCREMENT, created_at TEXT NOT NULL, payload TEXT NOT NULL, grain TEXT NOT NULL)');
        await db.execute('CREATE TABLE events(id INTEGER PRIMARY KEY AUTOINCREMENT, created_at TEXT NOT NULL, type TEXT NOT NULL, payload TEXT NOT NULL)');
      },
    );
    return _db!;
  }

  Future<void> saveCurrentEgos(List<AlterEgo> egos) async {
    final dbClient = await db;
    final batch = dbClient.batch();
    batch.delete('ego_state');
    for (final ego in egos) {
      batch.insert('ego_state', {'name': ego.name, 'payload': jsonEncode(ego.toJson())});
    }
    await batch.commit(noResult: true);
  }

  Future<List<AlterEgo>> loadCurrentEgos() async {
    final dbClient = await db;
    final rows = await dbClient.query('ego_state');
    return rows
        .map((r) => AlterEgo.fromJson(jsonDecode(r['payload']! as String)))
        .toList();
  }

  Future<void> appendSnapshot(List<AlterEgo> egos, {String grain = 'daily'}) async {
    final dbClient = await db;
    await dbClient.insert('snapshots', {
      'created_at': DateTime.now().toIso8601String(),
      'payload': jsonEncode(egos.map((e) => e.toJson()).toList()),
      'grain': grain,
    });
  }

  Future<List<Map<String, Object?>>> loadSnapshots({int limit = 300}) async {
    final dbClient = await db;
    return dbClient.query('snapshots', orderBy: 'id ASC', limit: limit);
  }

  Future<void> pruneAndRollupSnapshots() async {
    final dbClient = await db;
    final all = await dbClient.query('snapshots', orderBy: 'id ASC');
    if (all.length <= 90) return;

    final stale = all.take(all.length - 90).toList();
    final grouped = <String, List<Map<String, Object?>>>{};
    for (final row in stale) {
      final ts = DateTime.parse(row['created_at']! as String);
      final key = '${ts.year}-${ts.month ~/ 1}';
      grouped.putIfAbsent(key, () => []).add(row);
    }

    for (final rows in grouped.values) {
      if (rows.isEmpty) continue;
      final payload = rows.last['payload']!;
      await dbClient.insert('snapshots', {
        'created_at': DateTime.now().toIso8601String(),
        'payload': payload,
        'grain': 'monthly',
      });
      final ids = rows.map((r) => r['id']).join(',');
      await dbClient.delete('snapshots', where: 'id IN ($ids)');
    }
  }

  Future<void> appendEvent(String type, Map<String, dynamic> payload) async {
    final dbClient = await db;
    await dbClient.insert('events', {
      'created_at': DateTime.now().toIso8601String(),
      'type': type,
      'payload': jsonEncode(payload),
    });
  }
}
