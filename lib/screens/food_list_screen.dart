// lib/screens/food_list_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FoodListScreen extends StatelessWidget {
  const FoodListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🍽️ Available Food Donations'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('donations')
            .where('status', isEqualTo: 'available')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final donations = snapshot.data!.docs;

          if (donations.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.food_bank, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No food donations available',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  Text(
                    'Check back later!',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: donations.length,
            itemBuilder: (context, index) {
              final donation = donations[index];
              final data = donation.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: CircleAvatar(
                    backgroundColor: Colors.green,
                    radius: 28,
                    child: Text(
                      data['title']?.isNotEmpty == true
                          ? data['title'][0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    data['title'] ?? 'Unknown Food',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('🏪 ${data['donorName'] ?? 'Unknown Donor'}'),
                      Text('📦 ${data['quantity']} ${data['unit'] ?? ''}'),
                      Text('📍 ${data['pickupLocation'] ?? 'No location'}'),
                      if (data['expiryDate'] != null)
                        Text(
                          '⏰ Expires: ${_formatDate(data['expiryDate'])}',
                          style: const TextStyle(fontSize: 12),
                        ),
                    ],
                  ),
                  trailing: Chip(
                    label: Text(
                      data['status']?.toUpperCase() ?? 'AVAILABLE',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                    backgroundColor: Colors.green,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  isThreeLine: true,
                  onTap: () {
                    _showFoodDetails(context, donation.id, data);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _showFoodDetails(BuildContext context, String id, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(data['title'] ?? 'Food Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🍽️ Donor: ${data['donorName'] ?? 'Unknown'}'),
            const SizedBox(height: 8),
            Text('📧 Email: ${data['donorEmail'] ?? 'N/A'}'),
            const SizedBox(height: 8),
            Text('📦 Quantity: ${data['quantity']} ${data['unit'] ?? ''}'),
            const SizedBox(height: 8),
            Text('📍 Pickup: ${data['pickupLocation'] ?? 'N/A'}'),
            const SizedBox(height: 8),
            if (data['expiryDate'] != null)
              Text('⏰ Expires: ${_formatDate(data['expiryDate'])}'),
            const SizedBox(height: 8),
            Text('📝 ${data['description'] ?? 'No description available'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (data['status'] == 'available')
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _claimFood(context, id);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('Claim Food'),
            ),
        ],
      ),
    );
  }

  void _claimFood(BuildContext context, String donationId) {
    FirebaseFirestore.instance
        .collection('donations')
        .doc(donationId)
        .update({'status': 'claimed'}).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Food claimed! Please arrange pickup.'),
          backgroundColor: Colors.green,
        ),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: $error'),
          backgroundColor: Colors.red,
        ),
      );
    });
  }
}