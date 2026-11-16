import 'dart:math';

import 'package:alter_ego/models/identity.dart';

class Omen {
  final String symbol;
  final String name;
  final String message;
  final String ritual;
  const Omen(this.symbol, this.name, this.message, this.ritual);
}

/// Daily omen cards. One is drawn per day, coloured by the dominant voice.
class Omens {
  Omens._();

  static const _cards = [
    Omen('☽', 'The Moon', 'Not everything needs an answer today. Let something stay a mystery.', 'Before bed, write one question and leave it unanswered.'),
    Omen('☀', 'The Sun', 'Your light is meant to be seen. Stop dimming it to make others comfortable.', 'Wear or do one thing today that feels fully like you.'),
    Omen('✶', 'The Star', 'A small hope you dismissed is worth a second look.', 'Name one wish out loud, even if only to yourself.'),
    Omen('⚘', 'The Seed', 'What you plant quietly today will surprise you later.', 'Do one tiny thing for your future self.'),
    Omen('⌘', 'The Crossroads', 'A choice is near. The path that scares you a little may be the one.', 'Notice which option you keep thinking about.'),
    Omen('☁', 'The Mist', 'Clarity is coming, but not by force. Slow down.', 'Take a ten-minute walk without your phone.'),
    Omen('⚔', 'The Blade', 'Cut one thing that drains you. You will feel lighter.', 'Say no to one small request today.'),
    Omen('❀', 'The Bloom', 'Something in you is opening. Be gentle with it.', 'Give yourself one compliment and mean it.'),
    Omen('♜', 'The Tower', 'An old structure in your life is cracking. Let it.', 'Write down one belief you are ready to question.'),
    Omen('☄', 'The Comet', 'A sudden idea today is worth chasing.', 'Capture every idea you have today in one note.'),
    Omen('⚖', 'The Scales', 'Balance is not 50/50 every day. Give more to what needs it now.', 'Ask: what part of my life needs attention most today?'),
    Omen('🜂', 'The Flame', 'Your anger or passion is fuel. Point it somewhere useful.', 'Spend 20 minutes on something you care about.'),
    Omen('🜄', 'The River', 'Stop pushing against the current for a day. Flow.', 'Let one thing go the way it wants to.'),
    Omen('🜃', 'The Stone', 'Stay steady. Your patience is a quiet power.', 'Finish one thing you started, slowly and well.'),
    Omen('🜁', 'The Wind', 'Change is in the air. Open a window in your routine.', 'Do one thing differently from yesterday.'),
    Omen('◈', 'The Mirror', 'What irritates you in others has a message about you.', 'Notice one judgment you make today and ask what it reveals.'),
    Omen('⚚', 'The Healer', 'Rest is not lazy. Something in you needs repair.', 'Go to bed 30 minutes earlier tonight.'),
    Omen('♛', 'The Crown', 'Act today like the version of you who already made it.', 'Make one decision the way your future self would.'),
    Omen('⚓', 'The Anchor', 'Hold on to what grounds you. Not everything new is better.', 'Spend time with someone or something familiar.'),
    Omen('✧', 'The Spark', 'A conversation today could change something. Say the true thing.', 'Send one honest message you\'ve been holding back.'),
    Omen('☾', 'The Veil', 'You already know more than you admit. Listen inward.', 'Sit in silence for two minutes and notice the first thought.'),
    Omen('⚝', 'The Compass', 'If you feel lost, return to your values, not your fears.', 'Write your top three values and check today against them.'),
    Omen('☉', 'The Eye', 'Pay attention to small signs today. Patterns are speaking.', 'Notice what keeps repeating today.'),
    Omen('♾', 'The Loop', 'You are repeating a pattern. Today you can break it.', 'Catch the pattern once and do the opposite.'),
    Omen('⚶', 'The Key', 'An answer you need is in a conversation you\'ve been avoiding.', 'Start that conversation, or plan when you will.'),
    Omen('❂', 'The Wheel', 'Seasons turn. The hard part does not last forever.', 'Remember one hard time you got through.'),
    Omen('⛤', 'The Pentacle', 'Protect your energy and your resources today.', 'Check one expense or one commitment you could cut.'),
    Omen('☊', 'The Bridge', 'Reach toward someone. Connection is the medicine today.', 'Message someone you haven\'t spoken to in a while.'),
    Omen('⧗', 'The Hourglass', 'Time is precious. Spend today on what matters.', 'Pick the one task that would make today a win.'),
    Omen('✺', 'The Dawn', 'A new beginning is closer than it looks.', 'Write one sentence about the life you are starting.'),
  ];

  static const _voiceWhispers = {
    IdentityId.strategist: 'Your Strategist says: plan one move, then make it.',
    IdentityId.rebel: 'Your Rebel says: break one rule that isn\'t yours.',
    IdentityId.caretaker: 'Your Caretaker says: include yourself in today\'s kindness.',
    IdentityId.achiever: 'Your Achiever says: one finished thing beats ten started.',
    IdentityId.romantic: 'Your Romantic says: follow what makes your heart lean forward.',
    IdentityId.protector: 'Your Protector says: guard your peace like treasure.',
    IdentityId.analyst: 'Your Analyst says: check the story against the facts.',
    IdentityId.escapist: 'Your Escapist says: rest, but don\'t hide.',
    IdentityId.shadow: 'Your Shadow says: name the thing you\'re avoiding.',
  };

  static Omen today([DateTime? day]) {
    final d = day ?? DateTime.now();
    final seed = d.year * 1000 + d.month * 40 + d.day;
    return _cards[Random(seed).nextInt(_cards.length)];
  }

  static String whisper(IdentityId? dominant) =>
      dominant == null ? 'Your council is still forming. Check in to awaken it.' : _voiceWhispers[dominant]!;
}
