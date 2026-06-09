// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/food_listing.dart';

class ApiService {
  static const String baseUrl = 'https://6a2784daa84f9d39e908ab92.mockapi.io';
  
  static Future<List<FoodListing>> getFoodListings() async {
    final url = Uri.parse('$baseUrl/food-listings');
    
    print('📡 Fetching from: $url');
    
    try {
      final response = await http.get(url);
      
      print('📊 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final responseBody = response.body.trim();
        
        // Handle empty response
        if (responseBody.isEmpty || responseBody == '[]') {
          print('⚠️ No data found in MockAPI');
          return [];
        }
        
        // Parse JSON
        final jsonList = jsonDecode(responseBody);
        
        // Check if response is a List
        if (jsonList is List) {
          if (jsonList.isEmpty) {
            print('⚠️ Empty list returned');
            return [];
          }
          
          print('✅ Loaded ${jsonList.length} food items');
          return jsonList.map((json) => FoodListing.fromJson(json)).toList();
        } else if (jsonList is Map) {
          // If response is a single object instead of list
          print('✅ Loaded 1 food item (single object)');
          return [FoodListing.fromJson(jsonList)];
        } else {
          print('❌ Unexpected response type');
          return [];
        }
      } else if (response.statusCode == 404) {
        print('❌ Resource not found. Check if "food-listings" exists');
        return [];
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Network Error: $e');
      return [];
    }
  }

  // Add this method to create a new food listing
  static Future<Map<String, dynamic>?> createFoodListing(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/food-listings');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      
      if (response.statusCode == 201) {
        print('✅ Food listing created successfully');
        return jsonDecode(response.body);
      } else {
        print('❌ Failed to create: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Error creating: $e');
      return null;
    }
  }
}