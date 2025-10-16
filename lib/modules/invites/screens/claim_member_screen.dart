import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/redesign_tokens.dart';
import '../models/invite_models.dart';
import '../services/invite_service.dart';
import 'onboarding_screen.dart';

/// Screen for claiming a member profile during invite flow
class ClaimMemberScreen extends StatefulWidget {
  final String token;
  final InviteValidation validation;
  final String userEmail;

  const ClaimMemberScreen({
    super.key,
    required this.token,
    required this.validation,
    required this.userEmail,
  });

  @override
  State<ClaimMemberScreen> createState() => _ClaimMemberScreenState();
}

class _ClaimMemberScreenState extends State<ClaimMemberScreen> {
  String? _selectedMemberId;
  String _newMemberName = '';
  bool _isCreatingNew = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Who are you?',
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Who are you in ${widget.validation.householdName}?',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: RedesignTokens.ink,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose your profile or create a new one',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                color: RedesignTokens.slate,
              ),
            ),
            const SizedBox(height: 24),

            // Suggested Member (if any)
            if (widget.validation.memberCandidate != null) ...[
              _buildSuggestedMember(),
              const SizedBox(height: 16),
            ],

            // Existing Members
            if (widget.validation.suggestedMembers.isNotEmpty) ...[
              Text(
                'Existing Family Members',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: RedesignTokens.ink,
                ),
              ),
              const SizedBox(height: 12),
              ...widget.validation.suggestedMembers.map((member) => 
                _buildMemberOption(member)),
              const SizedBox(height: 16),
            ],

            // Create New Option
            _buildCreateNewOption(),

            const SizedBox(height: 24),

            // Continue Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canContinue() ? _continue : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: RedesignTokens.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
                        'Continue',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestedMember() {
    final member = widget.validation.memberCandidate!;
    return Card(
      color: RedesignTokens.primary.withOpacity(0.1),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedMemberId = member['id'];
            _isCreatingNew = false;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.star, color: RedesignTokens.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'We think you\'re ${member['name']}',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: RedesignTokens.primary,
                      ),
                    ),
                    Text(
                      'Recommended match',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        color: RedesignTokens.slate,
                      ),
                    ),
                  ],
                ),
              ),
              Radio<String>(
                value: member['id'],
                groupValue: _selectedMemberId,
                onChanged: (value) {
                  setState(() {
                    _selectedMemberId = value;
                    _isCreatingNew = false;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMemberOption(Map<String, dynamic> member) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedMemberId = member['id'];
            _isCreatingNew = false;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: RedesignTokens.primary,
                child: Text(
                  member['name'][0].toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  member['name'],
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    color: RedesignTokens.ink,
                  ),
                ),
              ),
              Radio<String>(
                value: member['id'],
                groupValue: _selectedMemberId,
                onChanged: (value) {
                  setState(() {
                    _selectedMemberId = value;
                    _isCreatingNew = false;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateNewOption() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _isCreatingNew = true;
            _selectedMemberId = null;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.person_add, color: RedesignTokens.slate),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'I\'m not on this list',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        color: RedesignTokens.ink,
                      ),
                    ),
                  ),
                  Radio<bool>(
                    value: true,
                    groupValue: _isCreatingNew,
                    onChanged: (value) {
                      setState(() {
                        _isCreatingNew = value ?? false;
                        _selectedMemberId = null;
                      });
                    },
                  ),
                ],
              ),
              if (_isCreatingNew) ...[
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Your Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _newMemberName = value;
                    });
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  bool _canContinue() {
    if (_isCreatingNew) {
      return _newMemberName.trim().isNotEmpty;
    }
    return _selectedMemberId != null;
  }

  Future<void> _continue() async {
    setState(() => _isLoading = true);

    try {
      Map<String, dynamic> memberChoice;
      
      if (_isCreatingNew) {
        memberChoice = {
          'create_new': {
            'name': _newMemberName.trim(),
          },
        };
      } else {
        memberChoice = {
          'member_id': _selectedMemberId,
        };
      }

      final result = await InviteService.acceptInvite(
        token: widget.token,
        userId: null, // Would be set in real implementation
        email: widget.userEmail,
        memberChoice: memberChoice,
        role: 'parent',
      );

      if (result['success']) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OnboardingScreen(
              householdId: result['household_id'],
              householdName: result['household_name'],
              memberName: result['member_name'],
            ),
          ),
        );
      } else {
        _showErrorSnackBar(result['message'] ?? 'Failed to join family');
      }
    } catch (e) {
      _showErrorSnackBar('Error: $e');
    } finally {
      setState(() => _isLoading = false);
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
}
