import 'package:alter_ego/models/identity.dart';
import 'package:alter_ego/question.dart';

/// Daily check-in scenarios. Each line is:
///   category | scenario | answer#codes | answer#codes | ...
/// Codes: S strategist, R rebel, C caretaker, A achiever, M romantic,
/// P protector, N analyst, E escapist, H shadow. The first code gets the
/// main weight, a second code a smaller one.
const _bank = r'''
work|Your manager praises a teammate for work you did.|Calmly mention your part in the next meeting#SA|Let it go, but note it for your review#NS|Feel it burn and say nothing#HE|Tell your manager privately, directly#RP
work|A big deadline lands on your desk at 5pm.|Make a fast plan and get moving#AS|Ask what can be dropped to make room#PN|Groan, grab snacks, and start later tonight#EA|Push back: this timeline isn't fair#RP
work|You're offered a promotion that means longer hours.|Take it, growth matters most right now#AS|Negotiate the hours before saying yes#SP|Ask yourself if the role excites you#MN|Turn it down; your peace is worth more#PC
work|A colleague keeps interrupting you in meetings.|Say "let me finish" in a calm voice#PR|Speak to them privately afterwards#CS|Track how often it happens first#NS|Quietly resent them#HE
work|You made a mistake nobody noticed yet.|Fix it and tell your lead straight away#AN|Fix it quietly and move on#SE|Worry about it all evening#HP|Own it openly; honesty is everything#MR
work|Your job feels stable but boring.|Start a side project to feel alive again#RA|Map a two-year plan to move up or out#SN|Stay; stability is underrated#PC|Daydream about a totally different life#ME
work|You're asked to present to senior leaders tomorrow.|Rehearse until it's sharp#AS|Focus on the story you want them to feel#MS|Prepare the data so no question catches you#NP|Feel like hiding until it's over#EH
work|A coworker is struggling and falling behind.|Offer to help them catch up#CM|Mention it to the manager to protect the project#PS|Give them tips without doing their work#NA|Stay out of it; it isn't your role#EP
work|You get vague feedback: "be more strategic."|Ask for a concrete example#NA|Read up and come back with a plan#SA|Feel stung and doubt yourself#HC|Shrug; they don't really know what they mean#RE
work|Your idea is rejected in a meeting.|Refine it and bring it back stronger#AS|Ask exactly what would make it work#NS|Feel embarrassed and stay quiet next time#EH|Build it anyway on the side#RA
money|An unexpected bill arrives this month.|Rework the budget line by line#NP|Find a quick way to earn extra#AR|Ignore it for a few days#EH|Call and negotiate a payment plan#SP
money|A friend asks to borrow money again.|Say no kindly but firmly#PC|Lend a smaller amount than asked#CS|Lend it and hope for the best#CM|Ask what happened to the last loan#HN
money|You have some extra money this month.|Save or invest most of it#PS|Treat yourself to something you've wanted#EM|Put it into a project or course#AS|Help someone who needs it#CM
money|You see a deal that seems too good to be true.|Research it thoroughly first#NP|Walk away; it probably is#PN|Try a tiny amount just to see#RA|Get excited and imagine the gains#ME
money|Everyone around you is spending on things you can't afford.|Stick to your plan, quietly#PS|Feel the pressure and spend anyway#EH|Laugh it off; you're on your own path#RM|Use it as fuel to earn more#AH
relationships|Someone you like takes hours to reply to your message.|Wait and match their energy#PS|Ask directly what's going on#RH|Assume the worst and spiral#HE|Stay warm; maybe they're just busy#CM
relationships|Your partner forgets something important to you.|Tell them how it made you feel#MC|Let it slide this time#CE|Bring it up later when calm#SP|Feel quietly hurt and keep score#HP
relationships|You're attracted to someone who isn't good for you.|Walk away before it gets deeper#PN|Follow the feeling and see#MR|Analyse why you're drawn to them#NH|Keep it secret and fantasise#HE
relationships|Someone you love wants more time than you can give.|Have an honest talk about limits#PM|Rearrange your schedule for them#CA|Feel guilty and pull away#HE|Plan regular quality time together#SC
relationships|An ex texts "I miss you."|Ignore it; that chapter is closed#PR|Reply kindly but keep distance#CS|Feel the old pull and reply warmly#ME|Ask yourself what you're really missing#HN
relationships|You want to say "I love you" first.|Say it; life is short#MR|Wait for clearer signs#PN|Show it through actions instead#CA|Overthink it for weeks#HE
relationships|Your partner has a habit that annoys you.|Bring it up gently#CM|Ignore it; nobody's perfect#EC|Joke about it until it changes#RE|Let it build until it explodes#HR
conflict|Someone dismisses your opinion in public.|Calmly hold your ground#PS|Fire back with something sharp#RH|Go quiet and replay it all night#HE|Address it privately afterwards#CS
conflict|A friend crosses a boundary again.|State the boundary clearly, one last time#PR|Distance yourself without explaining#EP|Try to understand why they did it#CN|Tell them exactly how angry you are#RH
conflict|Two friends ask you to take sides.|Stay neutral and support both#CS|Pick the side you believe is right#RM|Ask each one what happened, then decide#NS|Avoid both until it blows over#EP
conflict|You realise you were wrong in an argument.|Apologise clearly and quickly#MC|Change your behaviour without a big speech#AS|Defend yourself anyway#HR|Explain why you thought you were right#NP
conflict|A stranger is rude to you in public.|Ignore it; not worth your energy#ES|Say something back, calmly#PR|Wonder what bad day they're having#CM|Let it ruin your mood for hours#HE
conflict|Someone spreads a rumour about you.|Confront them directly#RP|Let your actions speak#SA|Tell close friends the truth#CM|Act like you don't care while seething#HE
stress|Your mind feels loud and overloaded.|Write everything down and pick three things#SA|Go for a walk and breathe#EP|Push through; there's too much to do#AH|Call someone and talk it out#CM
stress|You wake up tired with no emotional buffer.|Lower today's expectations on purpose#CP|Coffee and power through#AH|Cancel what you can and rest#EP|Figure out what's draining you#NS
stress|Everything feels urgent at once.|Rank it all, then do the top one#SN|Do the quickest tasks first for momentum#AE|Freeze and scroll your phone#EH|Ask for help with one thing#CP
stress|You feel pressure to be perfect.|Aim for done, not perfect#AR|Remind yourself who you're doing this for#MC|Double-check everything twice#NP|Secretly feel like a fraud#HE
stress|It's 2am and you can't stop thinking.|Get up and write the thoughts down#NS|Put on calming sounds#EC|Plan tomorrow in detail#SA|Spiral through every worst case#HP
stress|Your phone keeps buzzing with demands.|Turn on do-not-disturb for an hour#PE|Reply to everything fast to clear it#AC|Ignore them and feel guilty#EH|Set clear hours for replies#SP
identity|You wonder who is actually in control lately.|Notice your patterns this week#NS|Shake things up and do something new#RM|Go back to habits that grounded you#PA|Admit you've been on autopilot#HE
identity|An old pattern you hate returns.|Catch it early and change course#SA|Be gentle; growth isn't a straight line#CM|Get angry at yourself#HA|Look for what triggered it#NH
identity|You feel split between comfort and growth.|Choose growth, even if it hurts#AR|Choose comfort for now; you need rest#EC|Find a small step that does both#SN|Ask what your heart really wants#MH
identity|You want to reinvent yourself.|Start with one visible change#AR|Plan the new you carefully#SN|Tell no one until it's real#HP|Follow the feeling and see where it goes#ME
identity|Someone describes you in a way you don't recognise.|Ask what made them see you that way#NC|Laugh; they don't really know you#RE|Wonder if they're right#HM|Show them who you really are over time#AS
identity|You look at photos of yourself from five years ago.|Feel proud of how far you've come#AM|Miss who you used to be#ME|Notice what's still the same#NH|Make a plan for five years from now#SA
friends|A close friend hasn't checked on you in weeks.|Reach out first; maybe they're struggling#CM|Wait and see if they notice#HP|Tell them you've missed them#MR|Accept that friendships change#NE
friends|Your friend shares big news you feel jealous about.|Celebrate them genuinely#CM|Feel the jealousy and learn from it#HN|Use it as motivation#AH|Congratulate them and change the subject#EP
friends|You're invited out but you're exhausted.|Go for an hour, then leave#CS|Say no and rest without guilt#PE|Go and power through#AC|Cancel last minute#EH
friends|A friend asks your honest opinion on a bad idea.|Tell them the truth kindly#MN|Encourage them; it's their life#CR|Ask questions so they see it themselves#SN|Say it's great to avoid conflict#EC
friends|Your group chat makes a joke that hurts you.|Say it wasn't funny to you#RP|Laugh along and feel bad later#EH|Message one friend privately about it#CM|Leave the chat for a while#PE
family|A family member criticises your life choices.|Calmly explain your reasons#SN|Set a boundary about the topic#PR|Feel like a child again and shrink#HE|Remember they mean well, and let it pass#CM
family|Your parents expect you to follow a path you don't want.|Have an honest, respectful talk#MR|Follow it for now and plan your exit#SP|Do your own thing and let them adjust#RA|Feel torn and avoid the topic#EH
family|A sibling asks for help again.|Help; family is family#CP|Help, but set terms this time#PS|Say no; they need to grow#RN|Help while quietly resenting it#HC
family|There's tension at a family gathering.|Keep the peace and calm things down#CP|Step outside for air#EP|Address it head on#RH|Observe who's really upset and why#NS
family|An elderly relative needs more care.|Step up and organise a plan#SC|Share the load with others#CN|Feel overwhelmed and guilty#HE|Give what you can without burning out#PC
dreams|You have a dream you've never told anyone.|Write it down tonight#MS|Take one small step toward it this week#AR|Keep it safe and secret for now#PH|Tell one person you trust#CM
dreams|Someone your age achieved what you want.|Study how they did it#NA|Feel behind and frustrated#HE|Feel inspired to start#AM|Remind yourself your path is your own#RC
dreams|You could take a year off to do anything.|Travel and see the world#RM|Build something of your own#AS|Rest and heal properly#EC|Learn a whole new skill#NA
dreams|You're given a chance that scares you.|Say yes and figure it out later#RA|Prepare carefully, then say yes#SP|Say no; the timing isn't right#PE|Ask what scares you about it#HN
dreams|You imagine your life ten years from now.|Picture it clearly and work backwards#SA|Hope it feels meaningful, whatever it is#ME|Worry it won't turn out well#PH|Want it to be completely different from now#RM
mystic|A stranger hands you a key and walks away.|Search for the door it opens#RA|Keep it safe until you understand#PN|Feel it's a sign meant for you#ME|Wonder what they wanted from you#HN
mystic|You find a door in your home you've never seen.|Open it immediately#RA|Listen at it first#NP|Feel it's been waiting for you#MH|Lock it and pretend you didn't see it#EP
mystic|An oracle offers to show you your future, at a price.|Pay; knowledge is power#SA|Refuse; you'd rather write it yourself#RM|Ask what the price really is#NP|Look, but only at the good parts#EM
mystic|You can hear one person's true thoughts for a day.|Choose someone you love, to understand them#CM|Choose your rival, to win#SH|Refuse; some things should stay private#PN|Choose yourself, the real you#HM
mystic|A mirror shows a version of you who made different choices.|Ask them what they learned#NM|Feel envy for their life#HE|Feel grateful for your own path#CM|Step through and swap#RA
mystic|You wake up with one new power.|Invisibility, to move freely#ER|Reading minds, to understand people#NC|Time control, to get everything done#AS|Healing, to help others#CP
mystic|A wise old voice says: "Let go of one thing."|A grudge you've carried#CM|A fear that keeps you small#RA|A person who drains you#PH|A plan that no longer fits#SN
mystic|You're lost in a forest at dusk.|Find the stars and navigate#SN|Make a shelter and wait for morning#PE|Follow the strange light ahead#MR|Call out and see who answers#HC
mystic|You can relive one day of your life.|A day you wish you'd handled better#HN|The happiest day you remember#ME|A day you'd use to warn your younger self#PS|None; you'd rather go forward#AR
mystic|A fortune teller says you'll face a big choice soon.|Start preparing now#SP|Laugh; you make your own fate#RN|Feel a thrill of excitement#MA|Feel uneasy and on edge#HE
everyday|Plans get cancelled last minute.|Relief; free evening!#EC|Annoyed; you'd rearranged things#PN|Make new plans immediately#AR|Wonder if they're avoiding you#HP
everyday|You have a free Sunday with no plans.|Rest completely#EC|Tackle your to-do list#AS|Go somewhere new on a whim#RM|Spend it with people you love#CM
everyday|You're stuck in traffic and running late.|Call ahead and adjust plans#SC|Use the time to listen to something good#EN|Feel your blood boil#HR|Find a faster route and push through#AS
everyday|Someone compliments you unexpectedly.|Accept it warmly#MC|Brush it off awkwardly#EH|Wonder what they want#PH|Feel motivated for the day#AM
everyday|You see someone struggling with heavy bags.|Help them straight away#CA|Ask if they want help first#CP|Hesitate, then walk on#EH|Think about it for the rest of the day#MN
everyday|Your favourite place closes down.|Feel nostalgic and sad#ME|Find a new favourite quickly#AR|Wonder why it failed#NS|Shrug; things change#RE
choices|You find a wallet full of cash on the street.|Return everything to the owner#CP|Hand it to the police#PN|Keep a little as a "finder's fee"#HR|Track the owner down yourself#AM
choices|You can know the truth about one secret, but it will change things.|Know it; the truth matters#NR|Leave it; some peace is worth keeping#PE|Know it, then decide carefully what to do#SN|Know it, because not knowing would eat at you#HA
choices|You're asked to keep a secret that could hurt someone.|Keep your word#PC|Encourage them to tell the truth#MN|Tell the person who could be hurt#RC|Feel trapped and avoid them both#EH
choices|You have to choose between a safe path and an exciting one.|The exciting one; you only live once#RM|The safe one; you can take risks later#PS|Try the exciting one with a backup plan#SN|Freeze and wait for a sign#EH
choices|You're offered fame or deep friendship, not both.|Deep friendship, always#CM|Fame, and the influence it brings#AH|Neither; you want freedom#RE|Friendship, but you'd wonder about fame#HN
growth|You start a habit and miss a day.|Restart tomorrow, no drama#AS|Feel like you've ruined it#HE|Figure out what got in the way#NS|Make it easier so it sticks#SP
growth|Someone gives you harsh but fair criticism.|Thank them and use it#AN|Feel stung, then reflect later#CH|Defend yourself#RP|Ask for specific examples#NS
growth|You're learning something hard and progress is slow.|Keep showing up daily#AP|Change your method#SN|Wonder if you're just not good at it#HE|Remember why you started#MA
growth|You finally finish something you've worked on for months.|Celebrate properly#MC|Immediately start the next thing#AS|Feel oddly empty#HE|Review what you learned#NS
growth|You realise you've been comparing yourself to others a lot.|Unfollow accounts that make you feel small#PR|Write down your own wins#AC|Feel the sting and admit you want more#HM|Focus on your own lane from today#SA
''';

const _codeMap = {
  'S': IdentityId.strategist,
  'R': IdentityId.rebel,
  'C': IdentityId.caretaker,
  'A': IdentityId.achiever,
  'M': IdentityId.romantic,
  'P': IdentityId.protector,
  'N': IdentityId.analyst,
  'E': IdentityId.escapist,
  'H': IdentityId.shadow,
};

List<Question>? _cache;

/// The full bank of unique check-in questions.
List<Question> questionBank() {
  if (_cache != null) return _cache!;
  final out = <Question>[];
  var n = 0;
  for (final raw in _bank.split('\n')) {
    final line = raw.trim();
    if (line.isEmpty) continue;
    final parts = line.split('|');
    if (parts.length < 4) continue;
    final category = parts[0];
    final scenario = parts[1];
    final answers = <Answer>[];
    for (final a in parts.skip(2)) {
      final hash = a.lastIndexOf('#');
      if (hash < 0) continue;
      final text = a.substring(0, hash);
      final codes = a.substring(hash + 1);
      final scores = <IdentityId, double>{};
      for (final (i, ch) in codes.split('').indexed) {
        final id = _codeMap[ch];
        if (id != null) scores[id] = i == 0 ? 0.12 : 0.05;
      }
      answers.add(Answer(text: text, scores: scores));
    }
    out.add(Question(
      id: 'v2_${category}_$n',
      category: category,
      text: scenario,
      answers: answers,
    ));
    n++;
  }
  _cache = out;
  return out;
}
