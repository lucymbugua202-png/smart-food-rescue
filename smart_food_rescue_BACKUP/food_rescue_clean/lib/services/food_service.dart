import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/food_model.dart';

class FoodService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'foods';

  // Add food donation
  static Future<void> addFood(FoodModel food) async {
    try {
      await _firestore.collection(_collection).doc(food.id).set(food.toJson());
      
      // Update donor's total donations count
      await _firestore.collection('users').doc(food.donorId).update({
        'totalDonations': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error adding food: $e');
      rethrow;
    }
  }

  // Get donor's food items - simplified query without orderBy to avoid index
  static Stream<List<FoodModel>> getDonorFoods(String donorId) {
    return _firestore
        .collection(_collection)
        .where('donorId', isEqualTo: donorId)
        .snapshots()
        .map((snapshot) {
          List<FoodModel> foods = snapshot.docs.map((doc) {
            return FoodModel.fromJson(doc.data());
          }).toList();
          // Sort manually in memory
          foods.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return foods;
        });
  }

  // Get available food for recipients
  static Stream<List<FoodModel>> getAvailableFood() {
    return _firestore
        .collection(_collection)
        .where('status', isEqualTo: 'available')
        .snapshots()
        .map((snapshot) {
          List<FoodModel> foods = snapshot.docs.map((doc) {
            return FoodModel.fromJson(doc.data());
          }).toList();
          foods.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return foods;
        });
  }

  // Get food by ID
  static Future<FoodModel?> getFood(String foodId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection(_collection).doc(foodId).get();
      if (doc.exists) {
        return FoodModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting food: $e');
      return null;
    }
  }

  // Update food status
  static Future<void> updateFoodStatus(String foodId, String status) async {
    await _firestore.collection(_collection).doc(foodId).update({
      'status': status,
    });
  }

  // Delete food (cancel donation)
  static Future<void> deleteFood(String foodId) async {
    await _firestore.collection(_collection).doc(foodId).delete();
  }
}
