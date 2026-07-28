import 'dart:async';
import 'package:alter_ego/services/app_settings_service.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
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
  final _settings = AppSettingsService();

  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  bool _initialized = false;
  bool _storeAvailable = false;
  bool _isPremiumSubscribed = false;
  DateTime? _trialStartDate;
  bool _isLoadingProducts = false;
  bool _isPurchasing = false;

  List<ProductDetails> _products = const [];
  String? _lastError;

  bool get isPremium => _isPremiumSubscribed || _isTrialActive;

  bool get _isTrialActive {
    if (_trialStartDate == null) return false;
    final now = DateTime.now();
    final diff = now.difference(_trialStartDate!);
    return diff.inDays < 7;
  }

  String get premiumStatusText {
    if (_isPremiumSubscribed) return 'Premium (Subscribed)';
    if (_isTrialActive) {
      final daysLeft = 7 - DateTime.now().difference(_trialStartDate!).inDays;
      return 'Premium Trial ($daysLeft days left)';
    }
    return 'Free Tier';
  }

  bool get storeAvailable => _storeAvailable;
  bool get isLoadingProducts => _isLoadingProducts;
  bool get isPurchasing => _isPurchasing;
  List<ProductDetails> get products => _products;
  String? get lastError => _lastError;

  Stream<void> get changes => _changes.stream;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    final prefs = await SharedPreferences.getInstance();
    _isPremiumSubscribed = prefs.getBool(_entitlementKey) ?? false;

    _trialStartDate = await _settings.firstLaunchDate();
    if (_trialStartDate == null) {
      _trialStartDate = DateTime.now();
      await _settings.setFirstLaunchDate(_trialStartDate!);
    }

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

    // On iOS, we should also check if we can make payments
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final canMakePayments = await SKPaymentQueueWrapper.canMakePayments();
      if (!canMakePayments) {
        _storeAvailable = false;
        _isLoadingProducts = false;
        _lastError = 'In-app purchases are restricted on this device.';
        _emit();
        return;
      }
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
    _isPurchasing = true;
    _lastError = null;
    _emit();

    final purchaseParam = PurchaseParam(productDetails: product);
    try {
      final success = await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      if (!success) {
        _isPurchasing = false;
        _emit();
      }
      return success;
    } catch (e) {
      _isPurchasing = false;
      _lastError = e.toString();
      _emit();
      return false;
    }
  }

  Future<void> restorePurchases() async {
    _isPurchasing = true;
    _lastError = null;
    _emit();
    try {
      await _iap.restorePurchases();
    } catch (e) {
      _isPurchasing = false;
      _lastError = e.toString();
      _emit();
    }
  }

  bool canAccess(PremiumFeature feature) {
    if (isPremium) return true;
    switch (feature) {
      case PremiumFeature.fullIdentityMap:
      case PremiumFeature.shadowAnalysis:
      case PremiumFeature.deepCouncilSimulation:
      case PremiumFeature.weeklyEvolutionReport:
        return false;
    }
  }

  int applyIdentityLimit(int count) => isPremium ? count : (count > 3 ? 3 : count);

  int applyHistoryLimit(int count) => isPremium ? count : (count > 7 ? 7 : count);

  int applyCouncilDepthLimit(int count) => isPremium ? count : (count > 2 ? 2 : count);

  String getSubscriptionPeriodText(ProductDetails product) {
    String? periodText;

    if (product is AppStoreProductDetails) {
      final SKProductSubscriptionPeriodWrapper? period = product.skProduct.subscriptionPeriod;
      if (period != null) {
        final numberOfUnits = period.numberOfUnits;
        final unitText = switch (period.unit) {
          SKSubscriptionPeriodUnit.day => numberOfUnits == 1 ? 'day' : 'days',
          SKSubscriptionPeriodUnit.week => numberOfUnits == 1 ? 'week' : 'weeks',
          SKSubscriptionPeriodUnit.month => numberOfUnits == 1 ? 'month' : 'months',
          SKSubscriptionPeriodUnit.year => numberOfUnits == 1 ? 'year' : 'years',
        };
        periodText = numberOfUnits == 1 ? '/ $unitText' : '/ $numberOfUnits $unitText';
      }
    }
    return periodText ?? '';
  }

  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.pending) {
        _isPurchasing = true;
      } else {
        _isPurchasing = false;

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
    }
    _emit();
  }

  Future<void> _setPremiumEntitlement({required bool active, required String source}) async {
    _isPremiumSubscribed = active;
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
