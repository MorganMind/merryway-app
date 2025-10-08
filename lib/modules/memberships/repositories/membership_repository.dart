import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/membership_summary.dart';

class MembershipRepository {
  final SupabaseClient _supabase;

  MembershipRepository(this._supabase);

  Future<MembershipSummary?> getMembershipSummary() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await _supabase
          .from('user_membership_summary')
          .select()
          .eq('user_id', userId)
          .single();

      return MembershipSummary.fromJson(response);
    } catch (e) {
      print('Error fetching membership summary: $e');
      return null;
    }
  }

  Future<String?> createCheckoutSession({
    required String planCode,
    String? successUrl,
    String? cancelUrl,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'create-checkout-session',
        body: {
          'plan_code': planCode,
          'success_url': successUrl,
          'cancel_url': cancelUrl,
        },
      );

      if (response.data != null && response.data['checkout_url'] != null) {
        return response.data['checkout_url'];
      }
      return null;
    } catch (e) {
      print('Error creating checkout session: $e');
      return null;
    }
  }

  Future<void> refreshMembership() async {
    // Force refresh by re-fetching data
    // The webhook should have already updated the backend
    await getMembershipSummary();
  }
}
