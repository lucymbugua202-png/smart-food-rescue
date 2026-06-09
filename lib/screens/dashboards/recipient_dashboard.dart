import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/app_auth_provider.dart';
import '../../models/user_model.dart';
import '../../themes/app_theme.dart';

class RecipientDashboard extends StatefulWidget {
  const RecipientDashboard({super.key});

  @override
  State<RecipientDashboard> createState() => _RecipientDashboardState();
}

class _RecipientDashboardState extends State<RecipientDashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedMenuIndex = 0;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  
  // Recipient Stats
  int _availableDonations = 0;
  int _approvedRequests = 0;
  int _pendingRequests = 0;
  int _collectedItems = 0;
  int _mealsReceived = 0;
  bool _isLoading = true;

  final List<String> _categories = ['All', 'Vegetables', 'Fruits', 'Bakery', 'Dairy', 'Non-perishable', 'Other'];
  
  final List<Map<String, dynamic>> _menuItems = [
    {'icon': Icons.dashboard, 'title': 'Overview', 'index': 0},
    {'icon': Icons.search, 'title': 'Browse Donations', 'index': 1},
    {'icon': Icons.request_page, 'title': 'My Requests', 'index': 2},
    {'icon': Icons.history, 'title': 'Collection History', 'index': 3},
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
      final recipientId = authProvider.currentUser?.id;
      
      if (recipientId != null) {
        final donations = await _firestore
            .collection('donations')
            .where('status', isEqualTo: 'active')
            .get();
        
        final requests = await _firestore
            .collection('requests')
            .where('recipientId', isEqualTo: recipientId)
            .get();
        
        setState(() {
          _availableDonations = donations.docs.length;
          _approvedRequests = requests.docs.where((doc) => doc['status'] == 'approved').length;
          _pendingRequests = requests.docs.where((doc) => doc['status'] == 'pending').length;
          _collectedItems = _approvedRequests;
          _mealsReceived = _approvedRequests * 25;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() {
        _availableDonations = 0;
        _approvedRequests = 0;
        _pendingRequests = 0;
        _collectedItems = 0;
        _mealsReceived = 0;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AppAuthProvider>(context);
    final recipient = authProvider.currentUser;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Recipient Portal',
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
      drawer: _buildDrawer(recipient, authProvider),
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

  Widget _buildDrawer(AppUser? recipient, AppAuthProvider authProvider) {
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
                    recipient?.name[0].toUpperCase() ?? 'R',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                  ),
                ),
                const SizedBox(height: 8),
                Text(recipient?.name ?? 'Recipient', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                  child: const Text('Food Recipient', style: TextStyle(color: Colors.white, fontSize: 10)),
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
        return _buildBrowseDonations();
      case 2:
        return _buildMyRequests();
      case 3:
        return _buildCollectionHistory();
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
                        const Text('Food Assistance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 4),
                        Text(DateFormat('EEEE, MMMM d').format(DateTime.now()), style: const TextStyle(fontSize: 11, color: Colors.white70)),
                      ],
                    ),
                  ),
                  const Icon(Icons.people_outline, color: Colors.white, size: 32),
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
                _buildStatCard('Available', '$_availableDonations', Icons.restaurant, AppTheme.primaryGreen),
                _buildStatCard('Approved', '$_approvedRequests', Icons.check_circle, Colors.green),
                _buildStatCard('Pending', '$_pendingRequests', Icons.pending, Colors.orange),
                _buildStatCard('Collected', '$_collectedItems', Icons.delivery_dining, Colors.blue),
                _buildStatCard('Meals', '$_mealsReceived', Icons.restaurant_menu, Colors.amber),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppTheme.accentOrange.withOpacity(0.15), Colors.orange.withOpacity(0.05)]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Need Food?', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        Text('Browse available donations', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => setState(() => _selectedMenuIndex = 1),
                    icon: const Icon(Icons.search, size: 16),
                    label: const Text('Browse', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
                  ),
                ],
              ),
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

  // ==================== BROWSE DONATIONS ====================
  Widget _buildBrowseDonations() {
    final authProvider = Provider.of<AppAuthProvider>(context);
    final recipientId = authProvider.currentUser?.id;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search food...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(icon: const Icon(Icons.clear, size: 16), onPressed: () => setState(() => _searchQuery = ''))
                        : null,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((category) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category, style: const TextStyle(fontSize: 12)),
                          selected: _selectedCategory == category,
                          onSelected: (selected) => setState(() => _selectedCategory = category),
                          backgroundColor: Colors.white,
                          selectedColor: AppTheme.primaryGreen.withOpacity(0.2),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: _firestore.collection('donations').where('status', isEqualTo: 'active').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                
                var donations = snapshot.data!.docs;
                
                if (_searchQuery.isNotEmpty) {
                  donations = donations.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final title = data['title']?.toString().toLowerCase() ?? '';
                    return title.contains(_searchQuery.toLowerCase());
                  }).toList();
                }
                
                if (_selectedCategory != 'All') {
                  donations = donations.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return data['category'] == _selectedCategory;
                  }).toList();
                }
                
                if (donations.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 48, color: Colors.grey),
                        SizedBox(height: 12),
                        Text('No donations found', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: donations.length,
                  itemBuilder: (context, index) {
                    final donation = donations[index].data() as Map<String, dynamic>;
                    final donationId = donations[index].id;
                    return _buildDonationCard(donation, donationId, recipientId!);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonationCard(Map<String, dynamic> donation, String donationId, String recipientId) {
    final expiryDate = donation['expiryDate'] as Timestamp?;
    final daysLeft = expiryDate != null ? expiryDate.toDate().difference(DateTime.now()).inDays : 7;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Stack(
              children: [
                Center(
                  child: donation['imageUrl'] != null
                      ? Image.network(donation['imageUrl'], height: 80, width: 80, fit: BoxFit.cover)
                      : const Icon(Icons.food_bank, size: 40, color: AppTheme.primaryGreen),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: daysLeft <= 2 ? Colors.red : Colors.orange,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text('$daysLeft d', style: const TextStyle(color: Colors.white, fontSize: 9)),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(donation['title'] ?? 'Food', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('${donation['quantity']} ${donation['unit']}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _requestDonation(donation, donationId, recipientId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text('Request', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _requestDonation(Map<String, dynamic> donation, String donationId, String recipientId) async {
    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    final recipient = authProvider.currentUser;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Donation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Item: ${donation['title']}'),
            const SizedBox(height: 8),
            Text('Quantity: ${donation['quantity']} ${donation['unit']}'),
            const SizedBox(height: 8),
            Text('Pickup: ${donation['pickupLocation']}'),
            const SizedBox(height: 16),
            const Text('Confirm your request?'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              try {
                final request = {
                  'donationId': donationId,
                  'donationTitle': donation['title'],
                  'donorId': donation['donorId'],
                  'recipientId': recipientId,
                  'recipientName': recipient?.name,
                  'recipientEmail': recipient?.email,
                  'status': 'pending',
                  'createdAt': FieldValue.serverTimestamp(),
                };
                await _firestore.collection('requests').add(request);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request sent!'), duration: Duration(seconds: 2)));
                Navigator.pop(context);
                _loadStats();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  // ==================== MY REQUESTS ====================
  Widget _buildMyRequests() {
    final authProvider = Provider.of<AppAuthProvider>(context);
    final recipientId = authProvider.currentUser?.id;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('My Requests', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('Track your food requests', style: TextStyle(fontSize: 12, color: Colors.grey)),
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
                    .where('recipientId', isEqualTo: recipientId)
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  
                  final requests = snapshot.data!.docs;
                  if (requests.isEmpty) return const Center(child: Text('No requests yet'));
                  
                  return ListView.builder(
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final request = requests[index].data() as Map<String, dynamic>;
                      final status = request['status'] ?? 'pending';
                      final createdAt = request['createdAt'] as Timestamp?;
                      final date = createdAt != null ? DateFormat('MMM dd, yyyy').format(createdAt.toDate()) : 'Unknown date';
                      
                      return ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: status == 'approved' ? Colors.green.withOpacity(0.1) : 
                                status == 'rejected' ? Colors.red.withOpacity(0.1) : 
                                Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.request_page,
                            color: status == 'approved' ? Colors.green : 
                                status == 'rejected' ? Colors.red : 
                                Colors.orange,
                            size: 22,
                          ),
                        ),
                        title: Text(request['donationTitle'] ?? 'Food', style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text('Requested on $date', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: status == 'approved' ? Colors.green.withOpacity(0.1) : 
                                status == 'rejected' ? Colors.red.withOpacity(0.1) : 
                                Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: status == 'approved' ? Colors.green : 
                                  status == 'rejected' ? Colors.red : 
                                  Colors.orange,
                            ),
                          ),
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

  // ==================== COLLECTION HISTORY ====================
  Widget _buildCollectionHistory() {
    final authProvider = Provider.of<AppAuthProvider>(context);
    final recipientId = authProvider.currentUser?.id;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Collection History', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('Your collected donations', style: TextStyle(fontSize: 12, color: Colors.grey)),
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
                    .where('recipientId', isEqualTo: recipientId)
                    .where('status', isEqualTo: 'approved')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  
                  final requests = snapshot.data!.docs;
                  if (requests.isEmpty) return const Center(child: Text('No collection history yet'));
                  
                  return ListView.builder(
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final request = requests[index].data() as Map<String, dynamic>;
                      final createdAt = request['createdAt'] as Timestamp?;
                      final date = createdAt != null ? DateFormat('MMM dd, yyyy').format(createdAt.toDate()) : 'Unknown date';
                      
                      return ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.check_circle, color: Colors.green, size: 22),
                        ),
                        title: Text(request['donationTitle'] ?? 'Food', style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text('Collected on $date', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        trailing: const Icon(Icons.delivery_dining, color: Colors.blue),
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

  // ==================== SETTINGS ====================
  Widget _buildSettings() {
    final authProvider = Provider.of<AppAuthProvider>(context);
    final recipient = authProvider.currentUser;
    
    final nameController = TextEditingController(text: recipient?.name);
    final phoneController = TextEditingController(text: recipient?.phone);
    final emailController = TextEditingController(text: recipient?.email);

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
                  subtitle: Text(recipient?.email ?? ''),
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