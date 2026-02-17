import 'package:alter_ego/models/identity.dart';

class EgoConflict {
  final IdentityId identity;
  final String message;
  final String rationale;

  EgoConflict({
    required this.identity,
    required this.message,
    required this.rationale,
  });
}
