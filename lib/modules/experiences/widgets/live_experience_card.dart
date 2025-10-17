import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:html' as html; // For web download
import '../../../modules/core/theme/theme_colors.dart';
import '../../../modules/core/theme/merryway_theme.dart';
import '../../../modules/core/theme/redesign_tokens.dart';
import '../../../modules/family/models/family_models.dart';
import '../models/experience_models.dart';
import '../repositories/experience_repository.dart';
import 'dart:convert';

class LiveExperienceCard extends StatefulWidget {
  final Experience experience;
  final List<FamilyMember> allMembers;
  final VoidCallback onComplete;
  final VoidCallback onCancel;

  const LiveExperienceCard({
    Key? key,
    required this.experience,
    required this.allMembers,
    required this.onComplete,
    required this.onCancel,
  }) : super(key: key);

  @override
  State<LiveExperienceCard> createState() => _LiveExperienceCardState();
}

class _LiveExperienceCardState extends State<LiveExperienceCard> {
  Duration _elapsed = Duration.zero;
  DateTime? _startTime;
  bool _isUpdating = false;
  final ImagePicker _picker = ImagePicker();
  List<String> _photoUrls = [];

  @override
  void initState() {
    super.initState();
    _startTime = widget.experience.startAt ?? DateTime.now();
    _updateElapsed();
    // Update elapsed time every minute
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 60));
      if (mounted) {
        _updateElapsed();
        return true;
      }
      return false;
    });
  }

  void _updateElapsed() {
    if (_startTime != null) {
      setState(() {
        _elapsed = DateTime.now().difference(_startTime!);
      });
    }
  }

  String _formatElapsed() {
    final hours = _elapsed.inHours;
    final minutes = _elapsed.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  List<FamilyMember> _getParticipants() {
    return widget.allMembers
        .where((m) => widget.experience.participantIds.contains(m.id))
        .toList();
  }

  Future<void> _markAsLive() async {
    setState(() => _isUpdating = true);
    try {
      final repository = ExperienceRepository();
      
      // Call Django API to update experience
      await repository.updateExperience(
        widget.experience.id!,
        {
          'status': 'live',
          'start_at': DateTime.now().toIso8601String(),
        },
      );

      setState(() {
        _startTime = DateTime.now();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✨ Started! Have fun!'),
            backgroundColor: RedesignTokens.accentGold,
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
      setState(() => _isUpdating = false);
    }
  }

  Future<void> _markAsDone() async {
    widget.onComplete();
  }

  void _downloadICS() {
    // Generate .ics file content
    final start = widget.experience.startAt ?? DateTime.now();
    final end = widget.experience.endAt ?? start.add(const Duration(hours: 2));
    
    final icsContent = '''BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//Merryway//EN
BEGIN:VEVENT
UID:${widget.experience.id}@merryway.app
DTSTAMP:${_formatDateTimeICS(DateTime.now())}
DTSTART:${_formatDateTimeICS(start)}
DTEND:${_formatDateTimeICS(end)}
SUMMARY:${widget.experience.activityName}
DESCRIPTION:Merryway Experience
${widget.experience.place != null ? 'LOCATION:${widget.experience.place}' : ''}
STATUS:CONFIRMED
END:VEVENT
END:VCALENDAR''';

    // Trigger download for web
    final blob = html.Blob([icsContent], 'text/calendar');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'merryway-experience.ics')
      ..click();
    html.Url.revokeObjectUrl(url);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📅 Calendar event downloaded!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  String _formatDateTimeICS(DateTime dt) {
    return dt.toUtc().toIso8601String().replaceAll(RegExp(r'[-:]'), '').split('.')[0] + 'Z';
  }

  Future<void> _navigate() async {
    if (widget.experience.place != null) {
      final place = Uri.encodeComponent(widget.experience.place!);
      final Uri googleMapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$place');
      
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open maps'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  Future<void> _showPhotoSourceDialog() async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RedesignTokens.radiusCard),
        ),
        title: Text('Add Photo', style: RedesignTokens.titleMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt, color: RedesignTokens.primary),
              title: Text('Take Photo', style: RedesignTokens.body),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: RedesignTokens.accentSage),
              title: Text('Choose from Gallery', style: RedesignTokens.body),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: RedesignTokens.body.copyWith(color: RedesignTokens.slate)),
          ),
        ],
      ),
    );

    if (source != null) {
      await _pickAndUploadPhoto(source);
    }
  }

  Future<void> _pickAndUploadPhoto(ImageSource source) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (photo == null) return;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                ),
                SizedBox(width: 12),
                Text('Uploading photo...'),
              ],
            ),
            duration: Duration(seconds: 30),
          ),
        );
      }

      // Upload to Supabase storage via Django API
      final repository = ExperienceRepository();
      final bytes = await photo.readAsBytes();
      final fileName = 'experience_${widget.experience.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      final mediaItem = await repository.uploadMediaBytes(
        householdId: widget.experience.householdId,
        fileBytes: bytes,
        fileName: fileName,
        experienceId: widget.experience.id,
      );

      if (mediaItem.id != null) {
        setState(() {
          _photoUrls.add(mediaItem.id!);
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Text('Photo added! (${_photoUrls.length} total)'),
              ],
            ),
            backgroundColor: RedesignTokens.primary,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading photo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final participants = _getParticipants();
    final isPlanned = widget.experience.status == ExperienceStatus.planned;
    final isLive = widget.experience.status == ExperienceStatus.live;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: RedesignTokens.getGutter(screenWidth) + 16, // Added extra padding
        vertical: RedesignTokens.space12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(RedesignTokens.radiusCard),
        // Removed the border that was creating the black line
        boxShadow: RedesignTokens.shadowLevel2,
      ),
      child: Padding(
        padding: const EdgeInsets.all(RedesignTokens.space20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (isLive ? RedesignTokens.accentGold : RedesignTokens.primary)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(RedesignTokens.radiusButton),
                  ),
                  child: Icon(
                    isLive ? Icons.play_circle_filled : Icons.schedule,
                    color: isLive ? RedesignTokens.accentGold : RedesignTokens.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: RedesignTokens.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.experience.activityName ?? 'Experience',
                        style: RedesignTokens.titleMedium,
                      ),
                      if (isLive) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: RedesignTokens.accentGold,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Live · ${_formatElapsed()}',
                              style: RedesignTokens.meta.copyWith(
                                color: RedesignTokens.accentGold,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        const SizedBox(height: 4),
                        Text(
                          'Planned',
                          style: RedesignTokens.meta.copyWith(
                            color: RedesignTokens.mutedText,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  onPressed: widget.onCancel,
                  icon: const Icon(Icons.close, size: 20),
                  tooltip: 'Cancel',
                  style: IconButton.styleFrom(
                    foregroundColor: RedesignTokens.slate,
                  ),
                ),
              ],
            ),
            const SizedBox(height: RedesignTokens.space16),

            // Participants (using same chip style as SimplifiedSuggestionCard)
            if (participants.isNotEmpty) ...[
              Wrap(
                spacing: RedesignTokens.space8,
                runSpacing: RedesignTokens.space8,
                children: participants.map((member) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: RedesignTokens.space12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: RedesignTokens.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(RedesignTokens.radiusPill),
                      border: Border.all(
                        color: RedesignTokens.primary.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Avatar circle
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: RedesignTokens.primary,
                            shape: BoxShape.circle,
                            border: member.photoUrl != null
                                ? Border.all(color: Colors.white, width: 2)
                                : null,
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
                                    member.name[0].toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 8),
                        // Name
                        Text(
                          member.name,
                          style: RedesignTokens.meta.copyWith(
                            fontWeight: FontWeight.w600,
                            color: RedesignTokens.slate,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: RedesignTokens.space16),
            ],

            // Place
            if (widget.experience.place != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.place,
                    size: 16,
                    color: RedesignTokens.slate,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      widget.experience.place!,
                      style: RedesignTokens.meta,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: RedesignTokens.space16),
            ],

            // Prep notes
            if (widget.experience.prepNotes != null) ...[
              Container(
                padding: const EdgeInsets.all(RedesignTokens.space12),
                decoration: BoxDecoration(
                  color: RedesignTokens.canvas.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(RedesignTokens.radiusButton),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: RedesignTokens.slate,
                    ),
                    const SizedBox(width: RedesignTokens.space8),
                    Expanded(
                      child: Text(
                        widget.experience.prepNotes!,
                        style: RedesignTokens.body.copyWith(
                          color: RedesignTokens.slate,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: RedesignTokens.space16),
            ],

            // Action buttons
            Row(
              children: [
                if (isPlanned) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isUpdating ? null : _markAsLive,
                      icon: const Icon(Icons.play_arrow, size: 20),
                      label: const Text('Start'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: RedesignTokens.accentGold,
                        foregroundColor: RedesignTokens.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(RedesignTokens.radiusButton),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(width: RedesignTokens.space8),
                ],
                if (isLive) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _markAsDone,
                      icon: const Icon(Icons.check_circle, size: 20),
                      label: const Text('Done'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: RedesignTokens.primary,
                        foregroundColor: RedesignTokens.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(RedesignTokens.radiusButton),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(width: RedesignTokens.space8),
                ],
                IconButton(
                  onPressed: _downloadICS,
                  icon: const Icon(Icons.calendar_today, size: 20),
                  tooltip: 'Add to Calendar',
                  style: IconButton.styleFrom(
                    backgroundColor: RedesignTokens.infoPillBg,
                    foregroundColor: RedesignTokens.slate,
                  ),
                ),
                const SizedBox(width: RedesignTokens.space8),
                IconButton(
                  onPressed: _showPhotoSourceDialog,
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.add_a_photo, size: 20),
                      if (_photoUrls.isNotEmpty)
                        Positioned(
                          right: -4,
                          top: -4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: RedesignTokens.accentGold,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${_photoUrls.length}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  tooltip: 'Add Photo',
                  style: IconButton.styleFrom(
                    backgroundColor: RedesignTokens.infoPillBg,
                    foregroundColor: RedesignTokens.slate,
                  ),
                ),
                if (widget.experience.place != null) ...[
                  const SizedBox(width: RedesignTokens.space8),
                  IconButton(
                    onPressed: _navigate,
                    icon: const Icon(Icons.navigation, size: 20),
                    tooltip: 'Navigate',
                    style: IconButton.styleFrom(
                      backgroundColor: RedesignTokens.infoPillBg,
                      foregroundColor: RedesignTokens.slate,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

