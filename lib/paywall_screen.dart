import 'dart:async';

import 'package:alter_ego/services/monetization_service.dart';
import 'package:flutter/material.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  final _monetization = MonetizationService.instance;
  StreamSubscription<void>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = _monetization.changes.listen((_) {
      if (mounted) {
        setState(() {});
        if (_monetization.isPremium) {
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

  @override
  Widget build(BuildContext context) {
    final products = _monetization.products;

    return Scaffold(
      appBar: AppBar(title: const Text('Unlock Alter Ego Premium')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('See who is really in control.', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text('Premium unlocks:\n• Full alter ego map\n• Shadow analysis\n• Deep council simulation\n• Weekly evolution report', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 20),
            if (_monetization.lastError != null)
              Text(_monetization.lastError!, style: const TextStyle(color: Colors.redAccent)),
            if (_monetization.isLoadingProducts)
              const Center(child: CircularProgressIndicator())
            else if (products.isEmpty)
              const Text('Products unavailable. Try restore or retry later.')
            else
              ...products.map((p) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ElevatedButton(
                      onPressed: () => _monetization.buy(p),
                      child: Text('Subscribe: ${p.title} — ${p.price}'),
                    ),
                  )),
            const Spacer(),
            OutlinedButton(
              onPressed: _monetization.restorePurchases,
              child: const Text('Restore Purchases'),
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
