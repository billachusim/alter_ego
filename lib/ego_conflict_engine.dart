import 'package:alter_ego/content/offline_content_repository.dart';
import 'package:alter_ego/ego_conflict.dart';
import 'package:alter_ego/models/identity.dart';

class EgoConflictEngine {
  static const _tags = {
    'fear': ['fear', 'anxious', 'scared', 'panic', 'afraid', 'worry'],
    'authority': ['boss', 'manager', 'authority', 'rules', 'control', 'work'],
    'love': ['relationship', 'love', 'dating', 'partner', 'heart', 'ex'],
    'risk': ['risk', 'chance', 'gamble', 'quit', 'move', 'start'],
    'boundaries': ['boundary', 'no', 'drained', 'used', 'respect', 'limit'],
    'guilt': ['guilt', 'ashamed', 'regret', 'sorry', 'failed', 'mistake'],
    'growth': ['improve', 'learn', 'grow', 'better', 'future', 'goal'],
    'money': ['money', 'finance', 'cost', 'spend', 'budget', 'debt'],
  };

  static List<EgoConflict> generate(String situation) {
    final lowered = situation.toLowerCase();
    final matched = <String>[];

    _tags.forEach((tag, words) {
      if (words.any(lowered.contains)) {
        matched.add(tag);
      }
    });

    final tag = matched.isEmpty ? 'decision' : matched.first;
    final intensity = lowered.length > 100 ? 'high' : 'medium';

    final order = _identityOrderForTag(tag);
    return order.take(4).toList().asMap().entries.map((entry) {
      final identity = entry.value;
      return EgoConflict(
        identity: identity,
        message: OfflineContentRepository.pickReply(
          identity: identity,
          situationType: _situationForTag(tag),
          intensity: intensity,
          seed: lowered.hashCode + entry.key,
        ),
        rationale: 'Triggered by "$tag" language in your situation.',
      );
    }).toList();
  }

  static List<IdentityId> _identityOrderForTag(String tag) {
    return switch (tag) {
      'fear' => [IdentityId.shadow, IdentityId.protector, IdentityId.strategist, IdentityId.romantic],
      'authority' => [IdentityId.rebel, IdentityId.strategist, IdentityId.analyst, IdentityId.achiever],
      'love' => [IdentityId.romantic, IdentityId.caretaker, IdentityId.shadow, IdentityId.protector],
      'boundaries' => [IdentityId.protector, IdentityId.caretaker, IdentityId.rebel, IdentityId.shadow],
      'guilt' => [IdentityId.caretaker, IdentityId.shadow, IdentityId.analyst, IdentityId.escapist],
      _ => [IdentityId.strategist, IdentityId.rebel, IdentityId.analyst, IdentityId.shadow],
    };
  }

  static String _situationForTag(String tag) {
    return switch (tag) {
      'fear' => 'fear',
      'authority' => 'career',
      'love' => 'love',
      'boundaries' => 'boundaries',
      _ => 'decision',
    };
  }
}
