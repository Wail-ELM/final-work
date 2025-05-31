import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String userId;
  final double size;
  final VoidCallback? onTap;

  const ProfileAvatar({
    super.key,
    required this.userId,
    this.size = 50,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          border: Border.all(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            // Avatar par défaut avec initiales ou icône
            Center(
              child: Icon(
                Icons.person,
                size: size * 0.6,
                color: Theme.of(context).primaryColor,
              ),
            ),
            // Indicateur d'édition si onTap est fourni
            if (onTap != null)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: size * 0.3,
                  height: size * 0.3,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    size: size * 0.15,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
