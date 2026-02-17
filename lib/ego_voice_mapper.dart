import 'package:alter_ego/models/identity.dart';

class EgoVoiceMapper {
  static String voiceId(IdentityId identity) {
    return switch (identity) {
      IdentityId.strategist => 'EXAVITQu4vr4xnSDxMaL',
      IdentityId.rebel => 'TxGEqnHWrfWFTfGW9XjX',
      IdentityId.shadow => 'ErXwobaYiN019PkySvjV',
      IdentityId.caretaker => 'MF3mGyEYCl7XYWbV9V6O',
      _ => 'EXAVITQu4vr4xnSDxMaL',
    };
  }
}
