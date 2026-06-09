// lib/models/food_listing.dart
class FoodListing {
  final String id;
  final String donorName;
  final String foodItem;
  final String quantity;
  final String expiryDate;
  final String pickupLocation;
  final String status;

  const FoodListing({
    required this.id,
    required this.donorName,
    required this.foodItem,
    required this.quantity,
    required this.expiryDate,
    required this.pickupLocation,
    required this.status,
  });

  factory FoodListing.fromJson(Map<String, dynamic> json) {
    return FoodListing(
      id: json['id']?.toString() ?? '',
      donorName: json['donor_name']?.toString() ?? 'Unknown Donor',
      foodItem: json['food_item']?.toString() ?? 'Unknown Food',
      quantity: json['quantity']?.toString() ?? 'N/A',
      expiryDate: json['expiry_date']?.toString() ?? 'N/A',
      pickupLocation: json['pickup_location']?.toString() ?? 'N/A',
      status: json['status']?.toString() ?? 'available',
    );
  }
}