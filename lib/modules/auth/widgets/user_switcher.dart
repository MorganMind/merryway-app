import 'package:flutter/material.dart';
import '../../family/models/family_models.dart';
import '../../core/theme/redesign_tokens.dart';

class UserSwitcher extends StatefulWidget {
  final List<FamilyMember> members;
  final FamilyMember? currentUser;
  final Function(FamilyMember) onUserSelected;

  const UserSwitcher({
    super.key,
    required this.members,
    required this.currentUser,
    required this.onUserSelected,
  });

  @override
  State<UserSwitcher> createState() => _UserSwitcherState();
}

class _UserSwitcherState extends State<UserSwitcher> {
  bool _showPinEntry = false;
  FamilyMember? _pendingMember;
  final TextEditingController _pinController = TextEditingController();

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _selectUser(FamilyMember member) async {
    // Check if PIN is required
    if (member.pinRequired && member.devicePin != null && member.devicePin!.isNotEmpty) {
      _pendingMember = member;
      _showPinDialog();
    } else {
      // No PIN required, switch immediately
      widget.onUserSelected(member);
    }
  }

  void _showPinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: RedesignTokens.primary,
                    borderRadius: BorderRadius.circular(6),
                    image: _pendingMember?.photoUrl != null
                        ? DecorationImage(
                            image: NetworkImage(_pendingMember!.photoUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _pendingMember?.photoUrl == null
                      ? Center(
                          child: Text(
                            _pendingMember?.avatarEmoji ?? '👤',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _pendingMember?.name ?? '',
                        style: RedesignTokens.body.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Enter PIN',
                        style: RedesignTokens.caption.copyWith(
                          color: RedesignTokens.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _cancelPinEntry,
                  icon: const Icon(Icons.close, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // PIN input
            TextField(
              controller: _pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'PIN',
                hintText: '6-digit PIN',
                counterText: '',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _verifyPin(),
            ),
            const SizedBox(height: 16),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _cancelPinEntry,
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _verifyPin,
                    child: const Text('Verify'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _verifyPin() {
    if (_pendingMember == null) return;

    if (_pinController.text == _pendingMember!.devicePin) {
      // PIN correct
      widget.onUserSelected(_pendingMember!);
      _pinController.clear();
      _pendingMember = null;
      Navigator.of(context).pop(); // Close dialog
    } else {
      // PIN incorrect
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Incorrect PIN')),
      );
      _pinController.clear();
    }
  }

  void _cancelPinEntry() {
    _pinController.clear();
    _pendingMember = null;
    Navigator.of(context).pop(); // Close dialog
  }

  @override
  Widget build(BuildContext context) {
    if (_showPinEntry) {
      return _buildPinEntry();
    }

    return PopupMenuButton<FamilyMember>(
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 8,
      itemBuilder: (context) {
        return widget.members.map((member) {
          final isSelected = member.id == widget.currentUser?.id;
          
          return PopupMenuItem<FamilyMember>(
            value: member,
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? RedesignTokens.primary
                        : RedesignTokens.divider,
                    borderRadius: BorderRadius.circular(6),
                    image: member.photoUrl != null
                        ? DecorationImage(
                            image: NetworkImage(member.photoUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: member.photoUrl == null
                      ? Center(
                          child: Text(
                            member.avatarEmoji ?? '👤',
                            style: TextStyle(
                              fontSize: 16,
                              color: isSelected ? Colors.white : RedesignTokens.slate,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                // Name & role
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        member.name,
                        style: RedesignTokens.body.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _formatRole(member.role),
                        style: RedesignTokens.caption.copyWith(
                          color: RedesignTokens.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
                // Checkmark for selected
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: RedesignTokens.primary,
                    size: 20,
                  ),
              ],
            ),
          );
        }).toList();
      },
      onSelected: (member) => _selectUser(member),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: RedesignTokens.space12, vertical: RedesignTokens.space8),
        decoration: BoxDecoration(
          color: RedesignTokens.primary.withOpacity(0.04), // 50% lighter (was 0.08)
          borderRadius: BorderRadius.circular(RedesignTokens.radiusButton),
          border: Border.all(
            color: RedesignTokens.primary.withOpacity(0.075), // 50% lighter (was 0.15)
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: RedesignTokens.primary,
                borderRadius: BorderRadius.circular(4),
                image: widget.currentUser?.photoUrl != null
                    ? DecorationImage(
                        image: NetworkImage(widget.currentUser!.photoUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: widget.currentUser?.photoUrl == null
                  ? Center(
                      child: Text(
                        widget.currentUser?.avatarEmoji ?? '👤',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            // Name (truncated if too long)
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 80),
              child: Text(
                widget.currentUser?.name ?? 'Who?',
                style: RedesignTokens.meta.copyWith(
                  fontWeight: FontWeight.w600,
                  color: RedesignTokens.primary,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 4),
            // Chevron
            Icon(
              Icons.expand_more,
              size: 16,
              color: RedesignTokens.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPinEntry() {
    return Material(
      elevation: 16,
      borderRadius: BorderRadius.circular(12),
      color: Colors.white,
      child: Container(
        width: 240,
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: RedesignTokens.primary,
                    borderRadius: BorderRadius.circular(6),
                    image: _pendingMember?.photoUrl != null
                        ? DecorationImage(
                            image: NetworkImage(_pendingMember!.photoUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _pendingMember?.photoUrl == null
                      ? Center(
                          child: Text(
                            _pendingMember?.avatarEmoji ?? '👤',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _pendingMember?.name ?? '',
                        style: RedesignTokens.body.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Enter PIN',
                        style: RedesignTokens.caption.copyWith(
                          color: RedesignTokens.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _cancelPinEntry,
                  icon: const Icon(Icons.close, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // PIN input
            TextField(
              controller: _pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'PIN',
                hintText: '6-digit PIN',
                counterText: '',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _verifyPin(),
            ),
            const SizedBox(height: 16),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _cancelPinEntry,
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _verifyPin,
                    child: const Text('Verify'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatRole(MemberRole role) {
    switch (role) {
      case MemberRole.parent:
        return 'Parent';
      case MemberRole.caregiver:
        return 'Caregiver';
      case MemberRole.teen:
        return 'Teen';
      case MemberRole.child:
        return 'Child';
    }
  }
}
