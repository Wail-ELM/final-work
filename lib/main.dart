// lib/main.dart
import 'package:flutter/material.dart';
import 'main_navigation.dart';
import 'theme.dart';

void main() => runApp(const SocialBalansApp());

class SocialBalansApp extends StatelessWidget {
  const SocialBalansApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Social Balans',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const MainNavigation(),
    );
  }
}
