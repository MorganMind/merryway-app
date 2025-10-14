// EXAMPLE: How to integrate offline feedback into HomePage
// Copy the relevant parts into your lib/modules/home/pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/home_feedback_service_offline.dart';
import '../services/offline_feedback_queue.dart';

class HomePageWithOffline extends StatefulWidget {
  const HomePageWithOffline({super.key});

  @override
  State<HomePageWithOffline> createState() => _HomePageWithOfflineState();
}

class _HomePageWithOfflineState extends State<HomePageWithOffline> {
  late HomeFeedbackServiceOffline feedbackService;
  bool feedbackInProgress = false;
  int pendingFeedbackCount = 0;

  @override
  void initState() {
    super.initState();
    
    // Initialize offline-aware feedback service
    feedbackService = HomeFeedbackServiceOffline();
    feedbackService.initialize();
    
    // Check for pending feedback from previous sessions
    _checkPendingFeedback();
    
    // Listen for pending feedback changes
    _startPendingCountMonitor();
  }

  /// Check and sync pending feedback on startup
  Future<void> _checkPendingFeedback() async {
    final count = await feedbackService.getPendingCount();
    
    if (count > 0 && mounted) {
      setState(() => pendingFeedbackCount = count);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('📱 Syncing $count offline feedback...'),
          duration: const Duration(seconds: 3),
        ),
      );
      
      // Try to sync
      final result = await feedbackService.syncNow();
      
      if (result.success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Synced ${result.synced} items!'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
      
      // Update count
      final newCount = await feedbackService.getPendingCount();
      if (mounted) {
        setState(() => pendingFeedbackCount = newCount);
      }
    }
  }

  /// Monitor pending feedback count
  void _startPendingCountMonitor() {
    // Check every 10 seconds
    Future.delayed(const Duration(seconds: 10), () async {
      if (!mounted) return;
      final count = await feedbackService.getPendingCount();
      if (mounted && count != pendingFeedbackCount) {
        setState(() => pendingFeedbackCount = count);
      }
      _startPendingCountMonitor(); // Repeat
    });
  }

  /// Submit feedback with automatic offline handling
  Future<void> _submitFeedback(
    String suggestionId,
    String activityId,
    String action,
    int? rating,
  ) async {
    setState(() => feedbackInProgress = true);

    try {
      final result = await feedbackService.submitFeedback(
        suggestionId: suggestionId,
        activityId: activityId,
        action: action,
        rating: rating,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            backgroundColor: result.queued 
                ? Colors.orange.shade700 
                : Colors.green.shade700,
          ),
        );
      }

      // Update pending count
      final newCount = await feedbackService.getPendingCount();
      if (mounted) {
        setState(() => pendingFeedbackCount = newCount);
      }
    } finally {
      if (mounted) {
        setState(() => feedbackInProgress = false);
      }
    }
  }

  /// Manual sync button
  Future<void> _manualSync() async {
    final result = await feedbackService.syncNow();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          duration: const Duration(seconds: 2),
        ),
      );
      
      // Update count
      final newCount = await feedbackService.getPendingCount();
      setState(() => pendingFeedbackCount = newCount);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Today\'s Idea'),
        actions: [
          // Pending feedback indicator
          if (pendingFeedbackCount > 0)
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.sync),
                  onPressed: _manualSync,
                  tooltip: 'Sync pending feedback',
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$pendingFeedbackCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Activity Suggestion Here'),
            const SizedBox(height: 24),
            
            // Feedback buttons (example)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: feedbackInProgress ? null : () {
                    _submitFeedback(
                      'suggestion-123',
                      'activity-456',
                      'accept',
                      null,
                    );
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Try It'),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: feedbackInProgress ? null : () {
                    _submitFeedback(
                      'suggestion-123',
                      'activity-456',
                      'skip',
                      null,
                    );
                  },
                  icon: const Icon(Icons.skip_next),
                  label: const Text('Skip'),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Pending feedback status
            if (pendingFeedbackCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.cloud_off,
                      size: 16,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$pendingFeedbackCount feedback items queued',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: _manualSync,
                      child: const Text(
                        'Sync now',
                        style: TextStyle(fontSize: 12),
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
}

/*
==============================================================================
INTEGRATION CHECKLIST
==============================================================================

1. ✅ Add to your existing HomePage:
   - Import: import '../services/home_feedback_service_offline.dart';
   - Add: late HomeFeedbackServiceOffline feedbackService;
   - Add: int pendingFeedbackCount = 0;
   
2. ✅ In initState():
   feedbackService = HomeFeedbackServiceOffline();
   feedbackService.initialize();
   _checkPendingFeedback();

3. ✅ Replace your existing _submitFeedback() with the one above

4. ✅ Add pending feedback indicator to AppBar (optional but recommended)

5. ✅ Test offline mode:
   - Flutter DevTools → Network → Toggle offline
   - Give feedback → Should queue
   - Toggle online → Should auto-sync

==============================================================================
*/

