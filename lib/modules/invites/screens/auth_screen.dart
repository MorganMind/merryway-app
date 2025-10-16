import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/redesign_tokens.dart';
import '../models/invite_models.dart';
import 'claim_member_screen.dart';

/// Screen for authentication during invite flow
class AuthScreen extends StatefulWidget {
  final String token;
  final InviteValidation validation;

  const AuthScreen({
    super.key,
    required this.token,
    required this.validation,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.validation.invitedEmail ?? '';
    _checkExistingUser();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _checkExistingUser() async {
    // Check if user is already logged in
    final userId = await _getCurrentUserId();
    if (userId != null) {
      setState(() => _currentUserId = userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sign In',
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sign in to continue',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: RedesignTokens.ink,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Use the same email address that received the invite',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  color: RedesignTokens.slate,
                ),
              ),
              const SizedBox(height: 24),

              // Email Field
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email address';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Continue Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _continue,
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

              const SizedBox(height: 16),

              // Alternative: Create Account
              Center(
                child: TextButton(
                  onPressed: _showCreateAccountDialog,
                  child: Text(
                    'Don\'t have an account? Create one',
                    style: GoogleFonts.spaceGrotesk(
                      color: RedesignTokens.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _continue() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // In a real implementation, this would handle authentication
      // For now, we'll proceed to the member selection screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ClaimMemberScreen(
            token: widget.token,
            validation: widget.validation,
            userEmail: _emailController.text.trim(),
          ),
        ),
      );
    } catch (e) {
      _showErrorSnackBar('Authentication failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showCreateAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Create Account',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: RedesignTokens.ink,
          ),
        ),
        content: Text(
          'We\'ll create a new account for ${_emailController.text} and send you a verification email.',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 16,
            color: RedesignTokens.slate,
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
            onPressed: () {
              Navigator.pop(context);
              _continue();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: RedesignTokens.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Create Account',
              style: GoogleFonts.spaceGrotesk(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<String?> _getCurrentUserId() async {
    // Implementation to get current user ID
    return null;
  }
}
