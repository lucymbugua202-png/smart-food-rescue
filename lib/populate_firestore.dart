// lib/populate_firestore.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  final firestore = FirebaseFirestore.instance;
  
  print('🔄 Starting to populate Firestore with sample food donations...');
  
  final sampleDonations = [
    {
      'donorId': 'donor_001',
      'donorName': 'Heavenly Bakery',
      'donorEmail': 'heavenly@bakery.com',
      'donorPhone': '+254712345678',
      'title': 'Fresh Bread Loaves',
      'description': 'Freshly baked whole wheat and white bread loaves. Perfect for immediate consumption.',
      'quantity': 25,
      'unit': 'loaves',
      'category': 'Bakery',
      'status': 'available',
      'expiryDate': Timestamp.now().add(const Duration(days: 2)),
      'pickupLocation': '123 Main Street, Nairobi',
      'pickupLatitude': -1.2921,
      'pickupLongitude': 36.8219,
      'imageUrl': 'https://example.com/bread.jpg',
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    },
    {
      'donorId': 'donor_002',
      'donorName': 'Green Grocers Supermarket',
      'donorEmail': 'contact@greengrocers.co.ke',
      'donorPhone': '+254798765432',
      'title': 'Mixed Fresh Vegetables',
      'description': 'Assorted fresh vegetables including tomatoes, onions, cabbage, and spinach.',
      'quantity': 50,
      'unit': 'kg',
      'category': 'Vegetables',
      'status': 'available',
      'expiryDate': Timestamp.now().add(const Duration(days: 1)),
      'pickupLocation': '45 Moi Avenue, Nairobi',
      'pickupLatitude': -1.2833,
      'pickupLongitude': 36.8233,
      'imageUrl': 'https://example.com/vegetables.jpg',
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    },
    {
      'donorId': 'donor_003',
      'donorName': 'City Hotel Restaurant',
      'donorEmail': 'kitchen@cityhotel.com',
      'donorPhone': '+254733445566',
      'title': 'Prepared Meals - Vegetarian',
      'description': 'Freshly prepared vegetarian meals including rice, beans, chapati, and vegetable curry.',
      'quantity': 30,
      'unit': 'plates',
      'category': 'Prepared Meals',
      'status': 'available',
      'expiryDate': Timestamp.now().add(const Duration(hours: 12)),
      'pickupLocation': '789 Kenyatta Avenue, Nairobi',
      'pickupLatitude': -1.2864,
      'pickupLongitude': 36.8172,
      'imageUrl': 'https://example.com/meals.jpg',
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    },
    {
      'donorId': 'donor_004',
      'donorName': 'Daily Fresh Dairy',
      'donorEmail': 'sales@dailyfreshdairy.com',
      'donorPhone': '+254722334455',
      'title': 'Dairy Products Pack',
      'description': 'Fresh milk (2L), yogurt cups (500g), and cheese blocks (250g).',
      'quantity': 40,
      'unit': 'liters/pieces',
      'category': 'Dairy',
      'status': 'available',
      'expiryDate': Timestamp.now().add(const Duration(days: 3)),
      'pickupLocation': '12 River Road, Nairobi',
      'pickupLatitude': -1.2809,
      'pickupLongitude': 36.8281,
      'imageUrl': 'https://example.com/dairy.jpg',
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    },
    {
      'donorId': 'donor_005',
      'donorName': 'Fresh Fruits Ltd',
      'donorEmail': 'orders@freshfruits.co.ke',
      'donorPhone': '+254711223344',
      'title': 'Assorted Fresh Fruits',
      'description': 'Bananas, oranges, apples, mangoes, and watermelons - all fresh and ripe.',
      'quantity': 100,
      'unit': 'kg',
      'category': 'Fruits',
      'status': 'available',
      'expiryDate': Timestamp.now().add(const Duration(days: 4)),
      'pickupLocation': '78 Kimathi Street, Nairobi',
      'pickupLatitude': -1.2775,
      'pickupLongitude': 36.8241,
      'imageUrl': 'https://example.com/fruits.jpg',
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    },
  ];
  
  print('📦 Adding ${sampleDonations.length} sample donations to Firestore...');
  
  int successCount = 0;
  int errorCount = 0;
  
  for (var donation in sampleDonations) {
    try {
      final docRef = await firestore.collection('donations').add(donation);
      print('✅ SUCCESS: Added "${donation['title']}" (ID: ${docRef.id})');
      successCount++;
    } catch (e) {
      print('❌ ERROR: Failed to add "${donation['title']}": $e');
      errorCount++;
    }
  }
  
  print('\n' + '='.toString() * 50);
  print('🎉 POPULATION COMPLETE!');
  print('='.toString() * 50);
  print('✅ Successful additions: $successCount');
  print('❌ Failed additions: $errorCount');
  
  // Verify the data was added
  final querySnapshot = await firestore.collection('donations').get();
  print('📊 Total donations now in Firestore: ${querySnapshot.docs.length}');
  
  // Display first donation as sample
  if (querySnapshot.docs.isNotEmpty) {
    print('\n📋 Sample donation from Firestore:');
    print('   ID: ${querySnapshot.docs.first.id}');
    print('   Data: ${querySnapshot.docs.first.data()}');
  }
  
  print('\n✨ You can now use this data in your Smart Food Rescue app!');
}

// Helper extension for string repetition
extension StringExtension on String {
  String operator *(int times) => List.filled(times, this).join();
}