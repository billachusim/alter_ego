class EgoVoiceMapper {

  static String voiceId(String ego) {

    switch (ego) {

    // Calm masculine strategist
      case "Strategist":
        return "EXAVITQu4vr4xnSDxMaL";

    // Slightly edgy rebel
      case "Rebel":
        return "TxGEqnHWrfWFTfGW9XjX";

    // Deep mysterious
      case "Shadow":
        return "ErXwobaYiN019PkySvjV";

    // Warm caretaker
      case "Caretaker":
        return "MF3mGyEYCl7XYWbV9V6O";

      default:
        return "EXAVITQu4vr4xnSDxMaL";
    }
  }
}
