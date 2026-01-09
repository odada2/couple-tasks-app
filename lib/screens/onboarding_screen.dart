import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Our Philosophy',
      subtitle: 'Communication with Kindness',
      description:
          'Speak from the heart. Our tools help you express needs without the friction.',
      icon: '💬',
      color: AppTheme.lightPink,
    ),
    OnboardingPage(
      title: 'Onboarding',
      subtitle: 'Teamwork over Taskwork',
      description:
          'Shared goals bring you closer. Tackle chores together and make time for what matters.',
      icon: '🤝',
      color: AppTheme.softPeach,
    ),
    OnboardingPage(
      title: 'Our Philosophy',
      subtitle: 'Celebrating Each Other',
      description:
          'Small wins deserve big cheers. Send loving nudges and celebrate every task you finish together.',
      icon: '🏆',
      color: AppTheme.lightPink,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _pages[_currentPage].title,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  TextButton(
                    onPressed: () => _skipToEnd(),
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: AppTheme.primaryPink,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),

            // Page indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => _buildIndicator(index == _currentPage),
              ),
            ),

            const SizedBox(height: 32),

            // Get Started button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentPage < _pages.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _skipToEnd();
                    }
                  },
                  child: Text(_currentPage < _pages.length - 1
                      ? 'Get Started'
                      : "Let's Begin"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon container
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: page.color,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: Text(
                page.icon,
                style: const TextStyle(fontSize: 80),
              ),
            ),
          ),

          const SizedBox(height: 48),

          // Title
          Text(
            page.subtitle,
            style: Theme.of(context).textTheme.displaySmall,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Description
          Text(
            page.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.mediumGray,
                  height: 1.5,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primaryPink : AppTheme.mediumGray,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  void _skipToEnd() {
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class OnboardingPage {
  final String title;
  final String subtitle;
  final String description;
  final String icon;
  final Color color;

  OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
  });
}
