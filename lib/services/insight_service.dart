import 'package:alter_ego/alter_ego.dart';
import 'package:alter_ego/alter_ego_service.dart';
import 'package:alter_ego/models/identity.dart';

class InsightService {
  final AlterEgoService _service = AlterEgoService();

  Future<String?> getPatternHint(IdentityId currentIdentity) async {
    final history = await _service.loadHistory();
    if (history.length < 2) return null;

    final lastFew = history.reversed.take(5).toList();
    
    // Pattern 1: Sustained Dominance
    int count = 0;
    for (var snap in lastFew) {
      if (snap.egos.isEmpty) continue;
      final dominant = _getDominant(snap.egos);
      if (identityIdFromAny(dominant.name) == currentIdentity) {
        count++;
      }
    }
    
    if (count >= 3) {
      return "Your ${identityStorageLabel(currentIdentity)} has been consistently leading for several check-ins. It's a strong pattern.";
    }

    // Pattern 2: Recent Shift
    if (lastFew.length >= 2) {
      final latestDominant = _getDominant(lastFew[0].egos);
      final prevDominant = _getDominant(lastFew[1].egos);
      
      if (identityIdFromAny(latestDominant.name) == currentIdentity && 
          identityIdFromAny(prevDominant.name) != currentIdentity) {
        return "I'm seeing a shift. Your ${identityStorageLabel(currentIdentity)} is stepping up today, moving past your usual leanings.";
      }
    }

    // Pattern 3: Growing Tension (if current is high but not yet dominant)
    final latest = lastFew.first;
    final currentEgo = latest.egos.firstWhere(
      (e) => identityIdFromAny(e.name) == currentIdentity,
      orElse: () => AlterEgo(name: '', description: '', icon: '', leaning: 0),
    );
    
    if (currentEgo.leaning > 0.4 && _getDominant(latest.egos) != currentEgo) {
      return "Your ${identityStorageLabel(currentIdentity)} is gathering strength, even if it's not fully in charge yet.";
    }

    return null;
  }

  AlterEgo _getDominant(List<AlterEgo> egos) {
    if (egos.isEmpty) return AlterEgo(name: 'None', description: '', icon: '', leaning: 0);
    return egos.reduce((a, b) => a.leaning > b.leaning ? a : b);
  }
}
