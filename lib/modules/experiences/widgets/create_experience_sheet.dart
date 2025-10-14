import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../modules/core/theme/theme_colors.dart';
import '../../../modules/core/theme/merryway_theme.dart';
import '../../../modules/family/models/family_models.dart';
import '../models/experience_models.dart';
import '../repositories/experience_repository.dart';

class CreateExperienceSheet extends StatefulWidget {
  final String householdId;
  final List<FamilyMember> allMembers;
  final List<String> initialParticipantIds;
  final String activityName;
  final String? suggestionId;

  const CreateExperienceSheet({
    Key? key,
    required this.householdId,
    required this.allMembers,
    required this.initialParticipantIds,
    required this.activityName,
    this.suggestionId,
  }) : super(key: key);

  @override
  State<CreateExperienceSheet> createState() => _CreateExperienceSheetState();
}

class _CreateExperienceSheetState extends State<CreateExperienceSheet> {
  late Set<String> _selectedParticipants;
  String _timeWindow = 'now'; // now, later, today
  DateTime? _customStartTime;
  String? _place;
  final _placeController = TextEditingController();
  final _prepNotesController = TextEditingController();
  bool _needsAdult = false;
  double? _costEstimate;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _selectedParticipants = Set.from(widget.initialParticipantIds);
  }

  @override
  void dispose() {
    _placeController.dispose();
    _prepNotesController.dispose();
    super.dispose();
  }

  Future<void> _createExperience() async {
    if (_selectedParticipants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one participant')),
      );
      return;
    }

    setState(() => _isCreating = true);

    try {
      final supabase = Supabase.instance.client;
      final currentUserId = supabase.auth.currentUser?.id;
      final repository = ExperienceRepository();

      // Determine start/end times based on time window
      DateTime? startAt;
      DateTime? endAt;
      
      if (_timeWindow == 'now') {
        startAt = DateTime.now();
      } else if (_timeWindow == 'today') {
        startAt = DateTime.now().add(const Duration(hours: 1));
      } else if (_customStartTime != null) {
        startAt = _customStartTime;
      }

      final experience = Experience(
        householdId: widget.householdId,
        activityName: widget.activityName,
        suggestionId: widget.suggestionId,
        participantIds: _selectedParticipants.toList(),
        startAt: startAt,
        endAt: endAt,
        place: _place,
        status: _timeWindow == 'now' ? ExperienceStatus.live : ExperienceStatus.planned,
        prepNotes: _prepNotesController.text.isNotEmpty ? _prepNotesController.text : null,
        needsAdult: _needsAdult,
        costEstimate: _costEstimate,
        createdBy: currentUserId,
      );

      // Call Django API instead of direct Supabase
      final createdExperience = await repository.createExperience(experience);

      if (mounted) {
        Navigator.of(context).pop(createdExperience);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _timeWindow == 'now' 
                  ? '✨ Experience started! Enjoy!' 
                  : '✅ Experience planned!',
            ),
            backgroundColor: MerryWayTheme.primarySoftBlue,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating experience: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
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
                    color: MerryWayTheme.primarySoftBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.event_available,
                    color: MerryWayTheme.primarySoftBlue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Make it an Experience',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: MerryWayTheme.textDark,
                        ),
                      ),
                      Text(
                        widget.activityName,
                        style: const TextStyle(
                          fontSize: 14,
                          color: MerryWayTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Participants
            const Text(
              'Who\'s joining?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: MerryWayTheme.textDark,
              ),
            ),
            const SizedBox(height: 12),
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
                    style: const TextStyle(fontSize: 16),
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
            const SizedBox(height: 24),

            // Time window
            const Text(
              'When?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: MerryWayTheme.textDark,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Now'),
                    selected: _timeWindow == 'now',
                    onSelected: (selected) {
                      if (selected) setState(() => _timeWindow = 'now');
                    },
                    selectedColor: MerryWayTheme.accentGolden.withOpacity(0.3),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Today'),
                    selected: _timeWindow == 'today',
                    onSelected: (selected) {
                      if (selected) setState(() => _timeWindow = 'today');
                    },
                    selectedColor: MerryWayTheme.primarySoftBlue.withOpacity(0.3),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Later'),
                    selected: _timeWindow == 'later',
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _timeWindow = 'later');
                        _pickCustomTime();
                      }
                    },
                    selectedColor: MerryWayTheme.accentLavender.withOpacity(0.3),
                  ),
                ),
              ],
            ),
            if (_timeWindow == 'later' && _customStartTime != null) ...[
              const SizedBox(height: 8),
              Text(
                'Scheduled for: ${_customStartTime!.toString().substring(0, 16)}',
                style: const TextStyle(
                  fontSize: 13,
                  color: MerryWayTheme.textMuted,
                ),
              ),
            ],
            const SizedBox(height: 24),

            // Place (optional)
            const Text(
              'Place (optional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: MerryWayTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _placeController,
              decoration: InputDecoration(
                hintText: 'Golden Gate Park, Library, Home...',
                prefixIcon: const Icon(Icons.place_outlined, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() => _place = value.isNotEmpty ? value : null);
              },
            ),
            const SizedBox(height: 24),

            // Prep notes (optional)
            const Text(
              'Prep notes (optional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: MerryWayTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _prepNotesController,
              decoration: InputDecoration(
                hintText: 'Bring snacks, sunscreen, etc.',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // Needs adult & cost
            Row(
              children: [
                Expanded(
                  child: CheckboxListTile(
                    value: _needsAdult,
                    onChanged: (value) {
                      setState(() => _needsAdult = value ?? false);
                    },
                    title: const Text(
                      'Needs adult',
                      style: TextStyle(fontSize: 14),
                    ),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Create button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isCreating ? null : _createExperience,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: MerryWayTheme.primarySoftBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isCreating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _timeWindow == 'now' ? 'Start Now! 🎉' : 'Plan It',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _pickCustomTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null && mounted) {
        setState(() {
          _customStartTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }
}

