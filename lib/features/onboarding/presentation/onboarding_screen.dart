import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../main.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPageData> _pages = [
    const _OnboardingPageData(
      icon: Icons.tv,
      title: 'Control Any Smart TV',
      description:
          'Works with Samsung, LG, Android TV, Roku, Fire TV, Vizio, and Sony TVs.',
    ),
    const _OnboardingPageData(
      icon: Icons.wifi,
      title: 'WiFi Connected',
      description:
          'No IR blaster needed. Just connect to the same WiFi network as your TV.',
    ),
    const _OnboardingPageData(
      icon: Icons.block,
      title: 'No Ads. No Subscriptions.',
      description:
          'This app is completely free. No hidden costs, no annoying ads, no premium features.',
    ),
    const _OnboardingPageData(
      icon: Icons.favorite,
      title: 'Made By Users, For Users',
      description:
          'We built this because other remote apps were frustrating. If you like it, please leave a review!',
    ),
  ];

  Future<void> _completeOnboarding() async {
    HapticFeedback.mediumImpact();
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(StorageKeys.hasSeenOnboarding, true);
    if (mounted) {
      context.go(AppRoutes.discovery);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = NeumorphicColors.getBackground(context);
    final shadowDark = NeumorphicColors.getShadowDark(context);
    final shadowLight = NeumorphicColors.getShadowLight(context);
    final textSecondary = NeumorphicColors.getTextSecondary(context);
    final textPrimary = NeumorphicColors.getTextPrimary(context);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: NeumorphicButton(
                  onPressed: _completeOnboarding,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      color: textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  HapticFeedback.selectionClick();
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) => _OnboardingPage(
                  data: _pages[index],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 28 : 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _currentPage == index ? AppTheme.accentColor : bgColor,
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                          color: shadowDark,
                          offset: const Offset(2, 2),
                          blurRadius: 4,
                        ),
                        BoxShadow(
                          color: shadowLight,
                          offset: const Offset(-2, -2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: SizedBox(
                width: double.infinity,
                child: NeumorphicButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    if (_currentPage < _pages.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _completeOnboarding();
                    }
                  },
                  accentColor: _currentPage == _pages.length - 1
                      ? AppTheme.accentColor
                      : null,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Text(
                    _currentPage < _pages.length - 1 ? 'Next' : 'Get Started',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _currentPage == _pages.length - 1
                          ? Colors.white
                          : textPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageData {
  final IconData icon;
  final String title;
  final String description;

  const _OnboardingPageData({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardingPageData data;

  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    final textPrimary = NeumorphicColors.getTextPrimary(context);
    final textSecondary = NeumorphicColors.getTextSecondary(context);

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          NeumorphicIconButton(
            onPressed: () {},
            icon: data.icon,
            size: 120,
            isAccent: true,
          ),
          const SizedBox(height: 48),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
