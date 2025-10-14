import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../modules/core/theme/theme_colors.dart';
import '../../../modules/core/theme/redesign_tokens.dart';
import '../../../modules/family/models/family_models.dart';
import '../../../modules/home/widgets/compact_header.dart';
import '../models/experience_models.dart';
import '../repositories/experience_repository.dart';
import '../widgets/add_manual_moment_sheet.dart';
import '../widgets/experience_debrief_modal.dart';

class MomentsPage extends StatefulWidget {
  final String householdId;
  final List<FamilyMember> allMembers;

  const MomentsPage({
    Key? key,
    required this.householdId,
    required this.allMembers,
  }) : super(key: key);

  @override
  State<MomentsPage> createState() => _MomentsPageState();
}

class _MomentsPageState extends State<MomentsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ExperienceRepository _repository = ExperienceRepository();
  final ImagePicker _picker = ImagePicker();

  List<Experience> _upcomingExperiences = [];
  List<Experience> _completedExperiences = [];
  List<MerryMoment> _merryMoments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAllMoments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllMoments() async {
    setState(() => _isLoading = true);

    try {
      // Load planned experiences
      final planned = await _repository.listExperiences(
        widget.householdId,
        status: 'planned',
      );

      // Load completed experiences
      final completed = await _repository.listExperiences(
        widget.householdId,
        status: 'done',
      );

      // Load merry moments
      final supabase = Supabase.instance.client;
      final momentsResponse = await supabase
          .from('merry_moments')
          .select()
          .eq('household_id', widget.householdId)
          .order('occurred_at', ascending: false);

      final moments = (momentsResponse as List)
          .map((json) => MerryMoment.fromJson(json))
          .toList();

      setState(() {
        _upcomingExperiences = planned;
        _completedExperiences = completed;
        _merryMoments = moments;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading moments: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showAddManualMomentSheet() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddManualMomentSheet(
        householdId: widget.householdId,
        allMembers: widget.allMembers,
      ),
    );

    if (result == true) {
      _loadAllMoments();
    }
  }

  Future<void> _markExperienceComplete(Experience experience) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExperienceDebriefModal(
        experience: experience,
        onComplete: () {
          Navigator.pop(context, true);
        },
      ),
    );

    if (result == true) {
      _loadAllMoments();
    }
  }

  void _showCompletedExperienceDetail(Experience experience) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildCompletedDetailSheet(experience),
    );
  }

  void _showMomentDetail(MerryMoment moment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildMomentDetailSheet(moment),
    );
  }

  Future<void> _showPhotoSourceDialog(dynamic item) async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Photo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: RedesignTokens.primary),
              title: const Text('Take Photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: RedesignTokens.accentSage),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (source != null) {
      await _pickAndUploadPhoto(source, item);
    }
  }

  Future<void> _pickAndUploadPhoto(ImageSource source, dynamic item) async {
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
      final String? experienceId = item is Experience ? item.id : null;
      final String? momentId = item is MerryMoment ? item.id : null;
      final bytes = await photo.readAsBytes();
      final String itemId = experienceId ?? momentId ?? 'unknown';
      final fileName = 'moment_${itemId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      await _repository.uploadMediaBytes(
        householdId: widget.householdId,
        fileBytes: bytes,
        fileName: fileName,
        experienceId: experienceId,
        merryMomentId: momentId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Text('Photo added!'),
              ],
            ),
            backgroundColor: RedesignTokens.primary,
            duration: Duration(seconds: 2),
          ),
        );
        
        // Reload to show updated photo count
        _loadAllMoments();
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
    return Scaffold(
      backgroundColor: RedesignTokens.canvas,
      body: Column(
        children: [
          // Compact Header
          CompactHeader(
            isIdeasActive: false,
            isPlannerActive: false,
            isMomentsActive: true,
            onIdeas: () => context.go('/'),
            onPlanner: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Planner coming soon!')),
              );
            },
            onTime: () {
              // Navigate to Time dashboard
            },
            onMoments: () {
              // Already on moments page
            },
            onSettings: () => context.go('/settings'),
            onHelp: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Help coming soon!')),
              );
            },
            onLogout: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
              
              if (confirmed == true && context.mounted) {
                await Supabase.instance.client.auth.signOut();
                if (context.mounted) {
                  context.go('/login');
                }
              }
            },
          ),
          
          // TabBar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: RedesignTokens.primary,
              unselectedLabelColor: RedesignTokens.slate,
              indicatorColor: RedesignTokens.primary,
              labelStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Someday Soon'),
                      if (_upcomingExperiences.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: RedesignTokens.accentGold,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${_upcomingExperiences.length}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Yesterdays'),
                      if (_completedExperiences.isNotEmpty || _merryMoments.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: RedesignTokens.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${_completedExperiences.length + _merryMoments.length}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Body
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: RedesignTokens.primary),
                  )
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildUpcomingTab(),
                      _buildCompletedTab(),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddManualMomentSheet,
        icon: const Icon(Icons.edit),
        label: const Text('Journal'),
        backgroundColor: RedesignTokens.accentGold,
        foregroundColor: RedesignTokens.onPrimary,
      ),
    );
  }

  // UPCOMING TAB
  Widget _buildUpcomingTab() {
    if (_upcomingExperiences.isEmpty) {
      return _buildEmptyState(
        icon: Icons.event_available,
        title: 'No Upcoming Plans',
        subtitle:
            'When you accept an idea and plan it for later, it will appear here!',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAllMoments,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _upcomingExperiences.length,
        itemBuilder: (context, index) {
          final experience = _upcomingExperiences[index];
          return _buildUpcomingExperienceCard(experience);
        },
      ),
    );
  }

  // COMPLETED TAB
  Widget _buildCompletedTab() {
    // Combine completed experiences and merry moments, sorted by date
    final allCompleted = <dynamic>[
      ..._completedExperiences,
      ..._merryMoments,
    ]..sort((a, b) {
        final aDate = a is Experience
            ? (a.endAt ?? a.createdAt ?? DateTime.now())
            : (a as MerryMoment).occurredAt;
        final bDate = b is Experience
            ? (b.endAt ?? b.createdAt ?? DateTime.now())
            : (b as MerryMoment).occurredAt;
        return bDate.compareTo(aDate); // Newest first
      });

    if (allCompleted.isEmpty) {
      return _buildEmptyState(
        icon: Icons.photo_album_outlined,
        title: 'No Completed Moments Yet',
        subtitle:
            'Complete experiences or add manual entries to start building your family\'s memory album!',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAllMoments,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: allCompleted.length,
        itemBuilder: (context, index) {
          final item = allCompleted[index];
          if (item is Experience) {
            return _buildCompletedExperienceCard(item);
          } else {
            return _buildMerryMomentCard(item as MerryMoment);
          }
        },
      ),
    );
  }

  // EMPTY STATE
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: RedesignTokens.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: RedesignTokens.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: RedesignTokens.ink,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 15,
                color: RedesignTokens.slate,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // UPCOMING EXPERIENCE CARD
  Widget _buildUpcomingExperienceCard(Experience experience) {
    final participants = widget.allMembers
        .where((m) => experience.participantIds.contains(m.id))
        .toList();
    final timeUntil = _getTimeUntilText(experience.startAt);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      child: InkWell(
        onTap: () => _markExperienceComplete(experience),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                RedesignTokens.accentGold.withOpacity(0.05),
                Colors.white,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: RedesignTokens.accentGold.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.schedule,
                      color: RedesignTokens.accentGold,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          experience.activityName ?? 'Unnamed Activity',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: RedesignTokens.ink,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          timeUntil,
                          style: const TextStyle(
                            fontSize: 12,
                            color: RedesignTokens.accentGold,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Date & Time
              if (experience.startAt != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 14, color: RedesignTokens.slate),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('EEEE, MMM d · h:mm a').format(experience.startAt!),
                      style: const TextStyle(
                        fontSize: 13,
                        color: RedesignTokens.slate,
                      ),
                    ),
                  ],
                ),
              ],

              // Place
              if (experience.place != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.place_outlined,
                        size: 14, color: RedesignTokens.slate),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        experience.place!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: RedesignTokens.slate,
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              // Prep Notes
              if (experience.prepNotes != null && experience.prepNotes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: RedesignTokens.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.lightbulb_outline,
                          size: 16, color: RedesignTokens.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          experience.prepNotes!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: RedesignTokens.ink,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Participants
              if (participants.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: participants.map((member) => _buildParticipantChip(member)).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // COMPLETED EXPERIENCE CARD
  Widget _buildCompletedExperienceCard(Experience experience) {
    final participants = widget.allMembers
        .where((m) => experience.participantIds.contains(m.id))
        .toList();
    final completedDate = experience.endAt ?? experience.updatedAt ?? experience.createdAt;
    final daysSince = completedDate != null ? _getDaysSinceText(completedDate) : '';
    final dateStr = completedDate != null
        ? DateFormat('MMM d, y').format(completedDate)
        : '';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      child: InkWell(
        onTap: () => _showCompletedExperienceDetail(experience),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: RedesignTokens.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: RedesignTokens.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          experience.activityName ?? 'Unnamed Activity',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: RedesignTokens.ink,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$daysSince · $dateStr',
                          style: const TextStyle(
                            fontSize: 12,
                            color: RedesignTokens.slate,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Place
              if (experience.place != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.place_outlined,
                        size: 14, color: RedesignTokens.slate),
                    const SizedBox(width: 4),
                    Text(
                      experience.place!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: RedesignTokens.slate,
                      ),
                    ),
                  ],
                ),
              ],

              // Participants
              if (participants.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: participants.map((member) => _buildParticipantChip(member)).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // MERRY MOMENT CARD
  Widget _buildMerryMomentCard(MerryMoment moment) {
    final participants = widget.allMembers
        .where((m) => moment.participantIds.contains(m.id))
        .toList();
    final daysSince = _getDaysSinceText(moment.occurredAt);
    final dateStr = DateFormat('MMM d, y').format(moment.occurredAt);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      child: InkWell(
        onTap: () => _showMomentDetail(moment),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (moment.isManual
                              ? RedesignTokens.accentSage
                              : RedesignTokens.accentGold)
                          .withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      moment.isManual ? Icons.edit : Icons.celebration,
                      color: moment.isManual
                          ? RedesignTokens.accentSage
                          : RedesignTokens.accentGold,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          moment.title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: RedesignTokens.ink,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$daysSince · $dateStr',
                          style: const TextStyle(
                            fontSize: 12,
                            color: RedesignTokens.slate,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Description
              if (moment.description != null && moment.description!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  moment.description!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: RedesignTokens.ink,
                  ),
                ),
              ],

              // Place
              if (moment.place != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.place_outlined,
                        size: 14, color: RedesignTokens.slate),
                    const SizedBox(width: 4),
                    Text(
                      moment.place!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: RedesignTokens.slate,
                      ),
                    ),
                  ],
                ),
              ],

              // Participants
              if (participants.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: participants.map((member) => _buildParticipantChip(member)).toList(),
                ),
              ],

              // Media count
              if (moment.mediaIds.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: RedesignTokens.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.photo_library,
                          size: 14, color: RedesignTokens.primary),
                      const SizedBox(width: 4),
                      Text(
                        '${moment.mediaIds.length} ${moment.mediaIds.length == 1 ? 'photo' : 'photos'}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: RedesignTokens.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // HELPER FUNCTIONS
  
  /// Build a modern participant chip matching the SimplifiedSuggestionCard style
  Widget _buildParticipantChip(FamilyMember member) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: RedesignTokens.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border: member.photoUrl != null
                  ? Border.all(color: Colors.white, width: 2)
                  : null,
            ),
            child: member.photoUrl != null
                ? ClipOval(
                    child: Image.network(
                      member.photoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child: Text(
                          member.avatarEmoji ?? member.name.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      member.avatarEmoji ?? member.name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 6),
          // Name
          Text(
            member.name,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
  
  String _getTimeUntilText(DateTime? startAt) {
    if (startAt == null) return 'Planned';

    final now = DateTime.now();
    final difference = startAt.difference(now);

    if (difference.isNegative) {
      return 'Past due';
    } else if (difference.inMinutes < 60) {
      return 'In ${difference.inMinutes} minutes';
    } else if (difference.inHours < 24) {
      return 'In ${difference.inHours} hours';
    } else if (difference.inDays == 1) {
      return 'Tomorrow';
    } else if (difference.inDays < 7) {
      return 'In ${difference.inDays} days';
    } else {
      return DateFormat('MMM d').format(startAt);
    }
  }

  String _getDaysSinceText(DateTime occurredAt) {
    final now = DateTime.now();
    final difference = now.difference(occurredAt);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    }
  }

  // DETAIL SHEETS
  Widget _buildCompletedDetailSheet(Experience experience) {
    final participants = widget.allMembers
        .where((m) => experience.participantIds.contains(m.id))
        .toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        experience.activityName ?? 'Unnamed Activity',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: RedesignTokens.ink,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Completed badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: RedesignTokens.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle, 
                                size: 16, color: RedesignTokens.primary),
                            const SizedBox(width: 6),
                            Text(
                              'Completed ${_getDaysSinceText(experience.endAt ?? experience.updatedAt ?? DateTime.now())}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: RedesignTokens.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Place
                      if (experience.place != null) ...[
                        _buildDetailRow(Icons.place_outlined, 'Location', experience.place!),
                        const SizedBox(height: 16),
                      ],
                      
                      // Date
                      if (experience.endAt != null) ...[
                        _buildDetailRow(
                          Icons.calendar_today,
                          'Completed on',
                          DateFormat('EEEE, MMMM d, y').format(experience.endAt!),
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      // Participants
                      if (participants.isNotEmpty) ...[
                        const Text(
                          'Participants',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: RedesignTokens.slate,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: participants.map((member) => _buildParticipantChip(member)).toList(),
                        ),
                        const SizedBox(height: 24),
                      ],
                      
                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                _showPhotoSourceDialog(experience);
                              },
                              icon: const Icon(Icons.add_a_photo),
                              label: const Text('Add Photo'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: RedesignTokens.accentSage,
                                side: const BorderSide(color: RedesignTokens.accentSage),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: RedesignTokens.primary,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Close'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMomentDetailSheet(MerryMoment moment) {
    final participants = widget.allMembers
        .where((m) => moment.participantIds.contains(m.id))
        .toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        moment.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: RedesignTokens.ink,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Type badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: (moment.isManual
                                  ? RedesignTokens.accentSage
                                  : RedesignTokens.accentGold)
                              .withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              moment.isManual ? Icons.edit : Icons.celebration,
                              size: 16,
                              color: moment.isManual
                                  ? RedesignTokens.accentSage
                                  : RedesignTokens.accentGold,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              moment.isManual ? 'Manual Entry' : 'Merry Moment',
                              style: TextStyle(
                                fontSize: 13,
                                color: moment.isManual
                                    ? RedesignTokens.accentSage
                                    : RedesignTokens.accentGold,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Description
                      if (moment.description != null && moment.description!.isNotEmpty) ...[
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: RedesignTokens.slate,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          moment.description!,
                          style: const TextStyle(
                            fontSize: 15,
                            color: RedesignTokens.ink,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      
                      // Place
                      if (moment.place != null) ...[
                        _buildDetailRow(Icons.place_outlined, 'Location', moment.place!),
                        const SizedBox(height: 16),
                      ],
                      
                      // Date
                      _buildDetailRow(
                        Icons.calendar_today,
                        'Date',
                        DateFormat('EEEE, MMMM d, y').format(moment.occurredAt),
                      ),
                      const SizedBox(height: 16),
                      
                      // Participants
                      if (participants.isNotEmpty) ...[
                        const Text(
                          'Participants',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: RedesignTokens.slate,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: participants.map((member) => _buildParticipantChip(member)).toList(),
                        ),
                        const SizedBox(height: 24),
                      ],
                      
                      // Media count
                      if (moment.mediaIds.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: RedesignTokens.primary.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.photo_library,
                                  color: RedesignTokens.primary),
                              const SizedBox(width: 12),
                              Text(
                                '${moment.mediaIds.length} ${moment.mediaIds.length == 1 ? 'photo' : 'photos'} attached',
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: RedesignTokens.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      
                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                _showPhotoSourceDialog(moment);
                              },
                              icon: const Icon(Icons.add_a_photo),
                              label: const Text('Add Photo'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: RedesignTokens.accentSage,
                                side: const BorderSide(color: RedesignTokens.accentSage),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: RedesignTokens.primary,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Close'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: RedesignTokens.slate),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: RedesignTokens.slate,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  color: RedesignTokens.ink,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

