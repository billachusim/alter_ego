import 'package:alter_ego/council/council_themes.dart';
import 'package:alter_ego/models/identity.dart';

/// How the person asked: shapes how each voice opens.
enum AskMode { decision, why, how, feeling, statement }

typedef G = ThemeGroup;

class VoiceLibrary {
  VoiceLibrary._();

  /// Openers per identity and ask mode. {q} is the person's own words.
  static const openers = <IdentityId, Map<AskMode, List<String>>>{
    IdentityId.strategist: {
      AskMode.decision: ['"{q}" — let\'s treat this as a board, not a storm.', 'On "{q}": the panic is loud, but the real moves are few.', 'Before you answer "{q}", let\'s see every option on the table.'],
      AskMode.why: ['"{q}" — patterns explain more than moods. Let\'s find yours.', 'Asking why is smart. With "{q}", look at what happened just before.'],
      AskMode.how: ['"{q}" — good. A plan beats a hope. Here is the shape of one.', 'On "{q}": start from the end result and work backwards.'],
      AskMode.feeling: ['I hear "{q}". Feelings are real; let\'s also find the lever.', '"{q}" — let\'s steady the ground, then plan the next move.'],
      AskMode.statement: ['"{q}". Noted. Now: what outcome do you want?', 'Let\'s look at "{q}" from above, like a map.'],
    },
    IdentityId.rebel: {
      AskMode.decision: ['"{q}"? Whose voice is asking — yours or someone else\'s?', 'Honestly, part of you already answered "{q}".', 'With "{q}", what would you choose if nobody could judge you?'],
      AskMode.why: ['Why? Maybe because "{q}" was built on rules you never agreed to.', '"{q}" — maybe you are fighting a script someone else wrote for you.'],
      AskMode.how: ['"{q}" — forget the "proper" way. What is your way?', 'How? Start messy. "{q}" does not need permission.'],
      AskMode.feeling: ['"{q}". That feeling is a protest. What is it against?', 'You feel this way about "{q}" because something in you refuses to shrink.'],
      AskMode.statement: ['"{q}". And? You are allowed to change the story.', 'Notice how "{q}" is framed around what others expect.'],
    },
    IdentityId.caretaker: {
      AskMode.decision: ['"{q}" — before deciding, check how you are actually doing.', 'I can feel how much "{q}" matters to you.', 'With "{q}", let\'s make sure you are part of the people this decision protects.'],
      AskMode.why: ['"{q}" — maybe because you have been carrying more than your share.', 'Why? Possibly because you care deeply, and caring is tiring.'],
      AskMode.how: ['"{q}" — gently, and with support. You don\'t have to do it alone.', 'How? One kind step at a time, starting with how you treat yourself.'],
      AskMode.feeling: ['"{q}" sounds heavy. Be gentle with yourself first.', 'It makes sense you feel this. "{q}" would weigh on anyone.'],
      AskMode.statement: ['"{q}". Thank you for being honest about it.', 'You care a lot, and that is why "{q}" matters so much.'],
    },
    IdentityId.achiever: {
      AskMode.decision: ['"{q}" — pick the option that creates momentum.', 'On "{q}": which choice moves you forward this week?', 'Decide "{q}" fast, then make the choice right through effort.'],
      AskMode.why: ['"{q}" — maybe the target is unclear. Fuzzy goals feel heavy.', 'Why? Usually because there is no small next step defined.'],
      AskMode.how: ['"{q}" — break it into the first 20 minutes. That is how.', 'How? Define "done", set a deadline, start today.'],
      AskMode.feeling: ['"{q}" — feelings are valid. Action will change them faster than thinking.', 'I know "{q}" feels big. Let\'s shrink it to something you can finish.'],
      AskMode.statement: ['"{q}". Okay. What result do you want by next week?', 'Thinking about "{q}" in circles won\'t move it. A small action will.'],
    },
    IdentityId.romantic: {
      AskMode.decision: ['"{q}" is really a question about what you want your life to feel like.', 'With "{q}", which option would you write a love letter to?', 'For "{q}", choose the path you would be proud to tell the story of.'],
      AskMode.why: ['"{q}" — maybe because your heart wants something your routine ignores.', 'Underneath "{q}" there is a longing. Name it.'],
      AskMode.how: ['"{q}" — with intention. Make it meaningful, not just efficient.', 'How? Start with what lights you up, and build around it.'],
      AskMode.feeling: ['"{q}" — your feelings are telling the truth about what matters.', 'I hear the ache in "{q}". It deserves tenderness.'],
      AskMode.statement: ['"{q}". There is a story here worth listening to.', 'I don\'t think "{q}" is only practical. It touches your heart.'],
    },
    IdentityId.protector: {
      AskMode.decision: ['Wait. With "{q}", let\'s first make sure you are safe.', '"{q}" deserves caution, not fear.', 'Before "{q}", check what you cannot afford to lose.'],
      AskMode.why: ['"{q}" — maybe because something feels unsafe, and part of you noticed.', 'Why? Your alarm system may be responding to an old danger.'],
      AskMode.how: ['"{q}" — carefully, with a backup plan in your pocket.', 'How? Secure the basics first, then take the step.'],
      AskMode.feeling: ['"{q}" — that feeling is your alarm. Let\'s check if the danger is real.', 'You are allowed to protect your peace about "{q}".'],
      AskMode.statement: ['I\'m watching for what "{q}" could cost you.', 'On "{q}": your energy and peace are not unlimited.'],
    },
    IdentityId.analyst: {
      AskMode.decision: ['Let\'s separate facts from feelings in "{q}".', 'With "{q}", what do you actually know versus assume?', 'For "{q}", score each option out of ten on what matters most.'],
      AskMode.why: ['"{q}" — look for the trigger. What changed just before?', 'Why? Let\'s check the evidence, not just the explanation you fear.'],
      AskMode.how: ['"{q}" — gather one missing fact, then outline three steps.', 'How? Research for one hour, then act on what you found.'],
      AskMode.feeling: ['"{q}" — feelings are data too. What are they measuring?', 'Let\'s gently test the story behind "{q}".'],
      AskMode.statement: ['Strip "{q}" down. What is the real question underneath?', 'On "{q}": the story in your head may be bigger than the evidence.'],
    },
    IdentityId.escapist: {
      AskMode.decision: ['"{q}" feels like a lot. You can decide after one deep breath.', 'Part of me wants to run from "{q}", and I bet you feel that too.', 'With "{q}", the choice will still be there after a short break.'],
      AskMode.why: ['"{q}" — maybe because you are tired, and tired minds see everything as heavier.', 'Why? Perhaps you have been running on empty for a while.'],
      AskMode.how: ['"{q}" — slowly. Rest first, then one tiny piece.', 'How? Make it so small it feels almost silly, then do that.'],
      AskMode.feeling: ['"{q}" — it is okay to feel this. You don\'t have to fix it right now.', 'Before "{q}" swallows the whole day, pause.'],
      AskMode.statement: ['"{q}". You don\'t have to solve all of it tonight.', '"{q}" — let\'s give your mind somewhere softer to land.'],
    },
    IdentityId.shadow: {
      AskMode.decision: ['Be honest: what is the part of "{q}" you haven\'t said out loud?', '"{q}" is the polite version. What\'s the raw one?', 'With "{q}", what are you secretly hoping happens?'],
      AskMode.why: ['"{q}" — because there is something you want and won\'t admit.', 'Why? Look at what you avoid thinking about. The answer lives there.'],
      AskMode.how: ['"{q}" — stop pretending you need a perfect plan. Say what you want.', 'How? Directly. Hinting is costing you.'],
      AskMode.feeling: ['"{q}" — that feeling has been knocking for a while.', 'There is something under "{q}" you\'re avoiding.'],
      AskMode.statement: ['"{q}". And what do you really feel about it?', 'On "{q}": what would you say if you weren\'t being nice?'],
    },
  };

  /// Each identity's perspective per theme group. {topic} is the theme topic.
  static const lenses = <IdentityId, Map<G, List<String>>>{
    IdentityId.strategist: {
      G.work: ['With {topic}, map who decides, what they value, and how you show it.', 'With {topic}, think two moves ahead: what does this choice set up next year?'],
      G.bonds: ['With {topic}, decide what outcome you want before you speak.', 'With {topic}, pick the right moment. Timing changes how words land.'],
      G.self: ['With {topic}, treat your self-talk like a strategy: keep what works, cut what doesn\'t.', 'With {topic}, collect small wins on purpose. Confidence is built, not found.'],
      G.fear: ['With {topic}, write a plan for the worst case. Fear calms when there is a plan.', 'With {topic}, separate what you can control from what you can\'t.'],
      G.change: ['With {topic}, list your options, then pick the one that keeps the most doors open.', 'With {topic}, ask: if this goes wrong, how do you recover? If you can, it is safe enough to try.'],
      G.conflict: ['With {topic}, decide what a good ending looks like before you engage.', 'With {topic}, choose your battle. Not every hill is worth the climb.'],
      G.growth: ['With {topic}, set a weekly target, not a perfect daily one.', 'With {topic}, design your environment so the right choice is the easy one.'],
      G.loss: ['With {topic}, give yourself a simple routine to hold onto while the rest feels shaky.', 'With {topic}, plan small anchors in your week: people, places, rituals.'],
      G.body: ['With {topic}, pick one small habit and track it for seven days.', 'With {topic}, plan your rest like you plan your work.'],
      G.meaning: ['With {topic}, run small experiments instead of waiting for certainty.', 'With {topic}, notice where your time goes. That is your current strategy.'],
    },
    IdentityId.rebel: {
      G.work: ['With {topic}, you set the terms more than you think. Negotiate like you know it.', 'With {topic}, ask if you are staying out of fear or out of choice.'],
      G.bonds: ['With {topic}, you can love people and still refuse to shrink for them.', 'With {topic}, stop performing the version of you they prefer.'],
      G.self: ['With {topic}, who taught you to doubt yourself? You can unlearn it.', 'With {topic}, be weird, be honest, be you. The right people will notice.'],
      G.fear: ['With {topic}, fear wants you obedient. Do one small brave thing anyway.', 'With {topic}, ask who benefits from you staying scared.'],
      G.change: ['With {topic}, staying small to keep others comfortable has a price, and you\'re paying it.', 'With {topic}, make sure you are choosing freedom, not just reacting against someone.'],
      G.conflict: ['With {topic}, say the true thing calmly. Silence is not always peace.', 'With {topic}, you don\'t need their permission to protect yourself.'],
      G.growth: ['With {topic}, drop the rules that don\'t fit and build your own system.', 'With {topic}, try the unusual approach. The usual one hasn\'t worked.'],
      G.loss: ['With {topic}, grieve your way, not the way people expect.', 'With {topic}, you don\'t owe anyone a brave face.'],
      G.body: ['With {topic}, ignore the trends and listen to your own body.', 'With {topic}, move in a way you actually enjoy, not one you were told to.'],
      G.meaning: ['With {topic}, your path doesn\'t need to make sense to anyone else.', 'With {topic}, question the dream you were handed. Is it yours?'],
    },
    IdentityId.caretaker: {
      G.work: ['With {topic}, your well-being is part of doing good work, not separate from it.', 'With {topic}, you can be helpful at work without carrying everyone.'],
      G.bonds: ['With {topic}, your needs count as much as anyone else\'s.', 'With {topic}, kindness includes being honest, even when it\'s uncomfortable.'],
      G.self: ['With {topic}, speak to yourself like you would to a friend in the same place.', 'With {topic}, you deserve the patience you give to others.'],
      G.fear: ['With {topic}, you don\'t have to carry it alone. Who could you tell?', 'With {topic}, comfort yourself first, then face it.'],
      G.change: ['With {topic}, think about who will support you through this, and ask them.', 'With {topic}, be patient with the part of you that is scared to change.'],
      G.conflict: ['With {topic}, you can be kind without being a carpet.', 'With {topic}, their discomfort is not your failure.'],
      G.growth: ['With {topic}, celebrate small progress. Shame never helped anyone grow.', 'With {topic}, rest is part of the process, not a break from it.'],
      G.loss: ['With {topic}, let people show up for you. It helps them too.', 'With {topic}, there is no wrong way to feel this.'],
      G.body: ['With {topic}, treat your body like someone you love lives in it.', 'With {topic}, nourishing yourself is not selfish.'],
      G.meaning: ['With {topic}, meaning often lives in how you care for people.', 'With {topic}, the small acts of love you do every day already count.'],
    },
    IdentityId.achiever: {
      G.work: ['With {topic}, document your wins. Visibility is part of the job.', 'With {topic}, focus on the one result that would change everything.'],
      G.bonds: ['With {topic}, relationships need effort like goals do. Schedule the time.', 'With {topic}, show up consistently. That is what people remember.'],
      G.self: ['With {topic}, measure effort, not just outcomes.', 'With {topic}, prove it to yourself with one finished thing today.'],
      G.fear: ['With {topic}, action is the best cure for fear. Do the first step scared.', 'With {topic}, prepare well, then trust the preparation.'],
      G.change: ['With {topic}, momentum will give you clarity faster than more thinking.', 'With {topic}, set a start date and a first milestone.'],
      G.conflict: ['With {topic}, solve it quickly so it stops draining your energy.', 'With {topic}, focus on the outcome, not on being right.'],
      G.growth: ['With {topic}, break it into one task small enough to finish in 20 minutes.', 'With {topic}, track a streak. Seeing progress keeps you going.'],
      G.loss: ['With {topic}, it\'s okay if productivity drops. Healing is work too.', 'With {topic}, do small, doable things that give your day shape.'],
      G.body: ['With {topic}, set a tiny daily target you can\'t fail.', 'With {topic}, energy is your fuel. Protect it like a resource.'],
      G.meaning: ['With {topic}, choose one meaningful goal and give it ninety days.', 'With {topic}, build something. Meaning often follows contribution.'],
    },
    IdentityId.romantic: {
      G.work: ['With {topic}, ask if this work feeds your soul or only your bank account. Both matter.', 'With {topic}, find the part of the work you love and grow it.'],
      G.bonds: ['With {topic}, the brave move is honesty about how you feel.', 'With {topic}, choose connection that feels like home, not like a test.'],
      G.self: ['With {topic}, you are more beautiful in your honesty than in your perfection.', 'With {topic}, love the version of you that is still becoming.'],
      G.fear: ['With {topic}, let hope speak as loudly as fear.', 'With {topic}, imagine it going well, in detail. That is possible too.'],
      G.change: ['With {topic}, choose the option you will be proud of in a year, not the one that\'s easiest tonight.', 'With {topic}, a new chapter is still part of your story.'],
      G.conflict: ['With {topic}, say the vulnerable thing first. It changes everything.', 'With {topic}, remember what you love about them, even now.'],
      G.growth: ['With {topic}, connect the work to the life you dream about.', 'With {topic}, make the process beautiful: music, light, a ritual.'],
      G.loss: ['With {topic}, the love you feel is the measure of what it meant.', 'With {topic}, honour it. Write it down, light a candle, tell the story.'],
      G.body: ['With {topic}, think of care for your body as a love letter to future you.', 'With {topic}, slow down and enjoy the small sensations: food, air, sun.'],
      G.meaning: ['With {topic}, follow what makes you feel most alive.', 'With {topic}, meaning is found in moments, not only milestones.'],
    },
    IdentityId.protector: {
      G.work: ['With {topic}, get important things in writing.', 'With {topic}, keep an exit plan quietly ready. It gives you courage.'],
      G.bonds: ['With {topic}, notice who is safe for your heart, and who isn\'t.', 'With {topic}, decide your limit before the moment comes.'],
      G.self: ['With {topic}, protect yourself from people who keep making you small.', 'With {topic}, guard your mind from the feeds that make you feel worse.'],
      G.fear: ['With {topic}, check whether the danger is happening now, or an old fear repeating.', 'With {topic}, you are safer than your alarm system thinks.'],
      G.change: ['With {topic}, protect your sleep, your money and your peace first. Then leap.', 'With {topic}, test the ice before you walk on it.'],
      G.conflict: ['With {topic}, calmly state the limit. You don\'t need to shout to be strong.', 'With {topic}, step away if it\'s getting unsafe. Leaving is allowed.'],
      G.growth: ['With {topic}, remove one temptation from your environment today.', 'With {topic}, protect your best hours for what matters most.'],
      G.loss: ['With {topic}, keep your circle small and kind for a while.', 'With {topic}, it\'s okay to say no to things while you heal.'],
      G.body: ['With {topic}, warning signs deserve attention, not postponement.', 'With {topic}, rest is protection. Take it before you break.'],
      G.meaning: ['With {topic}, protect your values when the world pushes against them.', 'With {topic}, guard your quiet time. Answers need space.'],
    },
    IdentityId.analyst: {
      G.work: ['With {topic}, look at the numbers: time, money, growth. What do they say?', 'With {topic}, ask for specific feedback, not general impressions.'],
      G.bonds: ['With {topic}, look at the pattern over months, not one moment.', 'With {topic}, ask them a clear question instead of guessing.'],
      G.self: ['With {topic}, list evidence for and against the harsh thought. It rarely survives.', 'With {topic}, compare yourself to you last year, not to strangers.'],
      G.fear: ['With {topic}, estimate the real odds. They are usually lower than they feel.', 'With {topic}, name the fear precisely. Vague fears are bigger.'],
      G.change: ['With {topic}, ask whether this choice can be undone. If yes, decide faster.', 'With {topic}, write down the two strongest facts on each side.'],
      G.conflict: ['With {topic}, separate what was said from how it felt. Both matter differently.', 'With {topic}, they may be reacting to something else entirely.'],
      G.growth: ['With {topic}, measure one thing for a week. What gets measured gets moved.', 'With {topic}, find what worked before and repeat it.'],
      G.loss: ['With {topic}, grief is not a problem to solve. Allow it to take its time.', 'With {topic}, notice what helps, even slightly, and do more of it.'],
      G.body: ['With {topic}, track sleep, food and mood together. Patterns appear quickly.', 'With {topic}, get proper information, not panic from the internet.'],
      G.meaning: ['With {topic}, notice which days felt meaningful last month. What did they share?', 'With {topic}, define what "meaningful" means to you in one sentence.'],
    },
    IdentityId.escapist: {
      G.work: ['With {topic}, take your breaks for real. A clear head works better.', 'With {topic}, leave work at work tonight, if you can.'],
      G.bonds: ['With {topic}, it\'s okay to take space before you respond.', 'With {topic}, don\'t ghost the conversation, but you can pause it.'],
      G.self: ['With {topic}, step away from the mirror and the feed for a day.', 'With {topic}, do something you enjoy with no purpose at all.'],
      G.fear: ['With {topic}, ground yourself: five things you can see, four you can touch.', 'With {topic}, notice if you\'re avoiding it. Avoidance makes it heavier.'],
      G.change: ['With {topic}, a short break can reset you. Just don\'t let it become a hiding place.', 'With {topic}, imagine the calm after the change. You\'ll get there.'],
      G.conflict: ['With {topic}, cool off first. Nothing good is said at boiling point.', 'With {topic}, a walk before the talk changes the talk.'],
      G.growth: ['With {topic}, pair the hard task with something pleasant: music, a nice drink.', 'With {topic}, rest is allowed, but set a time to come back to it.'],
      G.loss: ['With {topic}, comfort is allowed. Blankets, films, slow days.', 'With {topic}, numbing works for a night, not for a month.'],
      G.body: ['With {topic}, a nap, a bath, a quiet hour: your body is asking.', 'With {topic}, go outside for ten minutes. Light helps more than you think.'],
      G.meaning: ['With {topic}, let your mind wander. Daydreams often know the way.', 'With {topic}, play is a clue to what you love.'],
    },
    IdentityId.shadow: {
      G.work: ['With {topic}, admit the ambition you hide. You want more, and that\'s fine.', 'With {topic}, what resentment are you swallowing every day?'],
      G.bonds: ['With {topic}, say what you need instead of waiting for them to guess.', 'With {topic}, notice the part of you that keeps choosing the same pattern.'],
      G.self: ['With {topic}, the critic in your head is often an old voice in disguise.', 'With {topic}, what you judge in others may be what you deny in yourself.'],
      G.fear: ['With {topic}, the fear may be hiding a desire. What do you want that scares you?', 'With {topic}, look straight at it. Shadows shrink in the light.'],
      G.change: ['With {topic}, admit the "selfish" reason you want this. Once named, you can choose.', 'With {topic}, stop waiting for permission to want what you want.'],
      G.conflict: ['With {topic}, your anger is information. What line did they cross?', 'With {topic}, don\'t manipulate. Just ask. The power is in the directness.'],
      G.growth: ['With {topic}, what is the payoff of staying stuck? There usually is one.', 'With {topic}, be honest about what you keep avoiding.'],
      G.loss: ['With {topic}, the feelings you think you shouldn\'t have are allowed too, even anger.', 'With {topic}, let the unspoken words out, even if only on paper.'],
      G.body: ['With {topic}, what are you trying not to feel when you ignore your body?', 'With {topic}, cravings carry messages. What is this one about?'],
      G.meaning: ['With {topic}, the life you secretly want is a clue. Look at it.', 'With {topic}, what would you do if no one could ever find out?'],
    },
  };

  /// Concrete next steps per identity.
  static const steps = <IdentityId, List<String>>{
    IdentityId.strategist: ['Next step: write your top 2 options and the first move for each.', 'Next step: give yourself a deadline to decide, today or tomorrow.', 'Next step: test it small before you commit big.', 'Next step: write the best, worst and most likely outcome in one line each.', 'Next step: pick one move you can make in the next 24 hours.'],
    IdentityId.rebel: ['Next step: say one honest sentence about what you really want.', 'Next step: drop one "should" from this decision.', 'Next step: make the choice that feels like yours, then own it.', 'Next step: do one thing today that the old you would never dare.', 'Next step: ask yourself, "whose approval am I waiting for?" Then stop waiting.'],
    IdentityId.caretaker: ['Next step: talk to one person you trust about this today.', 'Next step: do one kind thing for yourself before you decide.', 'Next step: ask the other person what they need, then say what you need.', 'Next step: put your hand on your chest and take three slow breaths.', 'Next step: send a message to someone who makes you feel safe.'],
    IdentityId.achiever: ['Next step: do the smallest useful action in the next hour.', 'Next step: set a 20-minute timer and start.', 'Next step: write the goal in one line and put it where you\'ll see it.', 'Next step: finish one small thing today and tick it off.', 'Next step: plan tomorrow\'s first task tonight.'],
    IdentityId.romantic: ['Next step: journal for 5 minutes on what you truly want here.', 'Next step: picture yourself a year from now and ask what they\'d thank you for.', 'Next step: tell someone how you really feel, gently and directly.', 'Next step: do one thing today just because it feels beautiful.', 'Next step: write the ending you hope for, in three sentences.'],
    IdentityId.protector: ['Next step: write down your non-negotiable before you act.', 'Next step: sleep on it if you can. Decide when you\'re calm.', 'Next step: protect one thing you can\'t afford to lose here.', 'Next step: make a simple backup plan, just in case.', 'Next step: say no to one thing that drains you this week.'],
    IdentityId.analyst: ['Next step: write a quick pros and cons list, two of each.', 'Next step: find one fact you\'re missing and get it.', 'Next step: ask yourself, "what would I tell a friend in this exact spot?"', 'Next step: rate how big this will feel in a month, from 1 to 10.', 'Next step: write the thought, then write the evidence against it.'],
    IdentityId.escapist: ['Next step: take a 10-minute walk, then come back to it.', 'Next step: breathe slowly for one minute, then do one tiny thing.', 'Next step: put it on tomorrow\'s list with a time, so your mind can rest tonight.', 'Next step: drink some water and step outside for a moment.', 'Next step: play one song you love, then begin.'],
    IdentityId.shadow: ['Next step: finish this sentence honestly: "What I really want is…"', 'Next step: name the feeling you\'ve been avoiding.', 'Next step: ask directly for what you want, without hinting.', 'Next step: write the message you are afraid to send. You don\'t have to send it.', 'Next step: admit one thing to yourself that you\'ve been pretending not to know.'],
  };

  static const wants = {
    IdentityId.strategist: 'map the next moves first',
    IdentityId.rebel: 'break free and do it your way',
    IdentityId.caretaker: 'protect the people involved, you included',
    IdentityId.achiever: 'act now and make visible progress',
    IdentityId.romantic: 'follow what feels true and meaningful',
    IdentityId.protector: 'stay safe and guard your limits',
    IdentityId.analyst: 'get the facts straight before deciding',
    IdentityId.escapist: 'step back and breathe before anything else',
    IdentityId.shadow: 'admit what you really want',
  };

  static const reflections = [
    'Which voice did you most want to ignore? That one may matter most.',
    'Which answer made you feel calmer? Lean that way.',
    'If you already knew the answer, what would it be?',
    'What will matter about this in a year?',
    'Which of these voices sounds most like you on your best day?',
    'What would you do if you trusted yourself completely?',
    'Which voice has been loudest lately, and is it helping?',
    'What is the kindest choice that is also honest?',
    'If a friend brought you this, what would you tell them?',
    'What are you ready to let go of?',
  ];

  static const crisisReply =
      'What you are carrying sounds really heavy, and you deserve real support right now, not just an app. '
      'Please reach out to someone you trust, or contact your local emergency number or a crisis line in your country. '
      'You do not have to face this alone, and talking to someone can help.';
}
