import 'dart:async';

import 'package:alter_ego/services/monetization_service.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:url_launcher/url_launcher.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  final _monetization = MonetizationService.instance;
  StreamSubscription<void>? _sub;
  bool _purchaseCompletedDuringSession = false;

  @override
  void initState() {
    super.initState();
    _sub = _monetization.changes.listen((_) {
      if (mounted) {
        setState(() {});
        // Only pop if a NEW purchase was made during this session.
        // If they were already premium, we let them stay on the page to view info.
        if (_monetization.isPremium && _purchaseCompletedDuringSession) {
          Navigator.pop(context, true);
        }
      }
    });
    _monetization.refreshStoreState();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _buy(ProductDetails product) async {
    final success = await _monetization.buy(product);
    if (success) {
      _purchaseCompletedDuringSession = true;
    }
  }

  Future<void> _restore() async {
    await _monetization.restorePurchases();
    // Restoring also counts as a "purchase completed" to close the paywall if successful
    if (_monetization.isPremium) {
       _purchaseCompletedDuringSession = true;
    }
  }

  Future<void> _launchAppleEULA() async {
    final url = Uri.parse('https://www.apple.com/legal/internet-services/itunes/dev/stdeula/');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Apple EULA')),
        );
      }
    }
  }

  Future<void> _launchTerms() async {
    final url = Uri.parse('https://sites.google.com/view/claire-diary/alter-ego-app-terms-of-use-and-privacy-policy?authuser=0');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Terms of Use')),
        );
      }
    }
  }

  Future<void> _launchPrivacyPolicy() async {
    final url = Uri.parse('https://sites.google.com/view/claire-diary/alter-ego-app-terms-of-use-and-privacy-policy?authuser=0'); 
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Privacy Policy')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = _monetization.products;

    return Scaffold(
      appBar: AppBar(title: const Text('Alter Ego Premium')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(_monetization.premiumStatusText, 
              style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            const Text('Unlock Alter Ego Premium', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text(
              'Gain complete insight into your psychological archetypes. Premium unlocks full features to help you master your shadows.',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 20),
            const Card(
              color: Colors.white10,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _FeatureItem(icon: Icons.map, text: 'Full Identity Map Visualization'),
                    _FeatureItem(icon: Icons.psychology, text: 'Advanced Shadow Analysis'),
                    _FeatureItem(icon: Icons.groups, text: 'Deep Council Simulation Depth'),
                    _FeatureItem(icon: Icons.assessment, text: 'Weekly Evolution Intelligence'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_monetization.lastError != null)
              Text(_monetization.lastError!, style: const TextStyle(color: Colors.redAccent)),
            if (_monetization.isLoadingProducts || _monetization.isPurchasing)
              const Center(child: CircularProgressIndicator())
            else if (products.isEmpty)
              const Text('Products unavailable. Try restore or retry later.')
            else
              ...products.map((p) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ElevatedButton(
                      onPressed: () => _buy(p),
                      child: Text('Subscribe: ${p.title} — ${p.price}'),
                    ),
                  )),
            const SizedBox(height: 8),
            const Text(
              'Payment will be charged to your iTunes account at confirmation of purchase. Subscriptions automatically renew unless auto-renew is turned off at least 24 hours before the end of the current period. Manage subscriptions in your iTunes Account Settings.',
              style: TextStyle(fontSize: 10, color: Colors.white54),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            OutlinedButton(
              onPressed: _restore,
              child: const Text('Restore Purchases'),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: _launchPrivacyPolicy,
                  child: const Text('Privacy Policy', style: TextStyle(fontSize: 10)),
                ),
                const Text('|', style: TextStyle(color: Colors.grey)),
                TextButton(
                  onPressed: _launchTerms,
                  child: const Text('Terms of Use', style: TextStyle(fontSize: 10)),
                ),
                const Text('|', style: TextStyle(color: Colors.grey)),
                TextButton(
                  onPressed: _launchAppleEULA,
                  child: const Text('Apple Standard EULA', style: TextStyle(fontSize: 10)),
                ),
              ],
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Not now'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blueAccent),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
