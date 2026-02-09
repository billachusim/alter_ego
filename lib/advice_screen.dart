import 'package:alter_ego/alter_ego.dart';
import 'package:alter_ego/alter_ego_service.dart';
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
      appBar: AppBar(
        title: const Text('Your Inner Council'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'You have a difficult decision to make at work.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: FutureBuilder<List<AlterEgo>>(
                future: _councilFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Your council is still forming.'));
                  }
                  final council = snapshot.data!;
                  return ListView.builder(
                    itemCount: council.length,
                    itemBuilder: (context, index) {
                      final ego = council[index];
                      return _buildAdviceCard(
                        '${ego.icon} ${ego.name}',
                        _getAdviceForEgo(ego.name),
                        _getColorForEgo(ego.name),
                      );
                    },
                  );
                },
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                // TODO: Capture user's choice and feed back into the model
                Navigator.pop(context);
              },
              child: const Text('I\'ve decided'),
            ),
          ],
        ),
      ),
    );
  }

  String _getAdviceForEgo(String egoName) {
    switch (egoName) {
      case 'The Strategist': return '"Wait. Think about the consequences."' ;
      case 'The Rebel': return '"Do it. You\'re tired of playing safe."' ;
      case 'The Caretaker': return '"How will this affect people you care about?"' ;
      case 'The Shadow': return '"Observe for now. Information is power."' ;
      default: return '"Embrace the mystery within."' ;
    }
  }

  Color _getColorForEgo(String egoName) {
    switch (egoName) {
      case 'The Strategist': return Colors.blue.withOpacity(0.3);
      case 'The Rebel': return Colors.red.withOpacity(0.3);
      case 'The Caretaker': return Colors.green.withOpacity(0.3);
      case 'The Shadow': return Colors.purple.withOpacity(0.3);
      default: return Colors.grey.withOpacity(0.3);
    }
  }

  Widget _buildAdviceCard(String egoName, String advice, Color color) {
    return Card(
      color: color,
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              egoName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              advice,
              style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}
