import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/app_auth_provider.dart';
import '../../models/user_model.dart';
import '../../themes/app_theme.dart';
import '../../services/image_upload_service.dart';

class DonorDashboard extends StatefulWidget {
  const DonorDashboard({super.key});

  @override
  State<DonorDashboard> createState() => _DonorDashboardState();
}

class _DonorDashboardState extends State<DonorDashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedMenuIndex = 0;
  
  // Donor Stats
  int _totalDonations = 0;
  int _activeDonations = 0;
  int _completedDonations = 0;
  int _pendingRequests = 0;
  int _mealsDonated = 0;
  int _peopleHelped = 0;
  int _impactPoints = 0;
  bool _isLoading = true;

  final List<Map<String, dynamic>> _menuItems = [
    {'icon': Icons.dashboard, 'title': 'Overview', 'index': 0},
    {'icon': Icons.restaurant, 'title': 'My Donations', 'index': 1},
    {'icon': Icons.request_page, 'title': 'Requests', 'index': 2},
    {'icon': Icons.analytics, 'title': 'Impact', 'index': 3},
    {'icon': Icons.settings, 'title': 'Settings', 'index': 4},
  ];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    
    try {
      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
      final donorId = authProvider.currentUser?.id;
      
      if (donorId != null) {
        final donations = await _firestore
            .collection('donations')
            .where('donorId', isEqualTo: donorId)
            .get();
        
        final requests = await _firestore
            .collection('requests')
            .where('donorId', isEqualTo: donorId)
            .where('status', isEqualTo: 'pending')
            .get();
        
        setState(() {
          _totalDonations = donations.docs.length;
          _activeDonations = donations.docs.where((doc) => doc['status'] == 'active').length;
          _completedDonations = donations.docs.where((doc) => doc['status'] == 'completed').length;
          _pendingRequests = requests.docs.length;
          _mealsDonated = _totalDonations * 75;
          _peopleHelped = _totalDonations * 20;
          _impactPoints = _totalDonations * 30;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() {
        _totalDonations = 0;
        _activeDonations = 0;
        _completedDonations = 0;
        _pendingRequests = 0;
        _mealsDonated = 0;
        _peopleHelped = 0;
        _impactPoints = 0;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AppAuthProvider>(context);
    final donor = authProvider.currentUser;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Donor Portal',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppTheme.primaryGreen),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red, size: 20),
            onPressed: () async {
              await authProvider.logout();
              if (mounted) Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      drawer: _buildDrawer(donor, authProvider),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : _buildMainContent(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryGreen,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_outlined), label: 'Alerts'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildDrawer(AppUser? donor, AppAuthProvider authProvider) {
    return Drawer(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppTheme.primaryGreen, AppTheme.darkGreen]),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Text(
                    donor?.name[0].toUpperCase() ?? 'D',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                  ),
                ),
                const SizedBox(height: 8),
                Text(donor?.name ?? 'Donor', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                  child: const Text('Food Donor', style: TextStyle(color: Colors.white, fontSize: 10)),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: _menuItems.map((item) {
                final isSelected = _selectedMenuIndex == item['index'];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryGreen.withOpacity(0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    leading: Icon(item['icon'], size: 22, color: isSelected ? AppTheme.primaryGreen : Colors.grey[600]),
                    title: Text(
                      item['title'],
                      style: TextStyle(
                        fontSize: 14,
                        color: isSelected ? AppTheme.primaryGreen : Colors.grey[700],
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    onTap: () {
                      setState(() => _selectedMenuIndex = item['index']);
                      Navigator.pop(context);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    switch (_selectedMenuIndex) {
      case 0:
        return _buildOverview();
      case 1:
        return _buildMyDonations();
      case 2:
        return _buildRequests();
      case 3:
        return _buildImpact();
      case 4:
        return _buildSettings();
      default:
        return _buildOverview();
    }
  }

  // ==================== OVERVIEW ====================
  Widget _buildOverview() {
    return RefreshIndicator(
      onRefresh: _loadStats,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppTheme.primaryGreen, AppTheme.lightGreen]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Donor Dashboard', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 4),
                        Text(DateFormat('EEEE, MMMM d').format(DateTime.now()), style: const TextStyle(fontSize: 11, color: Colors.white70)),
                      ],
                    ),
                  ),
                  const Icon(Icons.favorite, color: Colors.white, size: 32),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.2,
              children: [
                _buildStatCard('Total', '$_totalDonations', Icons.restaurant, AppTheme.primaryGreen),
                _buildStatCard('Active', '$_activeDonations', Icons.check_circle, Colors.teal),
                _buildStatCard('Completed', '$_completedDonations', Icons.done_all, Colors.green),
                _buildStatCard('Requests', '$_pendingRequests', Icons.pending, Colors.orange),
                _buildStatCard('Meals', '$_mealsDonated', Icons.restaurant_menu, Colors.amber),
                _buildStatCard('Score', '$_impactPoints', Icons.star, Colors.yellow.shade700),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 4)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  // ==================== MY DONATIONS ====================
  Widget _buildMyDonations() {
    final authProvider = Provider.of<AppAuthProvider>(context);
    final donorId = authProvider.currentUser?.id;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDonationDialog(),
        backgroundColor: AppTheme.primaryGreen,
        child: const Icon(Icons.add, size: 22),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('My Donations', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('Manage your food donations', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: StreamBuilder(
                stream: _firestore
                    .collection('donations')
                    .where('donorId', isEqualTo: donorId)
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  
                  final donations = snapshot.data!.docs;
                  if (donations.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.food_bank, size: 48, color: Colors.grey),
                          SizedBox(height: 12),
                          Text('No donations yet', style: TextStyle(color: Colors.grey)),
                          SizedBox(height: 8),
                          Text('Tap + to add', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: donations.length,
                    itemBuilder: (context, index) {
                      final donation = donations[index].data() as Map<String, dynamic>;
                      final donationId = donations[index].id;
                      return ListTile(
                        leading: donation['imageUrl'] != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(donation['imageUrl'], width: 45, height: 45, fit: BoxFit.cover),
                              )
                            : Container(
                                width: 45,
                                height: 45,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryGreen.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.food_bank, color: AppTheme.primaryGreen, size: 24),
                              ),
                        title: Text(donation['title'] ?? 'Food', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        subtitle: Text('${donation['quantity']} ${donation['unit']} • ${donation['status'] ?? 'pending'}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                          onPressed: () => _deleteDonation(donationId),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDonationDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final quantityController = TextEditingController();
    final pickupLocationController = TextEditingController();
    String selectedCategory = 'Vegetables';
    String selectedUnit = 'kg';
    DateTime selectedDate = DateTime.now().add(const Duration(days: 2));
    String? _selectedImageUrl;
    bool _isUploading = false;
    final ImageUploadService _imageService = ImageUploadService();

    final categories = ['Vegetables', 'Fruits', 'Bakery', 'Dairy', 'Non-perishable', 'Other'];
    final units = ['kg', 'pcs', 'liters', 'cans', 'boxes'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Add Donation', style: TextStyle(fontSize: 16)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () async {
                      setState(() => _isUploading = true);
                      final imageUrl = await _imageService.pickAndUploadImage();
                      if (imageUrl != null) setState(() => _selectedImageUrl = imageUrl);
                      setState(() => _isUploading = false);
                    },
                    child: Container(
                      height: 100,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: _isUploading
                          ? const Center(child: CircularProgressIndicator())
                          : _selectedImageUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(_selectedImageUrl!, fit: BoxFit.cover, width: double.infinity),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_photo_alternate, size: 32, color: Colors.grey[400]),
                                    const SizedBox(height: 6),
                                    Text('Add photo', style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                                  ],
                                ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                    maxLines: 2,
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: quantityController,
                          decoration: const InputDecoration(labelText: 'Qty', border: OutlineInputBorder()),
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedUnit,
                          decoration: const InputDecoration(labelText: 'Unit', border: OutlineInputBorder()),
                          items: units.map((unit) => DropdownMenuItem(value: unit, child: Text(unit, style: const TextStyle(fontSize: 12)))).toList(),
                          onChanged: (value) => setState(() => selectedUnit = value!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                    items: categories.map((category) => DropdownMenuItem(value: category, child: Text(category, style: const TextStyle(fontSize: 12)))).toList(),
                    onChanged: (value) => setState(() => selectedCategory = value!),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Expiry Date', style: TextStyle(fontSize: 12)),
                    subtitle: Text(DateFormat('MMM dd, yyyy').format(selectedDate), style: const TextStyle(fontSize: 11)),
                    trailing: const Icon(Icons.calendar_today, size: 16),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                      );
                      if (date != null) setState(() => selectedDate = date);
                    },
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: pickupLocationController,
                    decoration: const InputDecoration(labelText: 'Pickup Location', border: OutlineInputBorder()),
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(fontSize: 12))),
              ElevatedButton(
                onPressed: () async {
                  final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
                  final donorId = authProvider.currentUser?.id;
                  
                  if (donorId != null && titleController.text.isNotEmpty) {
                    final donationData = {
                      'donorId': donorId,
                      'title': titleController.text,
                      'description': descriptionController.text,
                      'quantity': int.tryParse(quantityController.text) ?? 0,
                      'unit': selectedUnit,
                      'category': selectedCategory,
                      'imageUrl': _selectedImageUrl,
                      'expiryDate': Timestamp.fromDate(selectedDate),
                      'pickupLocation': pickupLocationController.text,
                      'status': 'active',
                      'createdAt': FieldValue.serverTimestamp(),
                    };
                    
                    await _firestore.collection('donations').add(donationData);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Donation added!'), duration: Duration(seconds: 2)));
                    Navigator.pop(context);
                    _loadStats();
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
                child: const Text('Add', style: TextStyle(fontSize: 12)),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _deleteDonation(String donationId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Donation'),
        content: const Text('Are you sure?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await _firestore.collection('donations').doc(donationId).delete();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Donation deleted'), duration: Duration(seconds: 1)));
              Navigator.pop(context);
              _loadStats();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ==================== REQUESTS ====================
  Widget _buildRequests() {
    final authProvider = Provider.of<AppAuthProvider>(context);
    final donorId = authProvider.currentUser?.id;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Requests', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('Review donation requests', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: StreamBuilder(
                stream: _firestore
                    .collection('requests')
                    .where('donorId', isEqualTo: donorId)
                    .where('status', isEqualTo: 'pending')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                  final requests = snapshot.data!.docs;
                  
                  if (requests.isEmpty) {
                    return const Center(child: Text('No pending requests', style: TextStyle(color: Colors.grey)));
                  }

                  return ListView.builder(
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final request = requests[index].data() as Map<String, dynamic>;
                      return ListTile(
                        leading: const Icon(Icons.request_page, color: AppTheme.accentOrange, size: 22),
                        title: Text(request['donationTitle'] ?? 'Food', style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text('From: ${request['recipientName'] ?? 'Someone'}', style: const TextStyle(fontSize: 12)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            OutlinedButton(
                              onPressed: () => _respondToRequest(requests[index].id, 'rejected'),
                              style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
                              child: const Text('Reject', style: TextStyle(fontSize: 11, color: Colors.red)),
                            ),
                            const SizedBox(width: 6),
                            ElevatedButton(
                              onPressed: () => _respondToRequest(requests[index].id, 'approved'),
                              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
                              child: const Text('Approve', style: TextStyle(fontSize: 11)),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _respondToRequest(String requestId, String status) async {
    await _firestore.collection('requests').doc(requestId).update({
      'status': status,
      'respondedAt': FieldValue.serverTimestamp(),
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Request $status'), duration: Duration(seconds: 1)));
    _loadStats();
  }

  // ==================== IMPACT ====================
  Widget _buildImpact() {
    return RefreshIndicator(
      onRefresh: _loadStats,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Impact Report', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Your donation impact', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.1,
              children: [
                _buildImpactCard('Meals', '$_mealsDonated', Icons.restaurant_menu, Colors.amber),
                _buildImpactCard('People', '$_peopleHelped', Icons.people, Colors.green),
                _buildImpactCard('Carbon', '${(_mealsDonated * 2.5).toInt()} kg', Icons.eco, Colors.teal),
                _buildImpactCard('Score', '$_impactPoints', Icons.star, Colors.yellow.shade700),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: _impactPoints / 2000,
                    backgroundColor: Colors.grey[200],
                    color: AppTheme.primaryGreen,
                    minHeight: 5,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('$_impactPoints / 2000 pts', style: const TextStyle(fontSize: 9, color: Colors.grey)),
                      Text('${((_impactPoints / 2000) * 100).toInt()}%', style: const TextStyle(fontSize: 9, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImpactCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color.withOpacity(0.1), color.withOpacity(0.05)]),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  // ==================== SETTINGS ====================
  Widget _buildSettings() {
    final authProvider = Provider.of<AppAuthProvider>(context);
    final donor = authProvider.currentUser;
    
    final nameController = TextEditingController(text: donor?.name);
    final phoneController = TextEditingController(text: donor?.phone);
    final emailController = TextEditingController(text: donor?.email);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Settings', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Manage your account', style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person, color: AppTheme.primaryGreen),
                  title: const Text('Profile'),
                  subtitle: Text(donor?.email ?? ''),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showEditProfileDialog(nameController, phoneController, emailController),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.lock, color: AppTheme.primaryGreen),
                  title: const Text('Change Password'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showChangePasswordDialog(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(TextEditingController nameController, TextEditingController phoneController, TextEditingController emailController) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder())),
            const SizedBox(height: 8),
            TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone', border: OutlineInputBorder())),
            const SizedBox(height: 8),
            TextField(controller: emailController, enabled: false, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
              await authProvider.updateProfile(name: nameController.text, phone: phoneController.text);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated')));
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final newController = TextEditingController();
    final confirmController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: newController, decoration: const InputDecoration(labelText: 'New Password', border: OutlineInputBorder()), obscureText: true),
            const SizedBox(height: 8),
            TextField(controller: confirmController, decoration: const InputDecoration(labelText: 'Confirm', border: OutlineInputBorder()), obscureText: true),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (newController.text != confirmController.text) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match'), backgroundColor: Colors.red));
                return;
              }
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                await user.updatePassword(newController.text);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password updated')));
                Navigator.pop(context);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}