// lib/populate_data_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PopulateDataScreen extends StatefulWidget {
  const PopulateDataScreen({super.key});

  @override
  State<PopulateDataScreen> createState() => _PopulateDataScreenState();
}

class _PopulateDataScreenState extends State<PopulateDataScreen> {
  bool _isLoading = false;
  String _message = '';
  int _successCount = 0;

  final List<Map<String, dynamic>> _sampleDonations = [
    {
      'donorId': 'donor_001',
      'donorName': 'Heavenly Bakery',
      'donorEmail': 'heavenly@bakery.com',
      'title': 'Fresh Bread Loaves',
      'description': 'Freshly baked whole wheat and white bread loaves.',
      'quantity': 25,
      'unit': 'loaves',
      'category': 'Bakery',
      'status': 'available',
      'pickupLocation': '123 Main Street, Nairobi',
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'donorId': 'donor_002',
      'donorName': 'Green Grocers Supermarket',
      'donorEmail': 'contact@greengrocers.co.ke',
      'title': 'Mixed Fresh Vegetables',
      'description': 'Assorted fresh vegetables including tomatoes, onions, cabbage.',
      'quantity': 50,
      'unit': 'kg',
      'category': 'Vegetables',
      'status': 'available',
      'pickupLocation': '45 Moi Avenue, Nairobi',
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'donorId': 'donor_003',
      'donorName': 'City Hotel Restaurant',
      'donorEmail': 'kitchen@cityhotel.com',
      'title': 'Prepared Meals - Vegetarian',
      'description': 'Freshly prepared vegetarian meals including rice and beans.',
      'quantity': 30,
      'unit': 'plates',
      'category': 'Prepared Meals',
      'status': 'available',
      'pickupLocation': '789 Kenyatta Avenue, Nairobi',
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'donorId': 'donor_004',
      'donorName': 'Daily Fresh Dairy',
      'donorEmail': 'sales@dailyfreshdairy.com',
      'title': 'Dairy Products Pack',
      'description': 'Fresh milk, yogurt cups, and cheese blocks.',
      'quantity': 40,
      'unit': 'liters',
      'category': 'Dairy',
      'status': 'available',
      'pickupLocation': '12 River Road, Nairobi',
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'donorId': 'donor_005',
      'donorName': 'Fresh Fruits Ltd',
      'donorEmail': 'orders@freshfruits.co.ke',
      'title': 'Assorted Fresh Fruits',
      'description': 'Bananas, oranges, apples, mangoes, and watermelons.',
      'quantity': 100,
      'unit': 'kg',
      'category': 'Fruits',
      'status': 'available',
      'pickupLocation': '78 Kimathi Street, Nairobi',
      'createdAt': FieldValue.serverTimestamp(),
    },
  ];

  Future<void> _populateFirestore() async {
    setState(() {
      _isLoading = true;
      _message = '';
      _successCount = 0;
    });

    try {
      final firestore = FirebaseFirestore.instance;
      
      for (var donation in _sampleDonations) {
        await firestore.collection('donations').add(donation);
        _successCount++;
        setState(() {});
      }

      setState(() {
        _message = '✅ Successfully added $_successCount food donations to Firestore!';
      });
    } catch (e) {
      setState(() {
        _message = '❌ Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Populate Firestore Data'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_upload,
              size: 80,
              color: Colors.green,
            ),
            const SizedBox(height: 24),
            const Text(
              'Add Sample Food Donations',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'This will add 5 sample food donations to your Firestore database.\n\n'
              'You can use this data to test your Smart Food Rescue app.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            if (_isLoading)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: _populateFirestore,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Add Sample Data',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            const SizedBox(height: 16),
            if (_message.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _message.contains('✅') ? Colors.green.shade50 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _message.contains('✅') ? Colors.green : Colors.red,
                  ),
                ),
              ),
            if (_successCount > 0)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  'Added: $_successCount / ${_sampleDonations.length}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}