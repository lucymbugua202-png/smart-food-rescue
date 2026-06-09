import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_food_rescue/providers/app_auth_provider.dart';
import 'package:smart_food_rescue/screens/auth/login_screen.dart';
import 'package:smart_food_rescue/screens/dashboards/admin_dashboard.dart';
import 'package:smart_food_rescue/screens/dashboards/donor_dashboard.dart';
import 'package:smart_food_rescue/screens/dashboards/recipient_dashboard.dart';
import 'package:smart_food_rescue/models/user_model.dart';
import 'package:smart_food_rescue/themes/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AppAuthProvider>(context);
    final user = authProvider.currentUser;

    if (user == null) {
      return _buildLoginPrompt(context);
    }

    // Debug print to see the role
    print('User role in ProfileScreen: ${user.role}');
    
    // Show role-specific dashboard
    switch (user.role) {
      case UserRole.administrator:
        return const AdminDashboard();
      case UserRole.donor:
        return const DonorDashboard();
      case UserRole.recipient:
        return const RecipientDashboard();
      default:
        return const DonorDashboard();
    }
  }

  Widget _buildLoginPrompt(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                size: 50,
                color: AppTheme.primaryGreen,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Welcome to Smart Food Rescue',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sign in to access your profile, donate food, request donations, and track your impact on reducing food waste.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Sign In / Create Account'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
