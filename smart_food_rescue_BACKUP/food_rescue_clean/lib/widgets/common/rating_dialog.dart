import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../utils/constants.dart';
import '../../services/rating_service.dart';

class RatingDialog extends StatefulWidget {
  final String toUserId;
  final String toUserName;
  final String requestId;
  final String foodId;
  final String foodTitle;
  final VoidCallback onRated;

  const RatingDialog({
    super.key,
    required this.toUserId,
    required this.toUserName,
    required this.requestId,
    required this.foodId,
    required this.foodTitle,
    required this.onRated,
  });

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  double _rating = 0;
  String _comment = '';
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star_rate, size: 60, color: Colors.amber),
            const SizedBox(height: 16),
            Text(
              'Rate ${widget.toUserName}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'How was your experience?',
              style: TextStyle(color: AppColors.grey),
            ),
            const SizedBox(height: 24),
            // Star Rating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 40,
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = index + 1;
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 16),
            // Comment Field
            TextField(
              onChanged: (value) => _comment = value,
              decoration: const InputDecoration(
                hintText: 'Share your experience...',
                border: OutlineInputBorder(),
                helperText: 'Your feedback helps others make informed decisions',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : () => _submitRating(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Submit Rating'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitRating() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a rating')),
      );
      return;
    }
    
    setState(() => _isSubmitting = true);
    
    await RatingService.addRating(
      fromUserId: FirebaseAuth.instance.currentUser!.uid,
      fromUserName: FirebaseAuth.instance.currentUser!.email!,
      toUserId: widget.toUserId,
      toUserName: widget.toUserName,
      requestId: widget.requestId,
      foodId: widget.foodId,
      foodTitle: widget.foodTitle,
      rating: _rating,
      comment: _comment,
    );
    
    setState(() => _isSubmitting = false);
    Navigator.pop(context);
    widget.onRated();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Thank you for your rating!')),
    );
  }
}
