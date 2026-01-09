import 'dart:async';
import 'dart:io';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Subscription service for managing in-app purchases
/// 
/// Handles subscription purchases, restoration, and status checks
class SubscriptionService {
  static final SubscriptionService instance = SubscriptionService._init();
  
  final InAppPurchase _iap = InAppPurchase.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  
  // Product IDs (must match Google Play Console and App Store Connect)
  static const String monthlyProductId = 'couple_tasks_monthly';
  static const String annualProductId = 'couple_tasks_annual';
  
  // Subscription status
  bool _isPremium = false;
  String? _activeSubscriptionId;
  DateTime? _expiryDate;

  SubscriptionService._init();

  /// Get current premium status
  bool get isPremium => _isPremium;
  
  /// Get active subscription ID
  String? get activeSubscriptionId => _activeSubscriptionId;
  
  /// Get subscription expiry date
  DateTime? get expiryDate => _expiryDate;

  /// Initialize subscription service
  Future<void> initialize() async {
    print('💳 Initializing subscription service...');

    // Check if in-app purchases are available
    final available = await _iap.isAvailable();
    if (!available) {
      print('❌ In-app purchases not available');
      return;
    }

    // Set up purchase listener
    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onError: (error) {
        print('❌ Purchase stream error: $error');
      },
    );

    // Initialize platform-specific features
    if (Platform.isIOS) {
      final iosPlatform = _iap.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iosPlatform.setDelegate(ExamplePaymentQueueDelegate());
    }

    print('✅ Subscription service initialized');
  }

  /// Get available products
  Future<List<ProductDetails>> getProducts() async {
    print('📦 Fetching products...');

    final Set<String> productIds = {
      monthlyProductId,
      annualProductId,
    };

    final ProductDetailsResponse response = await _iap.queryProductDetails(productIds);

    if (response.error != null) {
      print('❌ Error fetching products: ${response.error}');
      return [];
    }

    if (response.notFoundIDs.isNotEmpty) {
      print('⚠️  Products not found: ${response.notFoundIDs}');
    }

    print('✅ Found ${response.productDetails.length} products');
    return response.productDetails;
  }

  /// Purchase subscription
  Future<void> purchaseSubscription(ProductDetails product) async {
    print('💳 Purchasing: ${product.id}');

    final PurchaseParam purchaseParam = PurchaseParam(
      productDetails: product,
    );

    try {
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      print('❌ Purchase error: $e');
      rethrow;
    }
  }

  /// Restore purchases
  Future<void> restorePurchases() async {
    print('🔄 Restoring purchases...');

    try {
      await _iap.restorePurchases();
      print('✅ Purchases restored');
    } catch (e) {
      print('❌ Restore error: $e');
      rethrow;
    }
  }

  /// Handle purchase updates
  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      print('📦 Purchase update: ${purchase.productID} - ${purchase.status}');

      switch (purchase.status) {
        case PurchaseStatus.pending:
          _handlePendingPurchase(purchase);
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _handleSuccessfulPurchase(purchase);
          break;
        case PurchaseStatus.error:
          _handleErrorPurchase(purchase);
          break;
        case PurchaseStatus.canceled:
          _handleCanceledPurchase(purchase);
          break;
      }

      // Complete purchase
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }

  /// Handle pending purchase
  void _handlePendingPurchase(PurchaseDetails purchase) {
    print('⏳ Purchase pending: ${purchase.productID}');
  }

  /// Handle successful purchase
  Future<void> _handleSuccessfulPurchase(PurchaseDetails purchase) async {
    print('✅ Purchase successful: ${purchase.productID}');

    // Verify purchase with backend (important for security!)
    final verified = await _verifyPurchase(purchase);
    
    if (!verified) {
      print('❌ Purchase verification failed');
      return;
    }

    // Update local status
    _isPremium = true;
    _activeSubscriptionId = purchase.productID;
    
    // Calculate expiry date based on subscription type
    if (purchase.productID == monthlyProductId) {
      _expiryDate = DateTime.now().add(Duration(days: 30));
    } else if (purchase.productID == annualProductId) {
      _expiryDate = DateTime.now().add(Duration(days: 365));
    }

    print('✅ Premium activated until: $_expiryDate');
  }

  /// Handle error purchase
  void _handleErrorPurchase(PurchaseDetails purchase) {
    print('❌ Purchase error: ${purchase.error}');
  }

  /// Handle canceled purchase
  void _handleCanceledPurchase(PurchaseDetails purchase) {
    print('🚫 Purchase canceled: ${purchase.productID}');
  }

  /// Verify purchase with backend
  Future<bool> _verifyPurchase(PurchaseDetails purchase) async {
    try {
      // In production, send receipt to your backend for verification
      // Backend should verify with Apple/Google servers
      
      print('🔐 Verifying purchase: ${purchase.productID}');
      
      // For now, just check that we have a purchase token/receipt
      if (Platform.isAndroid) {
        final androidPurchase = purchase as GooglePlayPurchaseDetails;
        return androidPurchase.billingClientPurchase.purchaseToken.isNotEmpty;
      } else if (Platform.isIOS) {
        final iosPurchase = purchase as AppStorePurchaseDetails;
        return iosPurchase.verificationData.serverVerificationData.isNotEmpty;
      }
      
      return false;
    } catch (e) {
      print('❌ Verification error: $e');
      return false;
    }
  }

  /// Save subscription to Firestore
  Future<void> saveSubscriptionToFirestore(String userId, PurchaseDetails purchase) async {
    try {
      await _firestore.collection('subscriptions').doc(userId).set({
        'userId': userId,
        'productId': purchase.productID,
        'purchaseId': purchase.purchaseID,
        'transactionDate': purchase.transactionDate,
        'status': purchase.status.toString(),
        'platform': Platform.isIOS ? 'ios' : 'android',
        'expiryDate': _expiryDate,
        'isPremium': true,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print('✅ Subscription saved to Firestore');
    } catch (e) {
      print('❌ Error saving subscription: $e');
    }
  }

  /// Load subscription from Firestore
  Future<void> loadSubscriptionFromFirestore(String userId) async {
    try {
      final doc = await _firestore.collection('subscriptions').doc(userId).get();
      
      if (!doc.exists) {
        print('ℹ️  No subscription found');
        _isPremium = false;
        return;
      }

      final data = doc.data()!;
      _isPremium = data['isPremium'] ?? false;
      _activeSubscriptionId = data['productId'];
      
      if (data['expiryDate'] != null) {
        _expiryDate = (data['expiryDate'] as Timestamp).toDate();
        
        // Check if expired
        if (_expiryDate!.isBefore(DateTime.now())) {
          print('⚠️  Subscription expired');
          _isPremium = false;
          _activeSubscriptionId = null;
          _expiryDate = null;
        } else {
          print('✅ Premium active until: $_expiryDate');
        }
      }
    } catch (e) {
      print('❌ Error loading subscription: $e');
      _isPremium = false;
    }
  }

  /// Check if user has active subscription
  Future<bool> hasActiveSubscription(String userId) async {
    await loadSubscriptionFromFirestore(userId);
    return _isPremium;
  }

  /// Get subscription details
  Map<String, dynamic> getSubscriptionDetails() {
    return {
      'isPremium': _isPremium,
      'activeSubscriptionId': _activeSubscriptionId,
      'expiryDate': _expiryDate?.toIso8601String(),
      'daysRemaining': _expiryDate != null 
          ? _expiryDate!.difference(DateTime.now()).inDays 
          : 0,
    };
  }

  /// Dispose subscription service
  void dispose() {
    _subscription?.cancel();
    print('🔒 Subscription service disposed');
  }
}

/// iOS payment queue delegate
class ExamplePaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(SKPaymentTransactionWrapper transaction, SKStorefrontWrapper storefront) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return false;
  }
}
