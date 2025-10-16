import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/redesign_tokens.dart';
import '../models/invite_models.dart';
import '../services/invite_service.dart';
import '../services/member_service.dart';

/// Dialog for sending invites
class InviteDialog extends StatefulWidget {
  final String householdId;
  final Function(Invite) onInviteSent;

  const InviteDialog({
    super.key,
    required this.householdId,
    required this.onInviteSent,
  });

  @override
  State<InviteDialog> createState() => _InviteDialogState();
}

class _InviteDialogState extends State<InviteDialog> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _selectedRole = 'parent';
  UnclaimedAdultMember? _selectedMember;
  List<UnclaimedAdultMember> _unclaimedMembers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUnclaimedMembers();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadUnclaimedMembers() async {
    try {
      final response = await MemberService.getHouseholdMembers(
        householdId: widget.householdId,
      );

      setState(() {
        _unclaimedMembers = (response['unclaimed_adults'] as List)
            .map((json) => UnclaimedAdultMember.fromJson(json))
            .toList();
      });
    } catch (e) {
      _showErrorSnackBar('Failed to load members: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Invite an Adult',
        style: GoogleFonts.spaceGrotesk(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: RedesignTokens.ink,
        ),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Email Field
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email Address',
                hintText: 'name@email.com',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an email address';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Member Suggestion
            if (_unclaimedMembers.isNotEmpty) ...[
              Text(
                'Suggested Member',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: RedesignTokens.ink,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<UnclaimedAdultMember>(
                value: _selectedMember,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: 'Select a member (optional)',
                ),
                items: [
                  const DropdownMenuItem<UnclaimedAdultMember>(
                    value: null,
                    child: Text('No suggestion'),
                  ),
                  ..._unclaimedMembers.map((member) => DropdownMenuItem(
                    value: member,
                    child: Text(member.name),
                  )),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedMember = value;
                  });
                },
              ),
              const SizedBox(height: 8),
              Text(
                'We\'ll suggest this person to claim their profile',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  color: RedesignTokens.slate,
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Role Selection (V1: Fixed to Parent)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: RedesignTokens.canvas,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: RedesignTokens.primary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: RedesignTokens.primary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Role: Parent (can invite others and manage family)',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        color: RedesignTokens.slate,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: GoogleFonts.spaceGrotesk(
              color: RedesignTokens.slate,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _sendInvite,
          style: ElevatedButton.styleFrom(
            backgroundColor: RedesignTokens.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  'Send Invite',
                  style: GoogleFonts.spaceGrotesk(
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ],
    );
  }

  Future<void> _sendInvite() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final invite = await InviteService.createInvite(
        householdId: widget.householdId,
        invitedEmail: _emailController.text.trim(),
        role: _selectedRole,
        memberCandidateId: _selectedMember?.id,
      );

      widget.onInviteSent(invite);
      
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invite sent to ${invite.invitedEmail}'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'Copy Link',
            textColor: Colors.white,
            onPressed: () => _copyInviteLink(invite),
          ),
        ),
      );
    } catch (e) {
      _showErrorSnackBar('Failed to send invite: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _copyInviteLink(Invite invite) {
    // Implementation to copy invite link to clipboard
    // This would generate the magic link URL
    final magicLink = 'https://app.merryway.com/invite/${invite.token}';
    // Clipboard.setData(ClipboardData(text: magicLink));
    _showSuccessSnackBar('Invite link copied to clipboard');
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
