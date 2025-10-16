import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/redesign_tokens.dart';
import '../models/invite_models.dart';
import '../services/invite_service.dart';
import 'auth_screen.dart';

/// Screen for validating invite tokens
class InviteValidationScreen extends StatefulWidget {
  final String token;

  const InviteValidationScreen({
    super.key,
    required this.token,
  });

  @override
  State<InviteValidationScreen> createState() => _InviteValidationScreenState();
}

class _InviteValidationScreenState extends State<InviteValidationScreen> {
  InviteValidation? _validation;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _validateInvite();
  }

  Future<void> _validateInvite() async {
    try {
      final validation = await InviteService.validateInvite(widget.token);
      
      setState(() {
        _validation = validation;
        _isLoading = false;
      });

      if (!validation.isValid) {
        setState(() {
          _error = validation.errorMessage ?? 'Invalid invite link';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to validate invite: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Join Family',
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
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(RedesignTokens.primary),
            ),
            const SizedBox(height: 16),
            Text(
              'Validating invite...',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                color: RedesignTokens.slate,
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_validation != null) {
      return _buildInviteDetails();
    }

    return Center(
      child: Text(
        'Something went wrong',
        style: GoogleFonts.spaceGrotesk(
          fontSize: 16,
          color: RedesignTokens.slate,
        ),
      ),
    );
  }

  Widget _buildErrorState() {
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
              'Invalid Invite',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 24,
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
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: RedesignTokens.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInviteDetails() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [RedesignTokens.primary, RedesignTokens.accentGold],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.family_restroom,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                Text(
                  'Welcome!',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You\'re joining ${_validation!.householdName}',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Invite Details
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Invite Details',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: RedesignTokens.ink,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow('Email', _validation!.invitedEmail),
                  _buildDetailRow('Household', _validation!.householdName),
                  _buildDetailRow('Role', 'Parent'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Suggested Member (if any)
          if (_validation!.memberCandidate != null) ...[
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person, color: RedesignTokens.primary),
                        const SizedBox(width: 8),
                        Text(
                          'We think you\'re ${_validation!.memberCandidate!['name']}',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: RedesignTokens.ink,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This person is already in the family. You can claim this profile or create a new one.',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        color: RedesignTokens.slate,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Continue Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _continueToAuth,
              style: ElevatedButton.styleFrom(
                backgroundColor: RedesignTokens.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
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
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                color: RedesignTokens.slate,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                color: RedesignTokens.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _continueToAuth() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AuthScreen(
          token: widget.token,
          validation: _validation!,
        ),
      ),
    );
  }
}
