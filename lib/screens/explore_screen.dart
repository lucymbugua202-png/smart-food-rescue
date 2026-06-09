// lib/screens/explore_screen.dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Food'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.explore, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text(
              'Explore Screen',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text('Find food donations near you'),
          ],
        ),
      ),
    );
  }
}