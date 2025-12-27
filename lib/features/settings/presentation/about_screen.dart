import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _requestReview() async {
    final inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      await inAppReview.requestReview();
    } else {
      await inAppReview.openStoreListing();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textPrimary = NeumorphicColors.getTextPrimary(context);
    final textSecondary = NeumorphicColors.getTextSecondary(context);
    final textMuted = NeumorphicColors.getTextMuted(context);

    return Scaffold(
      backgroundColor: NeumorphicColors.getBackground(context),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    NeumorphicIconButton(
                      onPressed: () {},
                      icon: Icons.tv,
                      size: 100,
                      isAccent: true,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      AppConstants.appName,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Version ${AppConstants.appVersion}',
                      style: TextStyle(
                        fontSize: 14,
                        color: textSecondary,
                      ),
                    ),
                    const SizedBox(height: 32),
                    NeumorphicContainer(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          NeumorphicIconButton(
                            onPressed: () {},
                            icon: Icons.favorite,
                            size: 56,
                            iconColor: AppTheme.errorColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Developed by shadowregister',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'This app was created because we were tired of TV remote apps '
                            'that are full of ads, require subscriptions, or are just annoying to use. '
                            'We wanted something simple, fast, and free.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: textSecondary,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _ActionButton(
                      icon: Icons.star,
                      label: 'Rate this app',
                      onTap: () {
                        HapticFeedback.lightImpact();
                        _requestReview();
                      },
                    ),
                    const SizedBox(height: 12),
                    _ActionButton(
                      icon: Icons.coffee,
                      label: 'Buy me a coffee',
                      onTap: () {
                        HapticFeedback.lightImpact();
                        _launchUrl(AppConstants.buyMeACoffeeUrl);
                      },
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'No ads. No subscriptions. Forever free.',
                      style: TextStyle(
                        fontSize: 13,
                        color: textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final textPrimary = NeumorphicColors.getTextPrimary(context);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          NeumorphicIconButton(
            onPressed: () => context.pop(),
            icon: Icons.arrow_back_ios_new,
            size: 44,
          ),
          const SizedBox(width: 16),
          Text(
            'About',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bgColor = NeumorphicColors.getBackground(context);
    final shadowDark = NeumorphicColors.getShadowDark(context);
    final shadowLight = NeumorphicColors.getShadowLight(context);
    final textPrimary = NeumorphicColors.getTextPrimary(context);
    final textMuted = NeumorphicColors.getTextMuted(context);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: _isPressed
              ? null
              : [
                  BoxShadow(
                    color: shadowDark,
                    offset: const Offset(5, 5),
                    blurRadius: 10,
                  ),
                  BoxShadow(
                    color: shadowLight,
                    offset: const Offset(-5, -5),
                    blurRadius: 10,
                  ),
                ],
        ),
        child: Row(
          children: [
            Icon(widget.icon, color: AppTheme.accentColor),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                widget.label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.open_in_new,
              size: 18,
              color: textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
