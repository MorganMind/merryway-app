import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../models/membership_summary.dart';
import '../repositories/membership_repository.dart';
import 'subscribe_screen.dart';

class MembershipHomeScreen extends StatefulWidget {
  const MembershipHomeScreen({Key? key}) : super(key: key);

  @override
  State<MembershipHomeScreen> createState() => _MembershipHomeScreenState();
}

class _MembershipHomeScreenState extends State<MembershipHomeScreen> {
  final _repository = MembershipRepository(Supabase.instance.client);
  MembershipSummary? _membershipSummary;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMembershipData();
  }

  Future<void> _loadMembershipData() async {
    setState(() => _loading = true);
    final summary = await _repository.getMembershipSummary();
    setState(() {
      _membershipSummary = summary;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Membership'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMembershipData,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadMembershipData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMembershipStatus(),
                      const SizedBox(height: 24),
                      _buildLedgerFeed(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildMembershipStatus() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Membership Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (_membershipSummary?.membershipStatus != null) ...[
              _buildStatusRow('Plan', _membershipSummary?.planName ?? 'None'),
              _buildStatusRow(
                'Status',
                _membershipSummary?.membershipStatus?.toUpperCase() ?? 'INACTIVE',
              ),
              if (_membershipSummary?.startedAt != null)
                _buildStatusRow(
                  'Started',
                  DateFormat('MMM dd, yyyy').format(_membershipSummary!.startedAt!),
                ),
              if (_membershipSummary?.expiresAt != null)
                _buildStatusRow(
                  'Expires',
                  DateFormat('MMM dd, yyyy').format(_membershipSummary!.expiresAt!),
                ),
            ] else ...[
              const Text('No active membership'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SubscribeScreen(),
                    ),
                  );
                  if (result == true) {
                    _loadMembershipData();
                  }
                },
                child: const Text('Subscribe Now'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildLedgerFeed() {
    final entries = _membershipSummary?.lastTenLedgerEntries ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Ledger Entries',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (entries.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Text('No ledger entries yet'),
              ),
            ),
          )
        else
          ...entries.map((entry) => _buildLedgerEntry(entry)),
      ],
    );
  }

  Widget _buildLedgerEntry(LedgerEntry entry) {
    final isCredit = entry.type == 'credit';
    final color = isCredit ? Colors.green : Colors.red;
    final sign = isCredit ? '+' : '-';

    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(
            isCredit ? Icons.add : Icons.remove,
            color: color,
          ),
        ),
        title: Text(
          '$sign${entry.displayValue}',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Source: ${entry.source}'),
            if (entry.entitlementCode != null)
              Text('Entitlement: ${entry.entitlementCode}'),
            Text(
              DateFormat('MMM dd, yyyy HH:mm').format(entry.createdAt),
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}
