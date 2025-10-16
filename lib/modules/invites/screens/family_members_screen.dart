import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/redesign_tokens.dart';
import '../../../modules/family/models/family_models.dart';
import '../../../modules/auth/services/user_context_service.dart';
import '../models/invite_models.dart';
import '../services/invite_service.dart';
import '../services/member_service.dart';
import '../widgets/invite_dialog.dart';

/// Screen showing family members and pending invites
class FamilyMembersScreen extends StatefulWidget {
  final String householdId;

  const FamilyMembersScreen({
    super.key,
    required this.householdId,
  });

  @override
  State<FamilyMembersScreen> createState() => _FamilyMembersScreenState();
}

class _FamilyMembersScreenState extends State<FamilyMembersScreen> {
  List<MemberWithClaim> _members = [];
  List<Invite> _pendingInvites = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load members and invites in parallel
      final results = await Future.wait([
        MemberService.getHouseholdMembers(householdId: widget.householdId),
        InviteService.getHouseholdInvites(householdId: widget.householdId),
      ]);

      setState(() {
        _members = (results[0]['members'] as List)
            .map((json) => MemberWithClaim.fromJson(json))
            .toList();
        _pendingInvites = results[1];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to load family members: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Family Members',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: RedesignTokens.ink,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: RedesignTokens.ink),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add, color: RedesignTokens.ink),
            onPressed: _showInviteDialog,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(RedesignTokens.primary),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: RedesignTokens.slate,
              ),
              const SizedBox(height: 16),
              Text(
                'Error',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: RedesignTokens.ink,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  color: RedesignTokens.slate,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: RedesignTokens.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Current Members Section
          _buildSectionHeader('Current Members'),
          ..._members.map((member) => _buildMemberCard(member)),
          
          const SizedBox(height: 24),
          
          // Pending Invites Section
          if (_pendingInvites.isNotEmpty) ...[
            _buildSectionHeader('Pending Invites'),
            ..._pendingInvites.map((invite) => _buildInviteCard(invite)),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: RedesignTokens.ink,
        ),
      ),
    );
  }

  Widget _buildMemberCard(MemberWithClaim member) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: RedesignTokens.primary,
          child: Text(
            member.name[0].toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          member.name,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: RedesignTokens.ink,
          ),
        ),
        subtitle: Text(
          '${member.age} years old • ${member.isAdult ? "Adult" : "Child"}',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            color: RedesignTokens.slate,
          ),
        ),
        trailing: member.claimedUserId != null
            ? const Icon(Icons.check_circle, color: Colors.green)
            : const Icon(Icons.person_outline, color: RedesignTokens.slate),
      ),
    );
  }

  Widget _buildInviteCard(Invite invite) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: RedesignTokens.accentGold,
          child: const Icon(Icons.email, color: Colors.white),
        ),
        title: Text(
          invite.invitedEmail,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: RedesignTokens.ink,
          ),
        ),
        subtitle: Text(
          'Invited by ${invite.inviterName} • Expires ${_formatDate(invite.expiresAt)}',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            color: RedesignTokens.slate,
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleInviteAction(invite, value),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'resend',
              child: Row(
                children: [
                  Icon(Icons.refresh, size: 20),
                  SizedBox(width: 8),
                  Text('Resend'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'revoke',
              child: Row(
                children: [
                  Icon(Icons.cancel, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Revoke', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInviteDialog() {
    showDialog(
      context: context,
      builder: (context) => InviteDialog(
        householdId: widget.householdId,
        onInviteSent: (invite) {
          setState(() {
            _pendingInvites.add(invite);
          });
        },
      ),
    );
  }

  Future<void> _handleInviteAction(Invite invite, String action) async {
    try {
      if (action == 'resend') {
        final success = await InviteService.resendInvite(inviteId: invite.id);
        
        if (success) {
          _showSuccessSnackBar('Invite resent successfully');
          _loadData(); // Refresh to get updated expiry
        } else {
          _showErrorSnackBar('Failed to resend invite');
        }
      } else if (action == 'revoke') {
        final success = await InviteService.revokeInvite(inviteId: invite.id);
        
        if (success) {
          _showSuccessSnackBar('Invite revoked');
          setState(() {
            _pendingInvites.removeWhere((i) => i.id == invite.id);
          });
        } else {
          _showErrorSnackBar('Failed to revoke invite');
        }
      }
    } catch (e) {
      _showErrorSnackBar('Error: $e');
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);
    
    if (difference.inDays > 0) {
      return 'in ${difference.inDays} days';
    } else if (difference.inHours > 0) {
      return 'in ${difference.inHours} hours';
    } else {
      return 'soon';
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }
}
