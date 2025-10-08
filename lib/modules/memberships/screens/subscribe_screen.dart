import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../repositories/membership_repository.dart';

class SubscribeScreen extends StatefulWidget {
  const SubscribeScreen({Key? key}) : super(key: key);

  @override
  State<SubscribeScreen> createState() => _SubscribeScreenState();
}

class _SubscribeScreenState extends State<SubscribeScreen> {
  final _repository = MembershipRepository(Supabase.instance.client);
  bool _loading = false;

  Future<void> _startCheckout() async {
    setState(() => _loading = true);

    try {
      // Get the base URL for return paths
      final baseUrl = Uri.base.origin;
      
      // Create checkout session with return URLs
      final checkoutUrl = await _repository.createCheckoutSession(
        planCode: 'starter',
        successUrl: '$baseUrl/membership/success',
        cancelUrl: '$baseUrl/membership/cancel',
      );

      if (checkoutUrl != null) {
        // Launch Stripe Checkout in browser
        final uri = Uri.parse(checkoutUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not open checkout')),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to create checkout session')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscribe'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.card_membership,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 24),
              const Text(
                'Starter Membership',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                '\$99/month',
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 16),
              const Text(
                'Get exclusive access to premium features',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 200,
                height: 48,
                child: ElevatedButton(
                  onPressed: _loading ? null : _startCheckout,
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Subscribe Now'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
