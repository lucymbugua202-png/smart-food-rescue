import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../utils/constants.dart';
import '../../services/food_service.dart';
import '../../services/request_service.dart';
import '../../services/user_service.dart';
import '../../services/chat_service.dart';
import '../../models/food_model.dart';
import '../../models/request_model.dart';
import 'food_detail_screen.dart';
import 'my_requests_screen.dart';
import '../common/notifications_screen.dart';
import '../common/messages_screen.dart';

class RecipientDashboard extends StatefulWidget {
  const RecipientDashboard({super.key});

  @override
  State<RecipientDashboard> createState() => _RecipientDashboardState();
}

class _RecipientDashboardState extends State<RecipientDashboard> {
  final user = FirebaseAuth.instance.currentUser;
  String? recipientName;
  String? recipientPhone;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  int _unreadCount = 0;
  int _unreadMessageCount = 0;
  
  final List<String> _categories = [
    'All', 'Vegetables', 'Fruits', 'Grains', 'Dairy', 
    'Meat', 'Baked Goods', 'Prepared Meals', 'Other'
  ];

  @override
  void initState() {
    super.initState();
    _loadRecipientData();
    _loadUnreadCount();
    _loadUnreadMessageCount();
  }

  Future<void> _loadRecipientData() async {
    final userData = await UserService.getUser(user!.uid);
    setState(() {
      recipientName = userData?.name ?? user?.email;
      recipientPhone = userData?.phone ?? '';
    });
  }

  Future<void> _loadUnreadCount() async {
    final notifications = await FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: user!.uid)
        .where('isRead', isEqualTo: false)
        .get();
    setState(() {
      _unreadCount = notifications.docs.length;
    });
  }

  Future<void> _loadUnreadMessageCount() async {
    final count = await ChatService.getUnreadCount(user!.uid);
    setState(() {
      _unreadMessageCount = count;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Available Food'),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
        actions: [
          // Messages Button with Badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.message_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MessagesScreen()),
                  ).then((_) => _loadUnreadMessageCount());
                },
                tooltip: 'Messages',
              ),
              if (_unreadMessageCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      _unreadMessageCount > 9 ? '9+' : '$_unreadMessageCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          
          // Notification Bell with Badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                  ).then((_) => _loadUnreadCount());
                },
                tooltip: 'Notifications',
              ),
              if (_unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      _unreadCount > 9 ? '9+' : '$_unreadCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          
          // My Requests Button
          IconButton(
            icon: const Icon(Icons.history_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyRequestsScreen()),
              );
            },
            tooltip: 'My Requests',
          ),
          
          // Logout Button
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            tooltip: 'Logout',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Welcome Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primaryLight],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, ${recipientName?.split(' ')[0] ?? 'Friend'}!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Find free food donations near you',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: InputDecoration(
                      hintText: 'Search food...',
                      prefixIcon: const Icon(Icons.search, color: AppColors.grey),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: AppColors.grey),
                              onPressed: () => setState(() => _searchQuery = ''),
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((category) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category),
                          selected: _selectedCategory == category,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = selected ? category : 'All';
                            });
                          },
                          selectedColor: AppColors.primary.withOpacity(0.15),
                          checkmarkColor: AppColors.primary,
                          backgroundColor: Colors.white,
                          side: BorderSide(
                            color: _selectedCategory == category 
                                ? AppColors.primary 
                                : AppColors.lightGrey,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          
          // Food List
          Expanded(
            child: StreamBuilder(
              stream: FoodService.getAvailableFood(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                var foods = snapshot.data!;
                
                if (_searchQuery.isNotEmpty) {
                  foods = foods.where((food) =>
                    food.title.toLowerCase().contains(_searchQuery.toLowerCase())
                  ).toList();
                }
                
                if (_selectedCategory != 'All') {
                  foods = foods.where((food) => food.category == _selectedCategory).toList();
                }
                
                if (foods.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: AppColors.grey.withOpacity(0.5)),
                        const SizedBox(height: 16),
                        const Text(
                          'No food items found',
                          style: TextStyle(fontSize: 16, color: AppColors.grey),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isNotEmpty 
                              ? 'Try a different search term' 
                              : 'Check back later for new donations',
                          style: TextStyle(fontSize: 14, color: AppColors.grey),
                        ),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: foods.length,
                  itemBuilder: (context, index) {
                    final food = foods[index];
                    return _buildFoodCard(food);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodCard(FoodModel food) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FoodDetailScreen(food: food),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary.withOpacity(0.1), AppColors.primaryLight.withOpacity(0.05)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getCategoryIcon(food.category),
                      color: AppColors.primary,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          food.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${food.quantity} ${food.unit}',
                          style: TextStyle(fontSize: 13, color: AppColors.grey),
                        ),
                      ],
                    ),
                  ),
                  if (food.isUrgent)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.error, AppColors.error],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'URGENT',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.store_outlined, size: 14, color: AppColors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      food.donorName,
                      style: TextStyle(fontSize: 12, color: AppColors.grey),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: AppColors.grey),
                  const SizedBox(width: 4),
                  Text(
                    _getExpiryText(food.expiryDate),
                    style: TextStyle(
                      fontSize: 12,
                      color: food.isExpiringSoon ? AppColors.warning : AppColors.grey,
                      fontWeight: food.isExpiringSoon ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _requestFood(food),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('Request This Food'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Vegetables': return Icons.eco_outlined;
      case 'Fruits': return Icons.apple;
      case 'Dairy': return Icons.egg_outlined;
      case 'Meat': return Icons.restaurant;
      case 'Baked Goods': return Icons.bakery_dining;
      default: return Icons.food_bank_outlined;
    }
  }

  String _getExpiryText(DateTime expiryDate) {
    final daysLeft = expiryDate.difference(DateTime.now()).inDays;
    if (daysLeft <= 0) return 'Expired';
    if (daysLeft == 1) return 'Expires tomorrow';
    if (daysLeft <= 3) return 'Expires in $daysLeft days';
    return 'Expires on ${expiryDate.month}/${expiryDate.day}';
  }

  void _requestFood(FoodModel food) async {
    if (recipientPhone == null || recipientPhone!.isEmpty) {
      _showPhoneNumberDialog(food);
      return;
    }
    _confirmRequest(food);
  }

  void _showPhoneNumberDialog(FoodModel food) {
    final phoneController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Phone Number Required'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide your phone number for pickup coordination:'),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              await UserService.updateUser(user!.uid, {
                'phone': phoneController.text,
              });
              setState(() {
                recipientPhone = phoneController.text;
              });
              Navigator.pop(context);
              _confirmRequest(food);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Save & Continue'),
          ),
        ],
      ),
    );
  }

  void _confirmRequest(FoodModel food) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Request'),
        content: Text('Would you like to request "${food.title}"?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sending request...')),
              );
              
              final request = RequestModel(
                id: const Uuid().v4(),
                foodId: food.id,
                foodTitle: food.title,
                donorId: food.donorId,
                donorName: food.donorName,
                recipientId: user!.uid,
                recipientName: recipientName ?? user!.email!,
                recipientPhone: recipientPhone ?? '',
                status: 'pending',
                createdAt: DateTime.now(),
              );
              
              await RequestService.createRequest(request);
              
              if (mounted) {
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Request for "${food.title}" sent!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}