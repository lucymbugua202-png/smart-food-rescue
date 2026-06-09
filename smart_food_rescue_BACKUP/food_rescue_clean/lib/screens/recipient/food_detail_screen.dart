import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../models/food_model.dart';

class FoodDetailScreen extends StatelessWidget {
  final FoodModel food;

  const FoodDetailScreen({super.key, required this.food});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(food.title),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Image Placeholder
            Container(
              height: 200,
              width: double.infinity,
              color: AppColors.primary.withOpacity(0.1),
              child: const Center(
                child: Icon(
                  Icons.food_bank,
                  size: 80,
                  color: AppColors.primary,
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Urgent Badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          food.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (food.isUrgent)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'URGENT',
                            style: TextStyle(
                              color: AppColors.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Donor Info
                  _buildInfoTile(
                    icon: Icons.store,
                    label: 'Donated by',
                    value: food.donorName,
                  ),
                  const SizedBox(height: 12),
                  
                  // Quantity
                  _buildInfoTile(
                    icon: Icons.scale,
                    label: 'Quantity',
                    value: '${food.quantity} ${food.unit}',
                  ),
                  const SizedBox(height: 12),
                  
                  // Category
                  _buildInfoTile(
                    icon: Icons.category,
                    label: 'Category',
                    value: food.category,
                  ),
                  const SizedBox(height: 12),
                  
                  // Expiry Date
                  _buildInfoTile(
                    icon: Icons.calendar_today,
                    label: 'Expiry Date',
                    value: _formatDate(food.expiryDate),
                    valueColor: food.isExpiringSoon ? AppColors.warning : null,
                  ),
                  const SizedBox(height: 12),
                  
                  // Pickup Address
                  _buildInfoTile(
                    icon: Icons.location_on,
                    label: 'Pickup Address',
                    value: food.pickupAddress,
                  ),
                  const SizedBox(height: 16),
                  
                  // Description
                  if (food.description.isNotEmpty) ...[
                    const Divider(),
                    const SizedBox(height: 8),
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      food.description,
                      style: const TextStyle(height: 1.5),
                    ),
                  ],
                  
                  const SizedBox(height: 32),
                  
                  // Request Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showRequestDialog(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Request This Food',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: AppColors.grey),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  void _showRequestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Request'),
        content: Text('Would you like to request "${food.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Request for "${food.title}" sent!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
