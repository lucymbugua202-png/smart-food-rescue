import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/constants.dart';
import '../../services/request_service.dart';
import '../../services/food_service.dart';
import '../../services/chat_service.dart';
import '../../models/request_model.dart';
import '../common/chat_screen.dart';
import '../../widgets/common/rating_dialog.dart';

class DonorRequestsScreen extends StatefulWidget {
  const DonorRequestsScreen({super.key});

  @override
  State<DonorRequestsScreen> createState() => _DonorRequestsScreenState();
}

class _DonorRequestsScreenState extends State<DonorRequestsScreen> {
  final user = FirebaseAuth.instance.currentUser;
  String _selectedFilter = 'all';
  bool _isLoading = true;
  List<RequestModel> _allRequests = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final requests = await RequestService.getDonorRequests(user!.uid).first;
      setState(() {
        _allRequests = requests;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  List<RequestModel> get _filteredRequests {
    if (_selectedFilter == 'all') return _allRequests;
    return _allRequests.where((r) => r.status == _selectedFilter).toList();
  }

  Future<void> _openChat(RequestModel request) async {
    final chatRoomId = await ChatService.createChatRoom(
      foodId: request.foodId,
      foodTitle: request.foodTitle,
      donorId: user!.uid,
      donorName: user!.email!,
      recipientId: request.recipientId,
      recipientName: request.recipientName,
    );
    
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            chatRoomId: chatRoomId,
            otherUserName: request.recipientName,
            foodTitle: request.foodTitle,
          ),
        ),
      );
    }
  }

  void _showRatingDialog(RequestModel request) {
    showDialog(
      context: context,
      builder: (context) => RatingDialog(
        toUserId: request.recipientId,
        toUserName: request.recipientName,
        requestId: request.id,
        foodId: request.foodId,
        foodTitle: request.foodTitle,
        onRated: () => _loadRequests(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Requests'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('all', 'All'),
                  const SizedBox(width: 8),
                  _buildFilterChip('pending', 'Pending'),
                  const SizedBox(width: 8),
                  _buildFilterChip('approved', 'Approved'),
                  const SizedBox(width: 8),
                  _buildFilterChip('rejected', 'Rejected'),
                  const SizedBox(width: 8),
                  _buildFilterChip('completed', 'Completed'),
                ],
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadRequests,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    int count = value == 'all' 
        ? _allRequests.length 
        : _allRequests.where((r) => r.status == value).length;
    
    return FilterChip(
      label: Text('$label ($count)'),
      selected: _selectedFilter == value,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = selected ? value : 'all';
        });
      },
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            const Text(
              'Unable to load requests',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: const TextStyle(color: AppColors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadRequests,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    if (_allRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox, size: 64, color: AppColors.grey),
            const SizedBox(height: 16),
            const Text(
              'No requests yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'When recipients request your food, they\'ll appear here',
              style: TextStyle(color: AppColors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    if (_filteredRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.filter_alt_off, size: 64, color: AppColors.grey),
            const SizedBox(height: 16),
            Text(
              'No $_selectedFilter requests',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredRequests.length,
      itemBuilder: (context, index) {
        final request = _filteredRequests[index];
        return _buildRequestCard(request);
      },
    );
  }

  Widget _buildRequestCard(RequestModel request) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _getStatusColor(request.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getStatusIcon(request.status),
                    color: _getStatusColor(request.status),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.foodTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Requested by: ${request.recipientName}',
                        style: const TextStyle(fontSize: 14, color: AppColors.grey),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(request.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    request.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      color: _getStatusColor(request.status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Contact Info Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person, size: 16, color: AppColors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          request.recipientName,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 16, color: AppColors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          request.recipientPhone.isNotEmpty 
                              ? request.recipientPhone 
                              : 'No phone provided',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16, color: AppColors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Requested: ${_formatDate(request.createdAt)}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  if (request.updatedAt != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.update, size: 16, color: AppColors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Updated: ${_formatDate(request.updatedAt!)}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Action Buttons Row
            Row(
              children: [
                // Chat Button (for approved/completed requests)
                if (request.status == 'approved' || request.status == 'completed')
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _openChat(request),
                      icon: const Icon(Icons.chat_bubble_outline, size: 18),
                      label: const Text('Chat'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                
                // Rating Button (for completed requests only)
                if (request.status == 'completed')
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showRatingDialog(request),
                      icon: const Icon(Icons.star_border, size: 18),
                      label: const Text('Rate'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.amber,
                        side: const BorderSide(color: Colors.amber),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                
                // Action buttons for pending requests
                if (request.status == 'pending') ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _updateRequestStatus(request, 'rejected'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _updateRequestStatus(request, 'approved'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Approve'),
                    ),
                  ),
                ],
                
                // Mark as Completed button for approved requests
                if (request.status == 'approved')
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _updateRequestStatus(request, 'completed'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Mark Completed'),
                    ),
                  ),
              ],
            ),
            
            // Note for completed requests
            if (request.status == 'completed')
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 16, color: AppColors.success),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'This request has been completed. Thank you for helping reduce food waste!',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return AppColors.warning;
      case 'approved': return AppColors.success;
      case 'rejected': return AppColors.error;
      case 'completed': return AppColors.primary;
      default: return AppColors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending': return Icons.pending_actions;
      case 'approved': return Icons.check_circle;
      case 'rejected': return Icons.cancel;
      case 'completed': return Icons.done_all;
      default: return Icons.help;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _updateRequestStatus(RequestModel request, String newStatus) async {
    setState(() => _isLoading = true);
    
    await RequestService.updateRequestStatus(request.id, newStatus);
    
    if (newStatus == 'approved' || newStatus == 'rejected') {
      await FoodService.updateFoodStatus(request.foodId, newStatus);
    }
    
    await _loadRequests();
    
    if (mounted) {
      String message = '';
      Color backgroundColor = AppColors.success;
      
      switch (newStatus) {
        case 'approved':
          message = 'Request approved! The recipient has been notified.';
          backgroundColor = AppColors.success;
          break;
        case 'rejected':
          message = 'Request rejected';
          backgroundColor = AppColors.error;
          break;
        case 'completed':
          message = 'Request marked as completed!';
          backgroundColor = AppColors.primary;
          break;
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
        ),
      );
    }
  }
}