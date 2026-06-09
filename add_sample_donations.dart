// run_this_file.dart (Create this in your project root or bin folder)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  final firestore = FirebaseFirestore.instance;
  
  final sampleDonations = [
    {
      'donorId': 'sample_donor1',
      'donorName': 'Heavenly Bakery',
      'title': 'Fresh Organic Vegetables',
      'description': 'Fresh organic vegetables - carrots, tomatoes, lettuce, cucumbers',
      'quantity': 50,
      'unit': 'kg',
      'category': 'Vegetables',
      'status': 'available',
      'expiryDate': Timestamp.now().add(const Duration(days: 2)),
      'pickupLocation': 'Downtown Food Bank, 123 Main St',
      'createdAt': Timestamp.now(),
    },
    {
      'donorId': 'sample_donor2',
      'donorName': 'Green Grocers Supermarket',
      'title': 'Fresh Bread & Pastries',
      'description': 'Freshly baked bread, croissants, pastries, and cakes',
      'quantity': 30,
      'unit': 'pieces',
      'category': 'Bakery',
      'status': 'available',
      'expiryDate': Timestamp.now().add(const Duration(days: 1)),
      'pickupLocation': 'Community Center, 456 Oak Ave',
      'createdAt': Timestamp.now(),
    },
    {
      'donorId': 'sample_donor3',
      'donorName': 'Fresh Fruits Ltd',
      'title': 'Canned Goods Assortment',
      'description': 'Assorted canned vegetables, soups, beans, and fruits',
      'quantity': 100,
      'unit': 'cans',
      'category': 'Non-perishable',
      'status': 'available',
      'expiryDate': Timestamp.now().add(const Duration(days: 365)),
      'pickupLocation': 'Food Rescue HQ, 789 Pine St',
      'createdAt': Timestamp.now(),
    },
    {
      'donorId': 'sample_donor4',
      'donorName': 'City Hotel',
      'title': 'Prepared Meals - Vegetarian',
      'description': 'Freshly prepared vegetarian meals including rice, beans, and vegetables',
      'quantity': 50,
      'unit': 'plates',
      'category': 'Prepared Meals',
      'status': 'available',
      'expiryDate': Timestamp.now().add(const Duration(hours: 12)),
      'pickupLocation': '789 Kenyatta Avenue, Nairobi',
      'createdAt': Timestamp.now(),
    },
    {
      'donorId': 'sample_donor5',
      'donorName': 'Daily Fresh Dairy',
      'title': 'Dairy Products Pack',
      'description': 'Fresh milk, yogurt, and cheese products',
      'quantity': 40,
      'unit': 'liters',
      'category': 'Dairy',
      'status': 'available',
      'expiryDate': Timestamp.now().add(const Duration(days: 3)),
      'pickupLocation': '12 River Road, Nairobi',
      'createdAt': Timestamp.now(),
    },
  ];
  
  print('📦 Adding ${sampleDonations.length} sample donations to Firestore...');
  
  for (var donation in sampleDonations) {
    try {
      final docRef = await firestore.collection('donations').add(donation);
      print('✅ Added: ${donation['title']} (ID: ${docRef.id})');
    } catch (e) {
      print('❌ Error adding ${donation['title']}: $e');
    }
  }
  
  print('🎉 Sample donations added successfully!');
  
  // Verify the data was added
  final querySnapshot = await firestore.collection('donations').get();
  print('📊 Total donations in Firestore: ${querySnapshot.docs.length}');
}