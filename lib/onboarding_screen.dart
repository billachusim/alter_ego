import 'package:alter_ego/question_screen.dart';
import 'package:alter_ego/services/app_settings_service.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _nicknameController = TextEditingController();
  final _settings = AppSettingsService();

  Future<void> _completeOnboarding() async {
    if (_nicknameController.text.trim().isEmpty) return;
    await _settings.setOnboarded(true);
    await _settings.setNickname(_nicknameController.text.trim());
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const QuestionScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome.', style: TextStyle(fontSize: 34)),
            const SizedBox(height: 12),
            const Text('Let\'s map your internal voices.'),
            const SizedBox(height: 24),
            TextField(
              controller: _nicknameController,
              decoration: const InputDecoration(labelText: 'What should I call you?', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _completeOnboarding, child: const Text('Begin')),
          ],
        ),
      ),
    );
  }
}
