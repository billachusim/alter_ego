import 'ego_conflict.dart';

class EgoConflictEngine {

  static List<EgoConflict> generate(String situation) {

    /// Later replace this with AI call.
    /// Keep structure.

    return [
      EgoConflict(
        ego: "Strategist",
        message: "Control the variables. Walk in prepared.",
      ),
      EgoConflict(
        ego: "Rebel",
        message: "Over-preparation kills authenticity.",
      ),
      EgoConflict(
        ego: "Shadow",
        message:
        "You are both ignoring the real question — why is he afraid?",
      ),
      EgoConflict(
        ego: "Caretaker",
        message:
        "Maybe focus less on yourself and more on how you can serve.",
      ),
    ];
  }
}
