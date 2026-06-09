import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/donation_model.dart';

class DonationProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<Donation> _featuredDonations = [];
  List<Donation> _allDonations = [];
  bool _isLoading = true;

  List<Donation> get featuredDonations => _featuredDonations;
  List<Donation> get allDonations => _allDonations;
  bool get isLoading => _isLoading;

  DonationProvider() {
    fetchFeaturedDonations();
    fetchAllDonations();
  }

  Future<void> fetchFeaturedDonations() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final snapshot = await _firestore
          .collection('donations')
          .where('status', isEqualTo: 'active')
          .limit(10)
          .get();
      
      _featuredDonations = snapshot.docs.map((doc) {
        final data = doc.data();
        return Donation(
          id: doc.id,
          donorId: data['donorId'] ?? '',
          title: data['title'] ?? 'Food Donation',
          description: data['description'] ?? '',
          quantity: (data['quantity'] ?? 0).toInt(),
          unit: data['unit'] ?? 'kg',
          category: data['category'] ?? 'Other',
          imageUrl: data['imageUrl'],
          expiryDate: (data['expiryDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
          pickupLocation: data['pickupLocation'] ?? '',
          location: data['location'],
          status: DonationStatus.values.firstWhere(
            (e) => e.toString().split('.').last == data['status'],
            orElse: () => DonationStatus.active,
          ),
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          claimedAt: data['claimedAt'] != null 
              ? (data['claimedAt'] as Timestamp).toDate() 
              : null,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error fetching featured donations: $e');
      // Mock data for demo
      _featuredDonations = [
        Donation(
          id: '1',
          donorId: 'donor1',
          title: 'Fresh Organic Vegetables',
          description: 'Fresh organic vegetables bundle',
          quantity: 50,
          unit: 'kg',
          category: 'Vegetables',
          imageUrl: null,
          expiryDate: DateTime.now().add(const Duration(days: 2)),
          pickupLocation: 'Downtown Food Bank',
          status: DonationStatus.active,
          createdAt: DateTime.now(),
        ),
        Donation(
          id: '2',
          donorId: 'donor2',
          title: 'Fresh Bread & Pastries',
          description: 'Freshly baked goods',
          quantity: 30,
          unit: 'pieces',
          category: 'Bakery',
          imageUrl: null,
          expiryDate: DateTime.now().add(const Duration(days: 1)),
          pickupLocation: 'Community Center',
          status: DonationStatus.active,
          createdAt: DateTime.now(),
        ),
        Donation(
          id: '3',
          donorId: 'donor3',
          title: 'Canned Goods Assortment',
          description: 'Assorted canned food',
          quantity: 100,
          unit: 'cans',
          category: 'Non-perishable',
          imageUrl: null,
          expiryDate: DateTime.now().add(const Duration(days: 365)),
          pickupLocation: 'Food Rescue HQ',
          status: DonationStatus.active,
          createdAt: DateTime.now(),
        ),
      ];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllDonations() async {
    try {
      final snapshot = await _firestore
          .collection('donations')
          .where('status', isEqualTo: 'active')
          .get();
      
      _allDonations = snapshot.docs.map((doc) {
        final data = doc.data();
        return Donation(
          id: doc.id,
          donorId: data['donorId'] ?? '',
          title: data['title'] ?? 'Food Donation',
          description: data['description'] ?? '',
          quantity: (data['quantity'] ?? 0).toInt(),
          unit: data['unit'] ?? 'kg',
          category: data['category'] ?? 'Other',
          imageUrl: data['imageUrl'],
          expiryDate: (data['expiryDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
          pickupLocation: data['pickupLocation'] ?? '',
          location: data['location'],
          status: DonationStatus.values.firstWhere(
            (e) => e.toString().split('.').last == data['status'],
            orElse: () => DonationStatus.active,
          ),
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          claimedAt: data['claimedAt'] != null 
              ? (data['claimedAt'] as Timestamp).toDate() 
              : null,
        );
      }).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching all donations: $e');
      _allDonations = List.from(_featuredDonations);
      notifyListeners();
    }
  }

  Future<void> addDonation(Donation donation) async {
    try {
      await _firestore.collection('donations').doc(donation.id).set(donation.toJson());
      await fetchAllDonations();
      await fetchFeaturedDonations();
    } catch (e) {
      debugPrint('Error adding donation: $e');
    }
  }

  Future<void> updateDonationStatus(String donationId, DonationStatus status) async {
    try {
      await _firestore.collection('donations').doc(donationId).update({
        'status': status.toString().split('.').last,
        if (status == DonationStatus.claimed) 'claimedAt': DateTime.now(),
      });
      await fetchAllDonations();
      await fetchFeaturedDonations();
    } catch (e) {
      debugPrint('Error updating donation status: $e');
    }
  }

  Future<List<Donation>> searchDonations(String query) async {
    if (query.isEmpty) return _allDonations;
    
    return _allDonations.where((donation) => 
      donation.title.toLowerCase().contains(query.toLowerCase()) ||
      donation.description.toLowerCase().contains(query.toLowerCase()) ||
      donation.category.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }
}
