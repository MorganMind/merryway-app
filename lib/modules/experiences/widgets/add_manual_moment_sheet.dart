import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../config/environment.dart';
import '../../../modules/core/theme/theme_colors.dart';
import '../../../modules/family/models/family_models.dart';
import '../models/experience_models.dart';
import '../repositories/experience_repository.dart';

// Access MerryWayTheme constants
class MerryWayTheme {
  static const Color primarySoftBlue = Color(0xFF91C8E4);
  static const Color accentLavender = Color(0xFFB4A7D6);
  static const Color accentGolden = Color(0xFFFFD700);
  static const Color accentSoftPink = Color(0xFFFFB6C1);
  static const Color textDark = Color(0xFF2D3436);
  static const Color textMuted = Color(0xFF636E72);
}

class AddManualMomentSheet extends StatefulWidget {
  final String householdId;
  final List<FamilyMember> allMembers;

  const AddManualMomentSheet({
    Key? key,
    required this.householdId,
    required this.allMembers,
  }) : super(key: key);

  @override
  State<AddManualMomentSheet> createState() => _AddManualMomentSheetState();
}

class _AddManualMomentSheetState extends State<AddManualMomentSheet> {
  final _textController = TextEditingController();
  final _titleController = TextEditingController();
  final _placeController = TextEditingController();
  Set<String> _selectedParticipants = {};
  DateTime? _occurredAt;
  bool _isProcessing = false;
  bool _isParsed = false;
  String _inputMode = 'text'; // text or voice

  @override
  void dispose() {
    _textController.dispose();
    _titleController.dispose();
    _placeController.dispose();
    super.dispose();
  }

  Future<void> _parseWithOpenAI() async {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter some text')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // Call backend to parse the natural language input with OpenAI
      // (API key is stored securely on the backend)
      final supabase = Supabase.instance.client;
      final token = supabase.auth.currentSession?.accessToken ?? '';
      
      final response = await http.post(
        Uri.parse('${Environment.apiUrl}/parse-journal-entry/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'text': _textController.text,
          'family_member_names': widget.allMembers.map((m) => m.name).toList(),
        }),
      );

      if (response.statusCode == 200) {
        // Backend returns parsed data directly
        final parsed = jsonDecode(response.body);
        
        setState(() {
          _titleController.text = parsed['title'] ?? 'Merry Moment';
          _placeController.text = parsed['place'] ?? '';
          
          // Match participants by name
          final participantNames = List<String>.from(parsed['participants'] ?? []);
          _selectedParticipants = widget.allMembers
              .where((m) => participantNames.any((name) => 
                  m.name.toLowerCase().contains(name.toLowerCase()) ||
                  name.toLowerCase().contains(m.name.toLowerCase())))
              .map((m) => m.id!)
              .toSet();
          
          // Parse date
          if (parsed['occurred_at'] != null) {
            try {
              _occurredAt = DateTime.parse(parsed['occurred_at']);
            } catch (e) {
              _occurredAt = DateTime.now();
            }
          } else {
            _occurredAt = DateTime.now();
          }
          
          _isParsed = true;
        });
      } else {
        throw Exception('Backend parsing error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error parsing: $e')),
        );
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _saveMoment() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    if (_selectedParticipants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one participant')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final supabase = Supabase.instance.client;
      final currentUserId = supabase.auth.currentUser?.id;
      final repository = ExperienceRepository();

      final moment = MerryMoment(
        householdId: widget.householdId,
        title: _titleController.text.trim(),
        description: _textController.text.trim().isNotEmpty ? _textController.text.trim() : null,
        participantIds: _selectedParticipants.toList(),
        occurredAt: _occurredAt ?? DateTime.now(),
        place: _placeController.text.trim().isNotEmpty ? _placeController.text.trim() : null,
        createdBy: currentUserId,
        isManual: true,
      );

      // Call Django API - this will:
      // - Create merry moment
      // - Update household.last_activity_at
      await repository.createMerryMoment(moment);

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✨ Merry Moment saved!'),
            backgroundColor: MerryWayTheme.accentGolden,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: MerryWayTheme.accentSoftPink.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.edit,
                    color: MerryWayTheme.accentSoftPink,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Add Merry Moment',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: MerryWayTheme.textDark,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Journal your family\'s memories',
              style: TextStyle(
                fontSize: 14,
                color: MerryWayTheme.textMuted,
              ),
            ),
            const SizedBox(height: 24),

            // Natural language input
            const Text(
              'What happened?',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: MerryWayTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Today Sarah and I went to the park, then the whole family had pizza...',
                hintStyle: const TextStyle(fontSize: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.auto_awesome),
                  onPressed: _isProcessing ? null : _parseWithOpenAI,
                  tooltip: 'Parse with AI',
                  color: MerryWayTheme.accentGolden,
                ),
              ),
              maxLines: 3,
              enabled: !_isProcessing,
            ),
            const SizedBox(height: 12),

            // Parse button
            if (!_isParsed) ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isProcessing ? null : _parseWithOpenAI,
                  icon: _isProcessing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.auto_awesome, size: 18),
                  label: Text(_isProcessing ? 'Processing...' : 'Parse with AI'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: MerryWayTheme.accentGolden),
                    foregroundColor: MerryWayTheme.accentGolden,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
            ],

            // Manual fields (shown after parsing or for manual entry)
            const Text(
              'Title',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: MerryWayTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Park Day',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Participants
            const Text(
              'Who was there?',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: MerryWayTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.allMembers.map((member) {
                final isSelected = _selectedParticipants.contains(member.id);
                return FilterChip(
                  selected: isSelected,
                  label: Text(member.name),
                  avatar: Text(
                    member.avatarEmoji ?? member.name.substring(0, 1),
                    style: const TextStyle(fontSize: 14),
                  ),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedParticipants.add(member.id!);
                      } else {
                        _selectedParticipants.remove(member.id);
                      }
                    });
                  },
                  selectedColor: MerryWayTheme.primarySoftBlue.withOpacity(0.2),
                  checkmarkColor: MerryWayTheme.primarySoftBlue,
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Date
            const Text(
              'When?',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: MerryWayTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _occurredAt ?? DateTime.now(),
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() => _occurredAt = date);
                }
              },
              icon: const Icon(Icons.calendar_today, size: 18),
              label: Text(
                _occurredAt != null
                    ? '${_occurredAt!.month}/${_occurredAt!.day}/${_occurredAt!.year}'
                    : 'Select Date',
              ),
            ),
            const SizedBox(height: 16),

            // Place (optional)
            const Text(
              'Place (optional)',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: MerryWayTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _placeController,
              decoration: InputDecoration(
                hintText: 'Golden Gate Park',
                prefixIcon: const Icon(Icons.place_outlined, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _saveMoment,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: MerryWayTheme.primarySoftBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Save Moment',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

