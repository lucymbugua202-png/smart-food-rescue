// lib/screens/test_api_screen.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/food_listing.dart';

class TestApiScreen extends StatefulWidget {
  const TestApiScreen({super.key});

  @override
  State<TestApiScreen> createState() => _TestApiScreenState();
}

class _TestApiScreenState extends State<TestApiScreen> {
  List<FoodListing> foodList = [];
  bool loading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() {
      loading = true;
      error = '';
    });

    final data = await ApiService.getFoodListings();
    
    setState(() {
      foodList = data;
      loading = false;
      if (data.isEmpty) {
        error = 'No food found. Check MockAPI.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Food Rescue'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadData,
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.warning, size: 64, color: Colors.orange),
                      const SizedBox(height: 16),
                      Text(error),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: loadData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : foodList.isEmpty
                  ? const Center(
                      child: Text('No food donations available'),
                    )
                  : ListView.builder(
                      itemCount: foodList.length,
                      padding: const EdgeInsets.all(8),
                      itemBuilder: (context, index) {
                        final food = foodList[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.green,
                              child: Text(
                                food.foodItem[0].toUpperCase(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(food.foodItem),
                            subtitle: Text('${food.donorName} • ${food.quantity}'),
                            trailing: Chip(
                              label: Text(food.status),
                              backgroundColor: Colors.green.shade100,
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}