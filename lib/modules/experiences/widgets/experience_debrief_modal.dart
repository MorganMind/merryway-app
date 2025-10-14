import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../../../modules/core/theme/theme_colors.dart';
import '../../../modules/core/theme/merryway_theme.dart';
import '../models/experience_models.dart';
import '../repositories/experience_repository.dart';

class ExperienceDebriefModal extends StatefulWidget {
  final Experience experience;
  final VoidCallback onComplete;

  const ExperienceDebriefModal({
    Key? key,
    required this.experience,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<ExperienceDebriefModal> createState() => _ExperienceDebriefModalState();
}

class _ExperienceDebriefModalState extends State<ExperienceDebriefModal>
    with SingleTickerProviderStateMixin {
  int _rating = 3;
  String? _effortFelt;
  String? _cleanupFelt;
  final _noteController = TextEditingController();
  XFile? _photo;
  bool _isSubmitting = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final photo = await picker.pickImage(source: ImageSource.gallery);
    if (photo != null) {
      setState(() => _photo = photo);
    }
  }

  Future<void> _submitDebrief() async {
    setState(() => _isSubmitting = true);

    try {
      final supabase = Supabase.instance.client;
      final currentUserId = supabase.auth.currentUser?.id;
      final repository = ExperienceRepository();

      // 1. Create review (Django will handle cascading updates)
      final review = ExperienceReview(
        experienceId: widget.experience.id!,
        householdId: widget.experience.householdId,
        rating: _rating,
        effortFelt: _effortFelt,
        cleanupFelt: _cleanupFelt,
        note: _noteController.text.isNotEmpty ? _noteController.text : null,
        reviewedBy: currentUserId,
      );

      // Call Django API - this will:
      // - Create review
      // - Mark experience as done
      // - Update learning weights
      await repository.createReview(review);

      // 2. Create Merry Moment
      final moment = MerryMoment(
        householdId: widget.experience.householdId,
        experienceId: widget.experience.id,
        title: widget.experience.activityName ?? 'Experience',
        description: _noteController.text.isNotEmpty ? _noteController.text : null,
        participantIds: widget.experience.participantIds,
        occurredAt: widget.experience.startAt ?? DateTime.now(),
        place: widget.experience.place,
        createdBy: currentUserId,
        isManual: false,
      );

      // Call Django API - this will:
      // - Create merry moment
      // - Update household.last_activity_at
      final createdMoment = await repository.createMerryMoment(moment);

      // 3. Upload photo if provided
      if (_photo != null) {
        try {
          await repository.uploadMedia(
            householdId: widget.experience.householdId,
            filePath: _photo!.path,
            merryMomentId: createdMoment.id,
            experienceId: widget.experience.id,
            caption: _noteController.text.isNotEmpty ? _noteController.text : null,
          );
        } catch (e) {
          debugPrint('Photo upload failed: $e');
          // Don't fail the whole flow if photo upload fails
        }
      }

      if (mounted) {
        Navigator.of(context).pop();
        widget.onComplete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✨ Merry Moment created!'),
            backgroundColor: MerryWayTheme.primarySoftBlue,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 400),
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
                        color: MerryWayTheme.accentGolden.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.star,
                        color: MerryWayTheme.accentGolden,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Quick Debrief',
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
                  'How was it? (10 seconds!)',
                  style: TextStyle(
                    fontSize: 14,
                    color: MerryWayTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 24),

                // Rating (1-5 stars)
                const Text(
                  'Overall rating',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: MerryWayTheme.textDark,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final starValue = index + 1;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _rating = starValue);
                      },
                      child: Icon(
                        _rating >= starValue ? Icons.star : Icons.star_border,
                        color: MerryWayTheme.accentGolden,
                        size: 40,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),

                // Effort felt
                const Text(
                  'Effort felt',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: MerryWayTheme.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Easy'),
                        selected: _effortFelt == 'easy',
                        onSelected: (selected) {
                          if (selected) setState(() => _effortFelt = 'easy');
                        },
                        selectedColor: MerryWayTheme.primarySoftBlue.withOpacity(0.3),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Moderate'),
                        selected: _effortFelt == 'moderate',
                        onSelected: (selected) {
                          if (selected) setState(() => _effortFelt = 'moderate');
                        },
                        selectedColor: MerryWayTheme.accentGolden.withOpacity(0.3),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Hard'),
                        selected: _effortFelt == 'hard',
                        onSelected: (selected) {
                          if (selected) setState(() => _effortFelt = 'hard');
                        },
                        selectedColor: MerryWayTheme.accentLavender.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Cleanup felt
                const Text(
                  'Cleanup felt',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: MerryWayTheme.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Easy'),
                        selected: _cleanupFelt == 'easy',
                        onSelected: (selected) {
                          if (selected) setState(() => _cleanupFelt = 'easy');
                        },
                        selectedColor: MerryWayTheme.primarySoftBlue.withOpacity(0.3),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Moderate'),
                        selected: _cleanupFelt == 'moderate',
                        onSelected: (selected) {
                          if (selected) setState(() => _cleanupFelt = 'moderate');
                        },
                        selectedColor: MerryWayTheme.accentGolden.withOpacity(0.3),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Hard'),
                        selected: _cleanupFelt == 'hard',
                        onSelected: (selected) {
                          if (selected) setState(() => _cleanupFelt = 'hard');
                        },
                        selectedColor: MerryWayTheme.accentLavender.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // One-line note
                const Text(
                  'One-line note (optional)',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: MerryWayTheme.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    hintText: 'Kids loved the swings!',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLength: 140,
                ),
                const SizedBox(height: 12),

                // Photo upload
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: _pickPhoto,
                      icon: const Icon(Icons.add_photo_alternate, size: 20),
                      label: Text(_photo == null ? 'Add Photo' : 'Photo Added'),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: _photo != null
                              ? MerryWayTheme.accentGolden
                              : MerryWayTheme.textMuted,
                        ),
                      ),
                    ),
                    if (_photo != null) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.check_circle, color: MerryWayTheme.accentGolden, size: 20),
                    ],
                  ],
                ),
                const SizedBox(height: 24),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitDebrief,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: MerryWayTheme.primarySoftBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Save & Create Merry Moment',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

