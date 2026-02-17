enum IdentityId {
  strategist,
  rebel,
  caretaker,
  achiever,
  romantic,
  protector,
  analyst,
  escapist,
  shadow,
}

class IdentityProfile {
  final IdentityId id;
  final String label;
  final String shortName;
  final String icon;
  final String description;
  final String shadowPattern;
  final String growthCue;

  const IdentityProfile({
    required this.id,
    required this.label,
    required this.shortName,
    required this.icon,
    required this.description,
    required this.shadowPattern,
    required this.growthCue,
  });
}

IdentityId? identityIdFromAny(String raw) {
  final normalized = raw.trim().toLowerCase();
  const map = {
    'strategist': IdentityId.strategist,
    'the strategist': IdentityId.strategist,
    'rebel': IdentityId.rebel,
    'the rebel': IdentityId.rebel,
    'caretaker': IdentityId.caretaker,
    'the caretaker': IdentityId.caretaker,
    'achiever': IdentityId.achiever,
    'the achiever': IdentityId.achiever,
    'romantic': IdentityId.romantic,
    'the romantic': IdentityId.romantic,
    'protector': IdentityId.protector,
    'the protector': IdentityId.protector,
    'analyst': IdentityId.analyst,
    'the analyst': IdentityId.analyst,
    'escapist': IdentityId.escapist,
    'the escapist': IdentityId.escapist,
    'shadow': IdentityId.shadow,
    'the shadow': IdentityId.shadow,
  };
  return map[normalized];
}

String identityStorageLabel(IdentityId id) {
  return switch (id) {
    IdentityId.strategist => 'The Strategist',
    IdentityId.rebel => 'The Rebel',
    IdentityId.caretaker => 'The Caretaker',
    IdentityId.achiever => 'The Achiever',
    IdentityId.romantic => 'The Romantic',
    IdentityId.protector => 'The Protector',
    IdentityId.analyst => 'The Analyst',
    IdentityId.escapist => 'The Escapist',
    IdentityId.shadow => 'The Shadow',
  };
}
