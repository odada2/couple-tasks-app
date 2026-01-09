import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:couple_tasks/services/subscription_service.dart';
import 'package:couple_tasks/utils/app_theme.dart';

/// Paywall screen with Gottman-inspired design
/// 
/// Shows subscription options with warm, empathetic messaging
class PaywallScreen extends StatefulWidget {
  final bool canSkip;
  final VoidCallback? onSubscribed;
  final VoidCallback? onSkip;

  const PaywallScreen({
    Key? key,
    this.canSkip = true,
    this.onSubscribed,
    this.onSkip,
  }) : super(key: key);

  @override
  _PaywallScreenState createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> with SingleTickerProviderStateMixin {
  final SubscriptionService _subscriptionService = SubscriptionService.instance;
  
  List<ProductDetails> _products = [];
  ProductDetails? _selectedProduct;
  bool _isLoading = true;
  bool _isPurchasing = false;
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _setupAnimations();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
    });

    final products = await _subscriptionService.getProducts();
    
    // Sort: Annual first (recommended), then monthly
    products.sort((a, b) {
      if (a.id == SubscriptionService.annualProductId) return -1;
      if (b.id == SubscriptionService.annualProductId) return 1;
      return 0;
    });

    setState(() {
      _products = products;
      _selectedProduct = products.isNotEmpty ? products.first : null;
      _isLoading = false;
    });
  }

  Future<void> _purchaseSubscription() async {
    if (_selectedProduct == null || _isPurchasing) return;

    setState(() {
      _isPurchasing = true;
    });

    try {
      await _subscriptionService.purchaseSubscription(_selectedProduct!);
      
      // Wait for purchase to complete
      await Future.delayed(Duration(seconds: 2));
      
      widget.onSubscribed?.call();
      
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Purchase failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPurchasing = false;
        });
      }
    }
  }

  Future<void> _restorePurchases() async {
    try {
      await _subscriptionService.restorePurchases();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Purchases restored successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Restore failed: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                children: [
                  // Skip button
                  if (widget.canSkip)
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: Icon(Icons.close, color: Colors.grey),
                        onPressed: () {
                          widget.onSkip?.call();
                          Navigator.of(context).pop(false);
                        },
                      ),
                    ),
                  
                  SizedBox(height: 16),
                  
                  // Hero illustration
                  _buildHeroIllustration(),
                  
                  SizedBox(height: 32),
                  
                  // Headline
                  Text(
                    'Growing Together\nTakes Commitment',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textColor,
                      height: 1.2,
                    ),
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Subhead
                  Text(
                    'Invest in your partnership with tools designed to help you thrive as a team',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                  
                  SizedBox(height: 32),
                  
                  // Subscription plans
                  if (_isLoading)
                    CircularProgressIndicator(color: AppTheme.primaryColor)
                  else
                    ..._products.map((product) => _buildPlanCard(product)).toList(),
                  
                  SizedBox(height: 32),
                  
                  // Benefits
                  _buildBenefits(),
                  
                  SizedBox(height: 32),
                  
                  // CTA Button
                  _buildCTAButton(),
                  
                  SizedBox(height: 16),
                  
                  // Social proof
                  Text(
                    'Join 10,000+ couples building\nstronger relationships',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Footer links
                  _buildFooter(),
                ],
              ),
            ),
            
            // Loading overlay
            if (_isPurchasing)
              Container(
                color: Colors.black54,
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroIllustration() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor.withOpacity(0.2),
            AppTheme.secondaryColor.withOpacity(0.2),
          ],
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Left heart
            Positioned(
              left: 60,
              child: Icon(
                Icons.favorite,
                size: 60,
                color: AppTheme.primaryColor,
              ),
            ),
            // Right heart
            Positioned(
              right: 60,
              child: Icon(
                Icons.favorite,
                size: 60,
                color: AppTheme.secondaryColor,
              ),
            ),
            // Sparkle
            Icon(
              Icons.auto_awesome,
              size: 40,
              color: Colors.amber,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(ProductDetails product) {
    final isAnnual = product.id == SubscriptionService.annualProductId;
    final isSelected = _selectedProduct?.id == product.id;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedProduct = product;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        margin: EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Badge
                if (isAnnual)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.diamond, size: 12, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'BEST VALUE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                
                Spacer(),
                
                // Checkmark
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: AppTheme.primaryColor,
                    size: 24,
                  ),
              ],
            ),
            
            SizedBox(height: 12),
            
            // Plan name
            Text(
              isAnnual ? 'Annual' : 'Monthly',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
              ),
            ),
            
            SizedBox(height: 4),
            
            // Price
            Text(
              product.price,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            
            SizedBox(height: 4),
            
            // Savings or period
            if (isAnnual)
              Text(
                'Save \$10 • Just \$4.17/month',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.green[700],
                  fontWeight: FontWeight.w500,
                ),
              )
            else
              Text(
                'Billed monthly',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            
            SizedBox(height: 8),
            
            // Free trial
            Row(
              children: [
                Icon(Icons.check, size: 16, color: Colors.green),
                SizedBox(width: 4),
                Text(
                  '7 days free, then ${product.price}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefits() {
    final benefits = [
      {'icon': Icons.auto_awesome, 'text': 'Unlimited shared tasks and dreams'},
      {'icon': Icons.favorite, 'text': 'Loving nudges to stay connected'},
      {'icon': Icons.flag, 'text': 'Achieve your goals together'},
      {'icon': Icons.celebration, 'text': 'Celebrate your progress as a couple'},
      {'icon': Icons.lock, 'text': 'Private and secure - just for you two'},
    ];

    return Column(
      children: benefits.map((benefit) {
        return Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Icon(
                benefit['icon'] as IconData,
                color: AppTheme.primaryColor,
                size: 24,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  benefit['text'] as String,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textColor,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCTAButton() {
    return ScaleTransition(
      scale: _pulseAnimation,
      child: ElevatedButton(
        onPressed: _isPurchasing ? null : _purchaseSubscription,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 4,
          minimumSize: Size(double.infinity, 56),
        ),
        child: Text(
          'Start Your Journey Together',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        // Restore purchases
        TextButton(
          onPressed: _restorePurchases,
          child: Text(
            'Restore Purchase',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ),
        
        SizedBox(height: 8),
        
        // Terms and privacy
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                // Open terms
              },
              child: Text(
                'Terms',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ),
            Text('•', style: TextStyle(color: Colors.grey)),
            TextButton(
              onPressed: () {
                // Open privacy
              },
              child: Text(
                'Privacy',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
        
        SizedBox(height: 8),
        
        // Billing terms
        Text(
          'Cancel anytime in settings. Subscription auto-renews.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }
}
