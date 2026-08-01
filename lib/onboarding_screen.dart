import 'package:alter_ego/question_screen.dart';
import 'package:alter_ego/services/app_settings_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _nicknameController = TextEditingController();
  final _pageController = PageController();
  final _settings = AppSettingsService();
  int _currentPage = 0;

  Future<void> _completeOnboarding() async {
    if (_nicknameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a nickname to proceed.')),
      );
      return;
    }
    await _settings.setOnboarded(true);
    await _settings.setNickname(_nicknameController.text.trim());
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const QuestionScreen()));
  }

  void _nextPage() {
    _pageController.nextPage(duration: 400.ms, curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (idx) => setState(() => _currentPage = idx),
            children: [
              _buildIntroSlide(),
              _buildPrivacySlide(),
              _buildNicknameSlide(),
            ],
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) => _buildDot(index)),
                ),
                const SizedBox(height: 24),
                if (_currentPage < 2)
                  ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                      backgroundColor: Colors.white10,
                    ),
                    child: const Text('Next'),
                  )
                else
                  ElevatedButton(
                    onPressed: _completeOnboarding,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                      backgroundColor: Colors.deepPurpleAccent,
                    ),
                    child: const Text('Begin Journey'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: 200.ms,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? Colors.white : Colors.white24,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildIntroSlide() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 120,
            width: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.blueAccent.withAlpha(50), blurRadius: 40, spreadRadius: 10)
              ],
              gradient: const LinearGradient(colors: [Colors.cyan, Colors.blueAccent]),
            ),
            child: const Icon(Icons.psychology, size: 60, color: Colors.white),
          ).animate().scale(delay: 200.ms, duration: 600.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 40),
          const Text(
            'Your Inner Council Awaits.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -1),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
          const SizedBox(height: 16),
          const Text(
            'Uncover the hidden voices that shape your decisions and identity.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.white70),
          ).animate().fadeIn(delay: 600.ms),
        ],
      ),
    );
  }

  Widget _buildPrivacySlide() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.security, size: 100, color: Colors.greenAccent).animate().shake(),
          const SizedBox(height: 40),
          const Text(
            '100% Local. 0% Cloud.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _privacyItem(Icons.no_accounts, 'No accounts required.'),
          _privacyItem(Icons.cloud_off, 'Your data never leaves your phone.'),
          _privacyItem(Icons.visibility_off, 'Encrypted local storage.'),
        ],
      ),
    );
  }

  Widget _privacyItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.white54, size: 24),
          const SizedBox(width: 16),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16, color: Colors.white70))),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1);
  }

  Widget _buildNicknameSlide() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'What should your council call you?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _nicknameController,
            autofocus: true,
            style: const TextStyle(fontSize: 20),
            decoration: InputDecoration(
              labelText: 'Nickname',
              hintText: 'e.g. Seeker',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              prefixIcon: const Icon(Icons.person_outline),
            ),
          ),
        ],
      ),
    );
  }
}
