import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;
import '../services/notification_service.dart'; // Import NotificationService
import 'package:flutter/foundation.dart' show kIsWeb;

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
      color: Colors.blueAccent,
    ),
    _OnboardingPageData(
      icon: Icons.nightlight_round,
      title: 'Minder schermtijd, meer rust',
      description:
          'Ontdek hoe kleine gewoontes en challenges je helpen om bewuster met technologie om te gaan.',
      color: Colors.teal,
    ),
    _OnboardingPageData(
      icon: Icons.emoji_events,
      title: 'Persoonlijke uitdagingen',
      description:
          'Kies uit inspirerende uitdagingen, volg je voortgang en vier je successen.',
      color: Colors.orange,
    ),
    _OnboardingPageData(
      icon: Icons.notifications_active,
      title: 'Blijf op de hoogte',
      description:
          'Activeer notificaties voor herinneringen, pauzes en het behalen van je doelen. Mis niets belangrijks!',
      color: Colors.green,
      isPermissionPage: true,
    ),
    _OnboardingPageData(
      icon: Icons.bar_chart,
      title: 'Inzicht & Motivatie',
      description:
          'Bekijk je statistieken, ontvang motiverende tips en blijf op koers voor een gezonder digitaal leven.',
      color: Colors.purple,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
                  width: _currentPage == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == i
                        ? Theme.of(context).primaryColor
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
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
                      child: const Text('Terug'),
                    ),
                  const Spacer(),
                  if (_pages[_currentPage].isPermissionPage)
                    ElevatedButton(
                      onPressed: _requestNotificationPermission,
                      child: const Text('Notificaties activeren'),
                    )
                  else if (_currentPage < _pages.length - 1)
                    ElevatedButton(
                      onPressed: () {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.ease,
                        );
                      },
                      child: const Text('Volgende'),
                    ),
                  if (_currentPage == _pages.length - 1)
                    ElevatedButton(
                      onPressed: _completeOnboarding,
                      child: const Text('Aan de slag!'),
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
          CircleAvatar(
            radius: 48,
            backgroundColor: page.color.withOpacity(0.15),
            child: Icon(page.icon, size: 56, color: page.color),
          ),
          const SizedBox(height: 32),
          Text(
            page.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: page.color,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            page.description,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
