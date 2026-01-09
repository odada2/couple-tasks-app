import 'package:flutter/material.dart';
import 'package:couple_tasks/services/subscription_service.dart';
import 'package:couple_tasks/screens/paywall_screen.dart';
import 'package:couple_tasks/utils/app_theme.dart';

/// Widget to gate premium features
/// 
/// Shows paywall if user is not premium
class PremiumGate extends StatelessWidget {
  final Widget child;
  final String featureName;
  final VoidCallback? onPremiumGranted;

  const PremiumGate({
    Key? key,
    required this.child,
    required this.featureName,
    this.onPremiumGranted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final subscriptionService = SubscriptionService.instance;

    if (subscriptionService.isPremium) {
      return child;
    }

    return GestureDetector(
      onTap: () => _showPaywall(context),
      child: Stack(
        children: [
          // Blurred/locked content
          Opacity(
            opacity: 0.3,
            child: AbsorbPointer(
              child: child,
            ),
          ),
          
          // Lock overlay
          Center(
            child: Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock,
                    size: 48,
                    color: AppTheme.primaryColor,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Premium Feature',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Unlock $featureName with premium',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _showPaywall(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Text('Upgrade Now'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showPaywall(BuildContext context) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PaywallScreen(
          canSkip: true,
          onSubscribed: onPremiumGranted,
        ),
        fullscreenDialog: true,
      ),
    );

    if (result == true) {
      onPremiumGranted?.call();
    }
  }
}

/// Button to show paywall
class UpgradeButton extends StatelessWidget {
  final String text;
  final VoidCallback? onUpgraded;

  const UpgradeButton({
    Key? key,
    this.text = 'Upgrade to Premium',
    this.onUpgraded,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _showPaywall(context),
      icon: Icon(Icons.diamond, size: 20),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }

  Future<void> _showPaywall(BuildContext context) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PaywallScreen(
          canSkip: true,
          onSubscribed: onUpgraded,
        ),
        fullscreenDialog: true,
      ),
    );

    if (result == true) {
      onUpgraded?.call();
    }
  }
}

/// Premium badge widget
class PremiumBadge extends StatelessWidget {
  final double size;

  const PremiumBadge({
    Key? key,
    this.size = 24,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber, Colors.orange],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.diamond, size: size * 0.7, color: Colors.white),
          SizedBox(width: 4),
          Text(
            'PRO',
            style: TextStyle(
              fontSize: size * 0.5,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// Check if feature is available
Future<bool> checkPremiumAccess(BuildContext context, String featureName) async {
  final subscriptionService = SubscriptionService.instance;

  if (subscriptionService.isPremium) {
    return true;
  }

  // Show paywall
  final result = await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => PaywallScreen(
        canSkip: true,
      ),
      fullscreenDialog: true,
    ),
  );

  return result == true;
}
