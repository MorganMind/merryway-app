import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../repositories/membership_repository.dart';

class CheckoutReturnScreen extends StatefulWidget {
  final String status; // 'success' or 'cancel'
  final String? sessionId;

  const CheckoutReturnScreen({
    Key? key,
    required this.status,
    this.sessionId,
  }) : super(key: key);

  @override
  State<CheckoutReturnScreen> createState() => _CheckoutReturnScreenState();
}

class _CheckoutReturnScreenState extends State<CheckoutReturnScreen> {
  final _repository = MembershipRepository(Supabase.instance.client);

  @override
  void initState() {
    super.initState();
    _handleReturn();
  }

  Future<void> _handleReturn() async {
    if (widget.status == 'success') {
      // Wait a moment for webhook to process
      await Future.delayed(const Duration(seconds: 2));
      
      // Refresh membership data
      await _repository.refreshMembership();
      
      if (mounted) {
        // Navigate to home with refresh flag
        context.go('/membership?refresh=true');
      }
    } else {
      // Canceled - just go back
      if (mounted) {
        context.go('/membership');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.status == 'success') ...[
              const Icon(Icons.check_circle, color: Colors.green, size: 80),
              const SizedBox(height: 16),
              const Text(
                'Payment Successful!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Setting up your membership...'),
              const SizedBox(height: 24),
              const CircularProgressIndicator(),
            ] else ...[
              const Icon(Icons.cancel, color: Colors.orange, size: 80),
              const SizedBox(height: 16),
              const Text(
                'Checkout Canceled',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Returning to membership page...'),
            ],
          ],
        ),
      ),
    );
  }
}
