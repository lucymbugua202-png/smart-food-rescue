import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_auth_provider.dart';
import '../themes/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _filterType = 'All';
  bool _isLoading = true;
  String? _errorMessage;
  
  final List<String> _filterOptions = ['All', 'Request', 'Donation', 'System'];

  @override
  void initState() {
    super.initState();
    _setupNotifications();
  }

  void _setupNotifications() {
    // This will be handled by the StreamBuilder
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AppAuthProvider>(context);
    final isLoggedIn = authProvider.currentUser != null;
    final userId = authProvider.currentUser?.id;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Notifications',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
        ),
        actions: [
          if (isLoggedIn)
            IconButton(
              icon: const Icon(Icons.done_all, size: 20),
              onPressed: () => _markAllAsRead(userId!),
              tooltip: 'Mark all as read',
            ),
        ],
      ),
      body: isLoggedIn
          ? _buildNotificationsList(userId!)
          : _buildLoginPrompt(),
    );
  }

  Widget _buildNotificationsList(String userId) {
    return Column(
      children: [
        // Filter Chips
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.white,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filterOptions.map((filter) {
                final isSelected = _filterType == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter, style: const TextStyle(fontSize: 13)),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _filterType = filter;
                      });
                    },
                    backgroundColor: Colors.white,
                    selectedColor: AppTheme.primaryGreen.withOpacity(0.2),
                    checkmarkColor: AppTheme.primaryGreen,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        // Notifications Stream
        Expanded(
          child: StreamBuilder(
            stream: _firestore
                .collection('notifications')
                .where('userId', isEqualTo: userId)
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                      const SizedBox(height: 12),
                      Text('Error: ${snapshot.error}', style: const TextStyle(fontSize: 12)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => setState(() {}),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              var notifications = snapshot.data!.docs;
              
              // Apply filter
              if (_filterType != 'All') {
                notifications = notifications.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return data['type'] == _filterType.toLowerCase();
                }).toList();
              }

              if (notifications.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  final data = notification.data() as Map<String, dynamic>;
                  return _buildNotificationCard(
                    data,
                    notification.id,
                    data['isRead'] ?? false,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification, String id, bool isRead) {
    final type = notification['type'] ?? 'system';
    final title = notification['title'] ?? 'Notification';
    final message = notification['message'] ?? '';
    final timestamp = notification['createdAt'] as Timestamp?;
    final date = timestamp != null ? timestamp.toDate() : DateTime.now();
    
    IconData icon;
    Color iconColor;
    Color backgroundColor;
    
    switch (type) {
      case 'request':
        icon = Icons.request_page;
        iconColor = AppTheme.accentOrange;
        backgroundColor = AppTheme.accentOrange.withOpacity(0.1);
        break;
      case 'donation':
        icon = Icons.restaurant;
        iconColor = AppTheme.primaryGreen;
        backgroundColor = AppTheme.primaryGreen.withOpacity(0.1);
        break;
      default:
        icon = Icons.notifications;
        iconColor = Colors.blue;
        backgroundColor = Colors.blue.withOpacity(0.1);
    }

    return GestureDetector(
      onTap: () => _markAsRead(id, isRead),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isRead ? Colors.white : AppTheme.primaryGreen.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: !isRead
              ? Border.all(color: AppTheme.primaryGreen.withOpacity(0.3))
              : null,
        ),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                message,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                _formatDate(date),
                style: TextStyle(fontSize: 10, color: Colors.grey[500]),
              ),
            ],
          ),
          trailing: !isRead
              ? Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryGreen,
                    shape: BoxShape.circle,
                  ),
                )
              : null,
          contentPadding: const EdgeInsets.all(12),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'When you receive notifications, they will appear here',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            const Text(
              'Sign in to view notifications',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Get alerts about donation requests, approvals, and updates',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _markAsRead(String notificationId, bool isRead) async {
    if (!isRead) {
      await _firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> _markAllAsRead(String userId) async {
    final batch = _firestore.batch();
    final notifications = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();
    
    for (var doc in notifications.docs) {
      batch.update(doc.reference, {'isRead': true, 'readAt': FieldValue.serverTimestamp()});
    }
    
    await batch.commit();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All notifications marked as read'), duration: Duration(seconds: 1)),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 7) {
      return DateFormat('MMM dd, yyyy').format(date);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}
