import 'dart:convert';
import 'package:alter_ego/alter_ego.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlterEgoService {
  static const _key = 'alter_egos';

  Future<void> saveAlterEgos(List<AlterEgo> egos) async {
    final prefs = await SharedPreferences.getInstance();
    final egoList = egos.map((ego) => jsonEncode({
      'name': ego.name,
      'description': ego.description,
      'icon': ego.icon,
      'leaning': ego.leaning,
    })).toList();
    await prefs.setStringList(_key, egoList);
  }

  Future<List<AlterEgo>> loadAlterEgos() async {
    final prefs = await SharedPreferences.getInstance();
    final egoList = prefs.getStringList(_key);
    if (egoList == null) {
      return [];
    }
    return egoList.map((egoString) {
      final egoMap = jsonDecode(egoString);
      return AlterEgo(
        name: egoMap['name'],
        description: egoMap['description'],
        icon: egoMap['icon'],
        leaning: egoMap['leaning'],
      );
    }).toList();
  }
}
