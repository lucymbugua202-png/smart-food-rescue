import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF2E7D32);
  static const Color primaryLight = Color(0xFF4CAF50);
  static const Color primaryDark = Color(0xFF1B5E20);
  static const Color accent = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color background = Color(0xFFF5F5F5);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF757575);
  static const Color lightGrey = Color(0xFFE0E0E0);
}

class AppStrings {
  static const String appName = 'Smart Food Rescue';
  static const String tagline = 'Rescue Food, Feed Communities';
  
  static const String login = 'Login';
  static const String register = 'Register';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String forgotPassword = 'Forgot Password?';
  
  static const String donor = 'Food Donor';
  static const String recipient = 'Recipient';
  
  static const String totalDonations = 'Total Donations';
  static const String activeDonations = 'Active Donations';
  static const String totalPickups = 'Total Pickups';
  static const String availableFood = 'Available Food';
  static const String myRequests = 'My Requests';
}

class AppSizes {
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double borderRadius = 12.0;
  static const double buttonHeight = 50.0;
  static const double iconSize = 24.0;
  static const double iconSizeLarge = 32.0;
}

class AppRoutes {
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String donorDashboard = '/donor-dashboard';
  static const String recipientDashboard = '/recipient-dashboard';
  static const String addFood = '/add-food';
  static const String profile = '/profile';
  static const String settings = '/settings';
}
