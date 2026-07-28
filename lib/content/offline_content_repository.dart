import 'dart:math';

import 'package:alter_ego/models/identity.dart';
import 'package:alter_ego/question.dart';

class CouncilReply {
  final IdentityId identity;
  final String situationType;
  final String intensity;
  final String text;

  const CouncilReply({
    required this.identity,
    required this.situationType,
    required this.intensity,
    required this.text,
  });
}

class OfflineContentRepository {
  OfflineContentRepository._();

  static final profiles = <IdentityProfile>[
    const IdentityProfile(id: IdentityId.strategist, label: 'The Strategist', shortName: 'Strategist', icon: '🜂', description: 'Plans with precision and thinks five moves ahead.', shadowPattern: 'Over-plans until action gets delayed.', growthCue: 'Pick one move and execute before optimizing.'),
    const IdentityProfile(id: IdentityId.rebel, label: 'The Rebel', shortName: 'Rebel', icon: '🜁', description: 'Protects freedom and resists pressure fast.', shadowPattern: 'Mistakes resistance for self-expression.', growthCue: 'Choose a rule to break and one to honor.'),
    const IdentityProfile(id: IdentityId.caretaker, label: 'The Caretaker', shortName: 'Caretaker', icon: '🜄', description: 'Feels others deeply and carries emotional weight.', shadowPattern: 'Gives until resentment builds.', growthCue: 'Offer support without abandoning your own needs.'),
    const IdentityProfile(id: IdentityId.achiever, label: 'The Achiever', shortName: 'Achiever', icon: '⬢', description: 'Tracks progress and turns pressure into output.', shadowPattern: 'Self-worth becomes tied to performance.', growthCue: 'Measure effort quality, not only outcomes.'),
    const IdentityProfile(id: IdentityId.romantic, label: 'The Romantic', shortName: 'Romantic', icon: '✦', description: 'Craves depth, meaning, and emotional truth.', shadowPattern: 'Idealizes then crashes into disappointment.', growthCue: 'Seek consistency over intensity.'),
    const IdentityProfile(id: IdentityId.protector, label: 'The Protector', shortName: 'Protector', icon: '🛡', description: 'Defends boundaries and people with fierce loyalty.', shadowPattern: 'Threat-detection stays on even when safe.', growthCue: 'Pause and verify threat before reacting.'),
    const IdentityProfile(id: IdentityId.analyst, label: 'The Analyst', shortName: 'Analyst', icon: '◬', description: 'Finds truth through evidence and pattern clarity.', shadowPattern: 'Confuses emotional distance with objectivity.', growthCue: 'Include feelings as data, not noise.'),
    const IdentityProfile(id: IdentityId.escapist, label: 'The Escapist', shortName: 'Escapist', icon: '☾', description: 'Looks for relief when reality feels heavy.', shadowPattern: 'Numbs discomfort and postpones growth.', growthCue: 'Take one tiny step before seeking comfort.'),
    const IdentityProfile(id: IdentityId.shadow, label: 'The Shadow', shortName: 'Shadow', icon: '🜃', description: 'Holds suppressed anger, hunger, and unspoken truth.', shadowPattern: 'Operates indirectly through cynicism or avoidance.', growthCue: 'Name the raw truth directly and safely.'),
  ];

  static final Map<IdentityId, IdentityProfile> profilesById = {
    for (final p in profiles) p.id: p,
  };

  static List<Question> getQuestionBank() {
    final categories = {
      'conflict': [
        'Someone dismisses your opinion in public',
        'A friend crosses a boundary again',
        'Your plan gets derailed last minute',
        'You are misunderstood in a tense conversation',
      ],
      'work': [
        'A high-stakes deadline lands suddenly',
        'You receive ambiguous feedback from your manager',
        'You can either ship now or improve quality',
        'Your teammate is underperforming on shared work',
      ],
      'relationships': [
        'A person you care about goes emotionally distant',
        'You sense mixed signals from someone important',
        'You need to ask for reassurance directly',
        'You must choose between peace and honesty tonight',
      ],
      'stress': [
        'Your mind feels loud and overloaded',
        'You wake up tired with no emotional buffer',
        'Everything feels urgent at once',
        'You feel pressure to be perfect',
      ],
      'identity': [
        'You wonder who is actually in control lately',
        'You notice an old pattern returning',
        'You feel split between comfort and growth',
        'You want to reinvent yourself but fear regret',
      ],
    };

    final answerTemplates = [
      (
        'I pause, map the pattern, then choose deliberately.',
        {
          IdentityId.strategist: 0.11,
          IdentityId.analyst: 0.07,
        }
      ),
      (
        'I push back fast. I would rather be real than compliant.',
        {
          IdentityId.rebel: 0.12,
          IdentityId.protector: 0.06,
        }
      ),
      (
        'I check who might be affected and try to hold everyone gently.',
        {
          IdentityId.caretaker: 0.12,
          IdentityId.romantic: 0.05,
        }
      ),
      (
        'I convert pressure into action and chase measurable progress.',
        {
          IdentityId.achiever: 0.12,
          IdentityId.strategist: 0.05,
        }
      ),
      (
        'I seek depth, emotional truth, and the conversation beneath the conversation.',
        {
          IdentityId.romantic: 0.11,
          IdentityId.shadow: 0.05,
        }
      ),
      (
        'I protect my boundaries first, then decide what access is earned.',
        {
          IdentityId.protector: 0.12,
          IdentityId.shadow: 0.04,
        }
      ),
      (
        'I gather data and detach until the facts are clean.',
        {
          IdentityId.analyst: 0.12,
          IdentityId.strategist: 0.04,
        }
      ),
      (
        'I avoid the weight for now and distract until I can breathe again.',
        {
          IdentityId.escapist: 0.13,
          IdentityId.shadow: 0.03,
        }
      ),
      (
        'I go quiet and track the truth nobody is saying out loud.',
        {
          IdentityId.shadow: 0.12,
          IdentityId.analyst: 0.04,
        }
      ),
    ];

    final questions = <Question>[];
    var i = 0;
    categories.forEach((category, prompts) {
      for (final prompt in prompts) {
        for (var variant = 0; variant < 18; variant++) {
          final answers = answerTemplates
              .map((a) => Answer(text: a.$1, scores: a.$2))
              .toList(growable: false);
          questions.add(
            Question(
              id: 'q_${category}_$i',
              category: category,
              text: '$prompt — what feels most like you right now?',
              answers: answers,
            ),
          );
          i++;
        }
      }
    });
    return questions;
  }

  static List<Question> selectDailyQuestions({
    required DateTime day,
    required Set<String> excludedIds,
    int count = 8,
  }) {
    final bank = getQuestionBank().where((q) => !excludedIds.contains(q.id)).toList();
    if (bank.isEmpty) return [];
    bank.shuffle(Random(day.year + day.month + day.day));

    final byCategory = <String, List<Question>>{};
    for (final q in bank) {
      byCategory.putIfAbsent(q.category, () => []).add(q);
    }

    final selected = <Question>[];
    while (selected.length < count && byCategory.values.any((list) => list.isNotEmpty)) {
      for (final entry in byCategory.entries) {
        if (selected.length >= count) break;
        if (entry.value.isNotEmpty) {
          selected.add(entry.value.removeAt(0));
        }
      }
    }
    return selected;
  }

  static List<CouncilReply> buildCouncilReplies() {
    const situations = ['decision', 'conflict', 'love', 'career', 'fear', 'boundaries'];
    const intensity = ['low', 'medium', 'high'];
    final replies = <CouncilReply>[];
    for (final profile in profiles) {
      for (final s in situations) {
        for (final level in intensity) {
          for (var i = 0; i < 5; i++) {
            replies.add(
              CouncilReply(
                identity: profile.id,
                situationType: s,
                intensity: level,
                text: _line(profile.shortName, s, level, i),
              ),
            );
          }
        }
      }
    }
    return replies;
  }

  static String pickReply({
    required IdentityId identity,
    required String situationType,
    required String intensity,
    int seed = 0,
    String? historyHint,
  }) {
    final pool = buildCouncilReplies().where((r) => r.identity == identity && r.situationType == situationType && r.intensity == intensity).toList();
    if (pool.isEmpty) return 'Stay honest with yourself. Small clear moves beat dramatic swings.';
    
    final base = pool[seed % pool.length].text;
    if (historyHint != null && historyHint.isNotEmpty) {
      return '$historyHint\n\n$base';
    }
    return base;
  }

  static List<String> notificationPrompts() {
    return [
      'Your Rebel showed up today.',
      'I\'m noticing a pattern…',
      'Your Strategist and Rebel disagreed today.',
      'You\'re becoming more decisive.',
      'There\'s a side of you you\'re avoiding.',
      'Tonight your dominant voice changed.',
      'Your Shadow has a message you keep postponing.',
      'Your boundaries were clearer than yesterday.',
      'You chose calm over impulse today.',
      'Identity reset window is open.',
    ];
  }

  static String _line(String ego, String s, String level, int i) {
    final Map<String, Map<String, List<String>>> vault = {
      'Strategist': {
        'decision': [
          'Calculate the opportunity cost of delay. Choose now.',
          'Your first instinct was likely the most efficient. Run with it.',
          'Map the three steps following this move. If they hold, proceed.',
        ],
        'conflict': [
          'Neutralize the emotion. What is the win-condition here?',
          'Pause. Don\'t move until the board is clear.',
          'Identify the pattern in their pushback. Use it to adjust.',
        ],
      },
      'Rebel': {
        'decision': [
          'Choose the path that preserves your freedom of movement.',
          'They expect you to go left. What happens if you go right?',
          'If this choice feels like a cage, it probably is. Exit.',
        ],
        'conflict': [
          'Compliance is a slow poison. Say the "no" that is stuck in your throat.',
          'Verify if you are resisting for truth or just for the sake of friction.',
          'Let them see the fire. It sets the boundary they can\'t ignore.',
        ],
      },
      'Caretaker': {
        'decision': [
          'Include yourself in the circle of people you care for today.',
          'If you say yes to this, what are you saying no to for yourself?',
          'Heavy choices need soft landing. Who can help you carry this?',
        ],
        'conflict': [
          'Resentment is the ghost of unspoken needs. Speak them now.',
          'You can be kind without being a carpet. Stand up slowly.',
          'Their discomfort is not your failure. Let them hold their own weight.',
        ],
      },
      'Achiever': {
        'decision': [
          'Stop planning and start shipping. Momentum is your fuel.',
          'Does this move result in progress or just "busy-ness"? Choose progress.',
          'Set a timer. Make the call. The quality will follow the action.',
        ],
        'conflict': [
          'Don\'t let friction slow your output. Solve it fast and keep moving.',
          'Your worth isn\'t the result of this argument. Focus on the goal.',
          'Is this conflict a distraction or a roadblock? Treat it accordingly.',
        ],
      },
      'Romantic': {
        'decision': [
          'Seek the choice that feels most honest, even if it\'s harder.',
          'What is the story you want to tell about this moment later?',
          'Depth over speed. Let the choice breathe for a second.',
        ],
        'conflict': [
          'Say the vulnerable thing first. It changes the frequency of the fight.',
          'You are looking for meaning where there might just be noise.',
          'Don\'t idealize their silence. Ask for the truth directly.',
        ],
      },
      'Protector': {
        'decision': [
          'Is your perimeter safe? Only then can you choose the risk.',
          'Protect the parts of you that are still growing. Choose safety today.',
          'Trust your threat detection, but verify if the danger is current or old.',
        ],
        'conflict': [
          'You don\'t need to bark to show you have teeth. Calmly state the limit.',
          'Is this worth the energy of a siege? Pick your battles.',
          'Someone is pushing. Lean back and let them fall into the space.',
        ],
      },
      'Analyst': {
        'decision': [
          'Strip the emotion away. What do the facts actually say?',
          'You have enough data. The remaining uncertainty is just life.',
          'Categorize this choice: is it reversible? If yes, go fast.',
        ],
        'conflict': [
          'They are reacting, not arguing facts. Don\'t get caught in the loop.',
          'Map the logic of their stance. It helps you stay detached and clear.',
          'Your silence is a tool. Use it to let them reveal their hand.',
        ],
      },
      'Escapist': {
        'decision': [
          'Don\'t hide from the choice. It will only be heavier tomorrow.',
          'Take one tiny, real step before you seek comfort.',
          'Is this relief or just postponement? Be honest.',
        ],
        'conflict': [
          'Numbing out won\'t solve the friction. Stay in the room for five more minutes.',
          'The conflict feels loud, but you are bigger than the noise.',
          'Don\'t laugh it off. The truth deserves a serious moment.',
        ],
      },
      'Shadow': {
        'decision': [
          'Admit the "selfish" reason you want this. Once it\'s named, you can choose.',
          'The hunger you feel won\'t be satisfied by this choice. Look deeper.',
          'Stop being indirect. What do you actually want to happen?',
        ],
        'conflict': [
          'Your cynicism is a shield. Put it down and say what hurts.',
          'Don\'t manipulate. Just ask. The power is in the directness.',
          'You are seeing their shadow. Don\'t forget to track your own too.',
        ],
      },
    };

    final egoMap = vault[ego] ?? {};
    final list = egoMap[s] ?? egoMap['decision'] ?? ['$ego says: protect your future self.'];
    return list[i % list.length];
  }
}
