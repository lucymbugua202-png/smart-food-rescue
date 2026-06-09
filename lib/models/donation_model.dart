enum DonationStatus { pending, active, claimed, completed, expired, rejected }

class Donation {
  final String id;
  final String donorId;
  final String title;
  final String description;
  final int quantity;
  final String unit;
  final String category;
  final String? imageUrl;
  final DateTime expiryDate;
  final String pickupLocation;
  final dynamic location;
  final DonationStatus status;
  final DateTime createdAt;
  final DateTime? claimedAt;

  Donation({
    required this.id,
    required this.donorId,
    required this.title,
    required this.description,
    required this.quantity,
    required this.unit,
    required this.category,
    this.imageUrl,
    required this.expiryDate,
    required this.pickupLocation,
    this.location,
    required this.status,
    required this.createdAt,
    this.claimedAt,
  });

  Map<String, dynamic> toJson() => {
    'donationId': id,
    'donorId': donorId,
    'title': title,
    'description': description,
    'quantity': quantity,
    'unit': unit,
    'category': category,
    'imageUrl': imageUrl,
    'expiryDate': expiryDate,
    'pickupLocation': pickupLocation,
    'location': location,
    'status': status.toString().split('.').last,
    'createdAt': createdAt,
    'claimedAt': claimedAt,
  };

  factory Donation.fromJson(Map<String, dynamic> json) => Donation(
    id: json['donationId'],
    donorId: json['donorId'],
    title: json['title'],
    description: json['description'],
    quantity: json['quantity'],
    unit: json['unit'],
    category: json['category'],
    imageUrl: json['imageUrl'],
    expiryDate: (json['expiryDate'] as DateTime),
    pickupLocation: json['pickupLocation'],
    location: json['location'],
    status: DonationStatus.values.firstWhere(
      (e) => e.toString().split('.').last == json['status']
    ),
    createdAt: json['createdAt'],
    claimedAt: json['claimedAt'],
  );
}
