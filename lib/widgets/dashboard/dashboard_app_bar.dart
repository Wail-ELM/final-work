import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/design_system.dart';

class DashboardAppBar extends ConsumerWidget {
  const DashboardAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: AppDesignSystem.primaryGradient,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(AppDesignSystem.radiusXLarge),
              bottomRight: Radius.circular(AppDesignSystem.radiusXLarge),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDesignSystem.space20,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Welkom terug! 👋',
                          style: AppDesignSystem.heading2.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: AppDesignSystem.space4),
                        Text(
                          _getGreetingSubtitle(),
                          style: AppDesignSystem.body2.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildUserAvatar(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserAvatar(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed('/profile');
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDesignSystem.radiusFull),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.person,
          color: AppDesignSystem.primaryGreen,
        ),
      ),
    );
  }

  String _getGreetingSubtitle() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Begin je dag met positiviteit.';
    } else if (hour < 18) {
      return 'Hoe gaat jouw middag?';
    } else {
      return 'Neem even tijd voor jezelf vanavond.';
    }
  }
}
