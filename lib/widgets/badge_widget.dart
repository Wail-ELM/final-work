import 'package:flutter/material.dart' hide Badge;
import 'package:social_balans/models/badge.dart';

class BadgeWidget extends StatelessWidget {
  final Badge badge;

  const BadgeWidget({super.key, required this.badge});

  // A simple function to map icon names to actual icons.
  // This can be expanded as more badges are created.
  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'footprint':
        return Icons.directions_walk;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'military_tech':
        return Icons.military_tech;
      case 'center_focus_strong':
        return Icons.center_focus_strong;
      case 'phone_android':
        return Icons.phone_android;
      default:
        return Icons.star; // Default icon
    }
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message:
          '${badge.description}\n(Verdiend op ${badge.dateEarned.day}/${badge.dateEarned.month}/${badge.dateEarned.year})',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Icon(
              _getIcon(badge.iconName),
              size: 30,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            badge.title,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
 