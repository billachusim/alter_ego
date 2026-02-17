import 'package:alter_ego/alter_ego.dart';
import 'package:alter_ego/alter_ego_service.dart';
import 'package:alter_ego/content/offline_content_repository.dart';
import 'package:alter_ego/models/identity.dart';
import 'package:flutter/material.dart';

class AdviceScreen extends StatefulWidget {
  const AdviceScreen({super.key});

  @override
  State<AdviceScreen> createState() => _AdviceScreenState();
}

class _AdviceScreenState extends State<AdviceScreen> {
  late Future<List<AlterEgo>> _councilFuture;
  final _alterEgoService = AlterEgoService();

  @override
  void initState() {
    super.initState();
    _councilFuture = _loadCouncil();
  }

  Future<List<AlterEgo>> _loadCouncil() async {
    final egos = await _alterEgoService.loadAlterEgos();
    egos.sort((a, b) => b.leaning.compareTo(a.leaning));
    return egos.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Council Replies')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: FutureBuilder<List<AlterEgo>>(
          future: _councilFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            final council = snapshot.data!;
            if (council.isEmpty) return const Center(child: Text('Your council is still forming.'));

            return ListView(
              children: council.map((ego) {
                final id = identityIdFromAny(ego.name) ?? IdentityId.shadow;
                final advice = OfflineContentRepository.pickReply(
                  identity: id,
                  situationType: 'decision',
                  intensity: 'medium',
                  seed: DateTime.now().day,
                );
                return Card(
                  color: Colors.white10,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text('${ego.icon} ${ego.name}'),
                    subtitle: Text(advice),
                    onTap: () => Navigator.pop(context, ego.name),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}
