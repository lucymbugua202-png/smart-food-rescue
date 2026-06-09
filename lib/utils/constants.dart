import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color secondaryGreen = Color(0xFF4CAF50);
  static const Color lightGreen = Color(0xFFC8E6C9);
  static const Color warningOrange = Color(0xFFFF9800);
  static const Color errorRed = Color(0xFFF44336);
}

class AppStrings {
  static const String appName = 'Smart Food Rescue';
  static const String tagline = 'Rescue Food, Feed Communities';
}

// Firebase Collections
class FirebaseCollections {
  static const String users = 'users';
  static const String foodItems = 'food_items';
  static const String pickupRequests = 'pickup_requests';
  static const String notifications = 'notifications';
}
// firestore.rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        (request.auth.uid == userId || 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.userType == 'admin');
    }
    
    // Food items collection
    match /food_items/{foodId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.userType == 'donor';
      allow update: if request.auth != null && 
        (resource.data.donorId == request.auth.uid ||
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.userType == 'admin');
      allow delete: if request.auth != null && 
        (resource.data.donorId == request.auth.uid ||
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.userType == 'admin');
    }
    
    // Pickup requests
    match /pickup_requests/{requestId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth != null;
    }
  }
}