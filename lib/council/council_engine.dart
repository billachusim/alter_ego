import 'dart:math';

import 'package:alter_ego/ego_conflict.dart';
import 'package:alter_ego/models/identity.dart';

/// A theme the user's situation touches, with the words that signal it.
class _Theme {
  final String id;
  final String topic; // how voices refer to it, e.g. "this work situation"
  final List<String> words;
  final Map<IdentityId, double> affinity;

  const _Theme(this.id, this.topic, this.words, this.affinity);
}

/// The council's overall read on a situation.
class CouncilVerdict {
  final String tension;
  final String nextStep;
  final String reflection;

  const CouncilVerdict({required this.tension, required this.nextStep, required this.reflection});
}

class CouncilResult {
  final List<EgoConflict> voices;
  final CouncilVerdict verdict;
  final List<String> themes;

  const CouncilResult({required this.voices, required this.verdict, required this.themes});
}

/// Offline Inner Council. Builds replies from the user's own words, the
/// themes in their situation and the voices that are strongest in their
/// identity map, so two different questions rarely get the same answer.
class CouncilEngine {
  CouncilEngine._();

  static const _s = IdentityId.strategist,
      _r = IdentityId.rebel,
      _c = IdentityId.caretaker,
      _a = IdentityId.achiever,
      _ro = IdentityId.romantic,
      _p = IdentityId.protector,
      _an = IdentityId.analyst,
      _e = IdentityId.escapist,
      _sh = IdentityId.shadow;

  static const _themes = <_Theme>[
    _Theme('work', 'this work situation', ['job', 'work', 'boss', 'manager', 'career', 'office', 'promotion', 'colleague', 'coworker', 'salary', 'interview', 'client', 'resign', 'fired', 'hire'], {_s: 1, _a: 1, _r: .7, _an: .6}),
    _Theme('money', 'the money side of this', ['money', 'pay', 'debt', 'loan', 'rent', 'budget', 'afford', 'spend', 'save', 'invest', 'broke', 'price', 'cost', 'finance', 'naira', 'dollar'], {_an: 1, _p: .8, _s: .8, _e: .4}),
    _Theme('love', 'this relationship', ['love', 'relationship', 'partner', 'boyfriend', 'girlfriend', 'husband', 'wife', 'dating', 'date', 'crush', 'ex', 'marry', 'marriage', 'breakup', 'cheat', 'text him', 'text her'], {_ro: 1, _c: .8, _sh: .7, _p: .6}),
    _Theme('family', 'your family situation', ['mom', 'mum', 'mother', 'dad', 'father', 'parent', 'sister', 'brother', 'family', 'son', 'daughter', 'child', 'kids', 'uncle', 'aunt'], {_c: 1, _p: .8, _r: .6, _sh: .5}),
    _Theme('friends', 'this friendship', ['friend', 'friends', 'bestie', 'group', 'circle', 'people around me'], {_c: .9, _p: .7, _ro: .5, _r: .5}),
    _Theme('study', 'your studies', ['exam', 'school', 'study', 'class', 'course', 'university', 'grade', 'test', 'jamb', 'waec', 'degree', 'lecture', 'assignment', 'project'], {_a: 1, _s: .9, _e: .6, _an: .6}),
    _Theme('health', 'your health and energy', ['health', 'sick', 'tired', 'sleep', 'body', 'weight', 'gym', 'exercise', 'burnout', 'exhausted', 'eat', 'pain'], {_p: 1, _c: .8, _a: .5, _e: .5}),
    _Theme('fear', 'the fear underneath this', ['fear', 'afraid', 'scared', 'anxious', 'anxiety', 'panic', 'worry', 'worried', 'nervous', 'overthink'], {_sh: 1, _p: .9, _an: .6, _e: .5}),
    _Theme('risk', 'this leap', ['risk', 'quit', 'start', 'move', 'relocate', 'business', 'launch', 'leave', 'change', 'chance', 'gamble', 'travel', 'abroad', 'new'], {_r: 1, _s: .8, _p: .7, _a: .6}),
    _Theme('boundaries', 'where your limits are', ['boundary', 'boundaries', 'used', 'drained', 'respect', 'disrespect', 'take advantage', 'say no', 'too much', 'limit'], {_p: 1, _r: .8, _c: .7, _sh: .5}),
    _Theme('guilt', 'the guilt you are carrying', ['guilt', 'guilty', 'ashamed', 'shame', 'regret', 'sorry', 'mistake', 'failed', 'my fault', 'blame'], {_c: .9, _sh: .9, _an: .5, _e: .5}),
    _Theme('selfworth', 'how you see yourself', ['worth', 'enough', 'confidence', 'ugly', 'stupid', 'failure', 'compare', 'insecure', 'hate myself', 'useless', 'not good'], {_sh: 1, _ro: .7, _a: .6, _c: .6}),
    _Theme('lonely', 'the loneliness in this', ['lonely', 'alone', 'isolated', 'nobody', 'no one', 'left out', 'ignored'], {_ro: 1, _c: .8, _sh: .7, _e: .6}),
    _Theme('stuck', 'this stuck feeling', ['stuck', 'procrastinate', 'lazy', 'motivation', 'unmotivated', 'can\'t start', 'wasting', 'lost', 'confused', 'direction', 'purpose'], {_a: 1, _e: .9, _s: .7, _r: .5}),
    _Theme('anger', 'the anger in this', ['angry', 'anger', 'mad', 'furious', 'annoyed', 'hate', 'argument', 'fight', 'insult', 'unfair', 'betray'], {_r: 1, _sh: .9, _p: .8, _an: .5}),
  ];

  static const _counterweight = {
    _s: _r, _r: _p, _c: _sh, _a: _e, _ro: _an, _p: _r, _an: _ro, _e: _a, _sh: _c,
  };

  static const _names = {
    _s: 'Strategist', _r: 'Rebel', _c: 'Caretaker', _a: 'Achiever', _ro: 'Romantic',
    _p: 'Protector', _an: 'Analyst', _e: 'Escapist', _sh: 'Shadow',
  };

  // What each voice wants, used for the verdict's tension line.
  static const _wants = {
    _s: 'map the next three moves first',
    _r: 'break free and do it your way',
    _c: 'protect the people involved, you included',
    _a: 'act now and make visible progress',
    _ro: 'follow what feels true and meaningful',
    _p: 'stay safe and guard your limits',
    _an: 'get the facts straight before deciding',
    _e: 'step back and breathe before anything else',
    _sh: 'admit what you really want',
  };

  static const _openers = {
    _s: ['Let\'s look at "{q}" as a board, not a storm.', 'On "{q}": the panic is loud, but the moves are few.', '"{q}". Good. Now we can plan it.', 'I hear "{q}". Before feelings decide, let\'s see the options.'],
    _r: ['"{q}"? Whose rules are you trying to follow here?', 'Honestly, part of you already knows the answer to "{q}".', 'Notice how "{q}" is framed around what others expect.', '"{q}". Ask yourself: what would you do if nobody was watching?'],
    _c: ['"{q}" sounds heavy. Be gentle with yourself first.', 'I can feel how much "{q}" matters to you.', 'Before solving "{q}", check how you are actually doing.', 'You care a lot, and that is why "{q}" hurts.'],
    _a: ['"{q}". Let\'s turn that into something you can act on today.', 'Thinking about "{q}" in circles won\'t move it. A small action will.', 'Here\'s the thing about "{q}": progress beats perfect.', 'On "{q}": what result do you actually want by next week?'],
    _ro: ['"{q}" is really a question about what you want your life to feel like.', 'Underneath "{q}" there\'s a longing. Name it.', 'I don\'t think "{q}" is only practical. It touches your heart.', '"{q}". What would the version of you that you admire choose?'],
    _p: ['Wait. With "{q}", let\'s first make sure you\'re safe.', '"{q}" deserves caution, not fear.', 'I\'m watching for what "{q}" could cost you.', 'On "{q}": your energy and peace are not unlimited.'],
    _an: ['Let\'s separate facts from feelings in "{q}".', '"{q}". What do you actually know, and what are you assuming?', 'On "{q}": the story in your head may be bigger than the evidence.', 'Strip "{q}" down. What is the real decision underneath?'],
    _e: ['"{q}" feels like a lot right now. That\'s okay.', 'Part of me wants to run from "{q}", and I bet you feel that too.', 'Before "{q}" swallows the whole day, pause.', '"{q}". You don\'t have to solve all of it tonight.'],
    _sh: ['Be honest: what is the part of "{q}" you haven\'t said out loud?', '"{q}" is the polite version. What\'s the raw one?', 'There\'s something under "{q}" you\'re avoiding.', 'On "{q}": what are you secretly hoping happens?'],
  };

  static const _insights = {
    _s: ['With {topic}, the cost of waiting is real too. Count it.', 'With {topic}, list your options, pick the one that keeps the most doors open.', 'With {topic}, ask: if this goes wrong, how do you recover? If you can recover, it\'s safe enough to try.'],
    _r: ['With {topic}, you\'re allowed to want something different from what is expected of you.', 'With {topic}, staying small to keep others comfortable has a price, and you\'re paying it.', 'With {topic}, make sure you\'re choosing freedom, not just reacting against someone.'],
    _c: ['With {topic}, your needs count as much as anyone else\'s.', 'With {topic}, you don\'t have to carry it alone. Who could you tell?', 'With {topic}, kindness includes being honest, even when it\'s uncomfortable.'],
    _a: ['With {topic}, break it into one task small enough to finish in 20 minutes.', 'With {topic}, define what "done" looks like, then work backwards.', 'With {topic}, momentum will give you clarity faster than more thinking.'],
    _ro: ['With {topic}, choose the option you\'ll be proud of in a year, not the one that\'s easiest tonight.', 'With {topic}, look for meaning, not just relief.', 'With {topic}, honesty about how you feel is the brave move.'],
    _p: ['With {topic}, decide your limit before the moment comes, so you don\'t give in under pressure.', 'With {topic}, check whether the danger is happening now, or an old fear repeating.', 'With {topic}, protect your sleep, your money and your peace first. Then decide.'],
    _an: ['With {topic}, write down the two strongest facts on each side. The answer is usually clearer on paper.', 'With {topic}, ask whether this choice can be undone. If yes, decide faster.', 'With {topic}, get one missing piece of information before you commit.'],
    _e: ['With {topic}, rest is allowed, but set a time to come back to it.', 'With {topic}, notice if you\'re avoiding it. Avoidance makes it heavier.', 'With {topic}, a short break can reset you. Just don\'t let it become a hiding place.'],
    _sh: ['With {topic}, the feeling you keep pushing down is information, not weakness.', 'With {topic}, if part of you is resentful, ask what it needs.', 'With {topic}, stop waiting for permission to want what you want.'],
  };

  static const _steps = {
    _s: ['Next step: write your top 2 options and the first move for each.', 'Next step: give yourself a deadline to decide, today or tomorrow.', 'Next step: test it small before you commit big.'],
    _r: ['Next step: say one honest sentence about what you really want, to yourself or someone else.', 'Next step: drop one "should" from this decision.', 'Next step: make the choice that feels like yours, then own it.'],
    _c: ['Next step: talk to one person you trust about this today.', 'Next step: do one kind thing for yourself before you decide.', 'Next step: ask the other person what they need, then say what you need.'],
    _a: ['Next step: do the smallest useful action in the next hour.', 'Next step: set a 20-minute timer and start.', 'Next step: write the goal in one line and put it where you\'ll see it.'],
    _ro: ['Next step: journal for 5 minutes on what you truly want here.', 'Next step: picture yourself a year from now and ask what they\'d thank you for.', 'Next step: tell someone how you really feel, gently and directly.'],
    _p: ['Next step: write down your non-negotiable before you act.', 'Next step: sleep on it if you can. Decide when you\'re calm.', 'Next step: protect one thing you can\'t afford to lose here.'],
    _an: ['Next step: write a quick pros and cons list, two of each.', 'Next step: find one fact you\'re missing and get it.', 'Next step: ask yourself, "what would I tell a friend in this exact spot?"'],
    _e: ['Next step: take a 10-minute walk, then come back to it.', 'Next step: breathe slowly for one minute, then do one tiny thing.', 'Next step: put it on tomorrow\'s list with a time, so your mind can rest tonight.'],
    _sh: ['Next step: finish this sentence honestly: "What I really want is…"', 'Next step: name the feeling you\'ve been avoiding.', 'Next step: ask directly for what you want, without hinting.'],
  };

  static const _reflections = [
    'Which voice did you most want to ignore? That one may matter most.',
    'Which answer made you feel calmer? Lean that way.',
    'If you already knew the answer, what would it be?',
    'What will matter about this in a year?',
    'Which of these voices sounds most like you on your best day?',
  ];

  /// [situation] is what the user typed. [leanings] are the user's current
  /// identity strengths (0 to 1) from check-ins; they shape who speaks.
  static CouncilResult consult(String situation, {Map<IdentityId, double> leanings = const {}}) {
    final text = situation.trim();
    final lowered = ' ${text.toLowerCase()} ';
    final rng = Random(text.toLowerCase().hashCode);

    final matched = _themes.where((t) => t.words.any((w) => _containsWord(lowered, w))).toList();
    final themes = matched.isEmpty
        ? const [_Theme('decision', 'this decision', [], {_s: .8, _an: .7, _ro: .6, _sh: .6})]
        : matched;

    // Score every voice by theme fit plus the user's own leanings.
    final scores = <IdentityId, double>{for (final id in IdentityId.values) id: rng.nextDouble() * .15};
    for (final (i, t) in themes.indexed) {
      final weight = i == 0 ? 1.0 : .6;
      t.affinity.forEach((id, v) => scores[id] = scores[id]! + v * weight);
    }
    leanings.forEach((id, v) => scores[id] = scores[id]! + v * .8);

    final ranked = IdentityId.values.toList()..sort((a, b) => scores[b]!.compareTo(scores[a]!));
    final council = <IdentityId>[ranked[0], ranked[1]];
    final counter = _counterweight[ranked[0]]!;
    if (!council.contains(counter)) council.add(counter);
    for (final id in ranked) {
      if (council.length >= 4) break;
      if (!council.contains(id)) council.add(id);
    }

    final quote = _quote(text);
    final voices = <EgoConflict>[];
    for (final (i, id) in council.indexed) {
      final theme = themes[i % themes.length];
      final message = [
        _pick(_openers[id]!, rng).replaceAll('{q}', quote),
        _pick(_insights[id]!, rng).replaceAll('{topic}', theme.topic),
        _pick(_steps[id]!, rng),
      ].join(' ');
      final reason = id == counter && i == 2
          ? 'Speaking as the counterweight to your ${_names[council[0]]}.'
          : (leanings[id] ?? 0) > .5
              ? 'One of your strongest voices, reacting to ${theme.topic}.'
              : 'Drawn in by ${theme.topic}.';
      voices.add(EgoConflict(identity: id, message: message, rationale: reason));
    }

    final verdict = CouncilVerdict(
      tension: 'Your ${_names[council[0]]} wants to ${_wants[council[0]]}, while your ${_names[council[1]]} wants to ${_wants[council[1]]}. '
          'Both are trying to help you with ${themes.first.topic}.',
      nextStep: _pick(_steps[council[0]]!, Random(rng.nextInt(1 << 30))).replaceFirst('Next step: ', ''),
      reflection: _pick(_reflections, rng),
    );

    return CouncilResult(voices: voices, verdict: verdict, themes: themes.map((t) => t.id).toList());
  }

  static bool _containsWord(String lowered, String word) {
    if (word.contains(' ')) return lowered.contains(word);
    return RegExp('(^|[^a-z])${RegExp.escape(word)}(s|es|ed|ing)?([^a-z]|\$)').hasMatch(lowered);
  }

  static String _quote(String text) {
    var t = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    t = t.replaceAll(RegExp(r'[?.!]+$'), '');
    if (t.length <= 70) return t;
    final firstSentence = t.split(RegExp(r'(?<=[.!?])\s')).first;
    if (firstSentence.length <= 70) return firstSentence.replaceAll(RegExp(r'[?.!]+$'), '');
    final cut = t.substring(0, 67);
    final lastSpace = cut.lastIndexOf(' ');
    return '${cut.substring(0, lastSpace > 40 ? lastSpace : 67)}…';
  }

  static String _pick(List<String> list, Random rng) => list[rng.nextInt(list.length)];
}
