import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PremiumFeature {
  fullIdentityMap,
  shadowAnalysis,
  deepCouncilSimulation,
  weeklyEvolutionReport,
}

class MonetizationService {
  MonetizationService._();
  static final MonetizationService instance = MonetizationService._();

  static const monthlyProductId = 'alter_ego_premium_monthly';
  static const yearlyProductId = 'alter_ego_premium_yearly';

  static const _entitlementKey = 'premium_entitlement_active';
  static const _entitlementSourceKey = 'premium_entitlement_source';
  static const _entitlementUpdatedAtKey = 'premium_entitlement_updated_at';

  final InAppPurchase _iap = InAppPurchase.instance;
  final StreamController<void> _changes = StreamController<void>.broadcast();

  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  bool _initialized = false;
  bool _storeAvailable = false;
  bool _isPremium = false;
  bool _isLoadingProducts = false;

  List<ProductDetails> _products = const [];
  String? _lastError;

  bool get isPremium => _isPremium;
  bool get storeAvailable => _storeAvailable;
  bool get isLoadingProducts => _isLoadingProducts;
  List<ProductDetails> get products => _products;
  String? get lastError => _lastError;

  Stream<void> get changes => _changes.stream;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool(_entitlementKey) ?? false;

    _purchaseSubscription = _iap.purchaseStream.listen(
      _handlePurchaseUpdates,
      onDone: () => _purchaseSubscription?.cancel(),
      onError: (Object e) {
        _lastError = e.toString();
        _emit();
      },
    );

    await refreshStoreState();
  }

  Future<void> refreshStoreState() async {
    _isLoadingProducts = true;
    _emit();

    _storeAvailable = await _iap.isAvailable();
    if (!_storeAvailable) {
      _isLoadingProducts = false;
      _lastError = 'Store unavailable on this device right now.';
      _emit();
      return;
    }

    final response = await _iap.queryProductDetails({monthlyProductId, yearlyProductId});
    _products = response.productDetails.toList();
    if (response.error != null) {
      _lastError = response.error!.message;
    } else {
      _lastError = null;
    }

    _isLoadingProducts = false;
    _emit();
  }

  Future<bool> buy(ProductDetails product) async {
    final purchaseParam = PurchaseParam(productDetails: product);
    return _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }

  bool canAccess(PremiumFeature feature) {
    if (_isPremium) return true;
    switch (feature) {
      case PremiumFeature.fullIdentityMap:
      case PremiumFeature.shadowAnalysis:
      case PremiumFeature.deepCouncilSimulation:
      case PremiumFeature.weeklyEvolutionReport:
        return false;
    }
  }

  int applyIdentityLimit(int count) => _isPremium ? count : (count > 3 ? 3 : count);

  int applyHistoryLimit(int count) => _isPremium ? count : (count > 7 ? 7 : count);

  int applyCouncilDepthLimit(int count) => _isPremium ? count : (count > 2 ? 2 : count);

  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased || purchase.status == PurchaseStatus.restored) {
        await _setPremiumEntitlement(active: true, source: purchase.productID);
      }

      if (purchase.status == PurchaseStatus.error) {
        _lastError = purchase.error?.message ?? 'Purchase failed.';
      }

      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
    _emit();
  }

  Future<void> _setPremiumEntitlement({required bool active, required String source}) async {
    _isPremium = active;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_entitlementKey, active);
    await prefs.setString(_entitlementSourceKey, source);
    await prefs.setString(_entitlementUpdatedAtKey, DateTime.now().toIso8601String());
  }

  void _emit() {
    if (!_changes.isClosed) {
      _changes.add(null);
    }
  }

  Future<void> dispose() async {
    await _purchaseSubscription?.cancel();
    await _changes.close();
  }
}
