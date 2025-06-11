import 'package:flutter/material.dart' hide ButtonStyle;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;
import '../services/notification_service.dart'; // Import NotificationService
import 'package:flutter/foundation.dart' show kIsWeb;
import '../core/design_system.dart'; // Import design system for wellness colors

class OnboardingScreen extends StatefulWidget {
  final VoidCallback? onDone;
  const OnboardingScreen({super.key, this.onDone});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<_OnboardingPageData> _pages = [
    _OnboardingPageData(
      icon: Icons.self_improvement,
      title: 'Welkom bij Social Balans',
      description:
          'Jouw digitale welzijn, opnieuw in balans. Minder schermtijd, meer leven.',
      color: AppDesignSystem.primaryGreen,
    ),
    _OnboardingPageData(
      icon: Icons.nightlight_round,
      title: 'Minder schermtijd, meer rust',
      description:
          'Ontdek hoe kleine gewoontes en challenges je helpen om bewuster met technologie om te gaan.',
      color: AppDesignSystem.secondaryBlue,
    ),
    _OnboardingPageData(
      icon: Icons.emoji_events,
      title: 'Persoonlijke uitdagingen',
      description:
          'Kies uit inspirerende uitdagingen, volg je voortgang en vier je successen.',
      color: AppDesignSystem.warning,
    ),
    _OnboardingPageData(
      icon: Icons.notifications_active,
      title: 'Blijf op de hoogte',
      description:
          'Activeer notificaties voor herinneringen, pauzes en het behalen van je doelen. Mis niets belangrijks!',
      color: AppDesignSystem.success,
      isPermissionPage: true,
    ),
    _OnboardingPageData(
      icon: Icons.bar_chart,
      title: 'Inzicht & Motivatie',
      description:
          'Bekijk je statistieken, ontvang motiverende tips en blijf op koers voor een gezonder digitaal leven.',
      color: AppDesignSystem.sageGreen,
    ),
  ];

  void _completeOnboarding() {
    // The parent widget is now responsible for handling the completion logic.
    if (widget.onDone != null) {
      widget.onDone!();
    } else if (mounted) {
      // Fallback navigation in case onDone is not provided.
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  Future<void> _requestNotificationPermission() async {
    bool granted = false;
    // Platform checks are not supported on the web.
    if (!kIsWeb) {
      if (Platform.isIOS) {
        granted = await NotificationService().requestIOSPermissions();
      } else {
        // For non-iOS, non-web platforms (like Android), assume granted for the flow.
        granted = true;
      }
    }

    // Move to next page regardless of outcome, not to block the user.
    if (mounted) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.ease,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesignSystem.neutral50,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, i) => _OnboardingPage(page: _pages[i]),
              ),
            ),
            // Modern page indicators
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == i ? 32 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: _currentPage == i
                          ? AppDesignSystem.primaryGradient
                          : null,
                      color:
                          _currentPage == i ? null : AppDesignSystem.neutral300,
                      borderRadius:
                          BorderRadius.circular(AppDesignSystem.radiusFull),
                      boxShadow: _currentPage == i
                          ? AppDesignSystem.shadowSmall
                          : null,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: () {
                        _controller.previousPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.ease,
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppDesignSystem.neutral600,
                      ),
                      child: const Text('Terug'),
                    ),
                  const Spacer(),
                  if (_pages[_currentPage].isPermissionPage)
                    ModernButton(
                      text: 'Notificaties activeren',
                      onPressed: _requestNotificationPermission,
                      icon: Icons.notifications_active,
                      style: ButtonStyle.success,
                    )
                  else if (_currentPage < _pages.length - 1)
                    ModernButton(
                      text: 'Volgende',
                      onPressed: () {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.ease,
                        );
                      },
                      icon: Icons.arrow_forward,
                    ),
                  if (_currentPage == _pages.length - 1)
                    ModernButton(
                      text: 'Aan de slag!',
                      onPressed: _completeOnboarding,
                      icon: Icons.rocket_launch,
                      style: ButtonStyle.success,
                    ),
                ],
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
  final Color color;
  final bool isPermissionPage;

  const _OnboardingPageData({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    this.isPermissionPage = false,
  });
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardingPageData page;
  const _OnboardingPage({required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Modern icon with gradient background
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  page.color.withOpacity(0.2),
                  page.color.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: AppDesignSystem.shadowMedium,
            ),
            child: Icon(
              page.icon,
              size: 56,
              color: page.color,
            ),
          ),
          const SizedBox(height: 40),
          Text(
            page.title,
            style: AppDesignSystem.heading2.copyWith(
              color: page.color,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            page.description,
            style: AppDesignSystem.body1.copyWith(
              color: AppDesignSystem.neutral600,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
