import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import '../../../modules/core/theme/merryway_theme.dart';
import '../../../modules/core/theme/redesign_tokens.dart';
import '../../../modules/family/models/family_models.dart';
import '../../../modules/core/ui/widgets/animated_list_item.dart';
import '../../../modules/core/ui/widgets/whimsical_card.dart';
import '../../../modules/home/widgets/compact_header.dart';
import '../../../modules/auth/services/user_context_service.dart';
import '../../../modules/auth/widgets/user_switcher.dart';
import '../../../modules/family/pages/family_health_dashboard_page.dart';
import '../models/experience_models.dart';
import '../repositories/experience_repository.dart';
import '../widgets/experience_debrief_modal.dart';
import '../widgets/web_video_player.dart';

class MomentsV2Page extends StatefulWidget {
  final String householdId;
  final List<FamilyMember> allMembers;

  const MomentsV2Page({
    Key? key,
    required this.householdId,
    required this.allMembers,
  }) : super(key: key);

  @override
  State<MomentsV2Page> createState() => _MomentsV2PageState();
}

class _MomentsV2PageState extends State<MomentsV2Page> {
  final ExperienceRepository _repository = ExperienceRepository();
  final ImagePicker _picker = ImagePicker();
  final ScrollController _scrollController = ScrollController();

  List<_UpcomingItem> _upcomingItems = [];
  List<_CompletedItem> _completedItems = [];
  bool _isLoading = true;
  Set<String> _dismissedPhotoPrompts = {};
  
  // User context state
  bool _familyModeEnabled = false;
  String? _currentMemberId;

  @override
  void initState() {
    super.initState();
    _loadUserContext();
    _loadMoments();
  }
  
  Future<void> _loadUserContext() async {
    // Check if family mode is enabled
    final supabase = Supabase.instance.client;
    try {
      final householdData = await supabase
          .from('households')
          .select('family_mode_enabled')
          .eq('id', widget.householdId)
          .maybeSingle();
      
      final isFamilyModeEnabled = householdData?['family_mode_enabled'] ?? false;
      
      // Get current member ID
      final memberId = await UserContextService.getCurrentMemberId(
        allMembers: widget.allMembers,
        familyModeEnabled: isFamilyModeEnabled,
      );
      
      setState(() {
        _familyModeEnabled = isFamilyModeEnabled;
        _currentMemberId = memberId;
      });
    } catch (e) {
      print('Error loading user context: $e');
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMoments() async {
    setState(() => _isLoading = true);

    try {
      // TODO: Replace with actual API calls to new endpoints
      // For now, use existing data structure
      
      // Load upcoming (planned) experiences
      final upcomingExperiences = await _repository.listExperiences(
        widget.householdId,
        status: 'planned',
      );

      _upcomingItems = upcomingExperiences.map((exp) {
        final now = DateTime.now();
        final minutesToStart = exp.startAt != null
            ? exp.startAt!.difference(now).inMinutes
            : 999;
        
        return _UpcomingItem(
          id: exp.id!,
          title: exp.activityName ?? 'Unnamed',
          startAt: exp.startAt ?? DateTime.now(),
          iconEmoji: _getActivityIcon(exp.activityName),
          participants: widget.allMembers
              .where((m) => exp.participantIds.contains(m.id))
              .toList(),
          minutesToStart: minutesToStart,
          experience: exp,
        );
      }).toList();

      // Load completed experiences and moments
      final completedExperiences = await _repository.listExperiences(
        widget.householdId,
        status: 'done',
      );

      final supabase = Supabase.instance.client;
      final momentsResponse = await supabase
          .from('merry_moments')
          .select()
          .eq('household_id', widget.householdId)
          .order('occurred_at', ascending: false);

      final moments = (momentsResponse as List)
          .map((json) => MerryMoment.fromJson(json))
          .toList();

      // Combine and convert to _CompletedItem
      List<_CompletedItem> completed = [];

      for (var exp in completedExperiences) {
        // Get all media items
        final mediaResponse = await supabase
            .from('media_items')
            .select('id, file_url')
            .eq('experience_id', exp.id!)
            .order('created_at', ascending: false);
        
        final mediaList = mediaResponse as List;
        final List<String> mediaUrls = mediaList
            .map((item) => item['file_url'] as String)
            .toList();

        // Get review if exists
        String? reviewNote;
        try {
          final reviewResponse = await supabase
              .from('experience_reviews')
              .select('note')
              .eq('experience_id', exp.id!)
              .maybeSingle();
          
          if (reviewResponse != null) {
            reviewNote = reviewResponse['note'] as String?;
          }
        } catch (e) {
          print('Error loading review: $e');
        }

        completed.add(_CompletedItem(
          id: exp.id!,
          title: exp.activityName ?? 'Unnamed',
          date: exp.endAt ?? exp.createdAt ?? DateTime.now(),
          participants: widget.allMembers
              .where((m) => exp.participantIds.contains(m.id))
              .toList(),
          mediaUrls: mediaUrls,
          mediaCount: mediaList.length,
          type: 'experience',
          canAddMedia: true,
          canJournal: true,
          experience: exp,
          summary: reviewNote,
        ));
      }

      for (var moment in moments) {
        // Get all media items for moments
        final mediaResponse = await supabase
            .from('media_items')
            .select('id, file_url')
            .eq('merry_moment_id', moment.id!)
            .order('created_at', ascending: false);
        
        final mediaList = mediaResponse as List;
        final List<String> mediaUrls = mediaList
            .map((item) => item['file_url'] as String)
            .toList();

        completed.add(_CompletedItem(
          id: moment.id!,
          title: moment.title,
          date: moment.occurredAt,
          participants: widget.allMembers
              .where((m) => moment.participantIds.contains(m.id))
              .toList(),
          mediaUrls: mediaUrls,
          mediaCount: mediaList.length,
          type: 'moment',
          canAddMedia: true,
          canJournal: false,
          moment: moment,
          summary: moment.description,
        ));
      }

      // Sort by date descending
      completed.sort((a, b) => b.date.compareTo(a.date));

      setState(() {
        _completedItems = completed;
      });
    } catch (e) {
      debugPrint('Error loading moments: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading moments: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _getActivityIcon(String? activityName) {
    if (activityName == null) return '✨';
    final name = activityName.toLowerCase();
    
    if (name.contains('park') || name.contains('outdoor')) return '🌳';
    if (name.contains('museum') || name.contains('art')) return '🎨';
    if (name.contains('sport') || name.contains('play')) return '⚽';
    if (name.contains('food') || name.contains('pizza') || name.contains('eat')) return '🍕';
    if (name.contains('movie') || name.contains('film')) return '🎬';
    if (name.contains('game')) return '🎮';
    if (name.contains('read') || name.contains('book')) return '📚';
    if (name.contains('music')) return '🎵';
    if (name.contains('craft')) return '✂️';
    if (name.contains('zoo') || name.contains('animal')) return '🦁';
    if (name.contains('beach')) return '🏖️';
    
    return '✨';
  }

  Future<void> _handleAddPhoto(_CompletedItem item) async {
    final mediaType = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Add Media',
          style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera, color: RedesignTokens.primary),
              title: const Text('Take Photo'),
              onTap: () => Navigator.pop(context, 'camera_photo'),
            ),
            ListTile(
              leading: const Icon(Icons.videocam, color: RedesignTokens.primary),
              title: const Text('Record Video'),
              onTap: () => Navigator.pop(context, 'camera_video'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: RedesignTokens.primary),
              title: const Text('Upload Photo/Video(s)'),
              onTap: () => Navigator.pop(context, 'gallery_media'),
            ),
          ],
        ),
      ),
    );

    if (mediaType != null) {
      await _uploadMedia(mediaType, item);
    }
  }

  Future<void> _uploadMedia(String mediaType, _CompletedItem item) async {
    try {
      final XFile? media;
      bool isVideo = false;
      
      // Pick media based on type
      switch (mediaType) {
        case 'camera_photo':
          media = await _picker.pickImage(
            source: ImageSource.camera,
            maxWidth: 1920,
            maxHeight: 1920,
            imageQuality: 85,
          );
          break;
        case 'camera_video':
          media = await _picker.pickVideo(
            source: ImageSource.camera,
            maxDuration: const Duration(minutes: 3), // 3 min max
          );
          isVideo = true;
          break;
        case 'gallery_media':
          // Let the picker handle both photos and videos
          media = await _picker.pickMedia();
          // Detect if it's a video by file extension
          if (media != null) {
            isVideo = _isVideoUrl(media.path);
          }
          break;
        default:
          return;
      }

      if (media == null) return;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Text(isVideo ? 'Uploading video...' : 'Uploading photo...'),
              ],
            ),
            duration: const Duration(seconds: 30),
          ),
        );
      }

      final bytes = await media.readAsBytes();
      final extension = isVideo ? '.mp4' : '.jpg';
      final fileName = '${item.type}_${item.id}_${DateTime.now().millisecondsSinceEpoch}$extension';

      await _repository.uploadMediaBytes(
        householdId: widget.householdId,
        fileBytes: bytes,
        fileName: fileName,
        experienceId: item.type == 'experience' ? item.id : null,
        merryMomentId: item.type == 'moment' ? item.id : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text('${isVideo ? 'Video' : 'Photo'} added! ✨'),
              ],
            ),
            backgroundColor: RedesignTokens.primary,
            duration: const Duration(seconds: 2),
          ),
        );

        // Show confetti effect for first media
        if (item.mediaCount == 0) {
          _showConfetti();
        }

        // Reload data
        await _loadMoments();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showConfetti() {
    // Simple confetti celebration
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Center(
        child: TweenAnimationBuilder(
          duration: const Duration(milliseconds: 800),
          tween: Tween<double>(begin: 0.0, end: 1.0),
          builder: (context, double value, child) {
            return Opacity(
              opacity: 1.0 - value,
              child: Transform.scale(
                scale: 1.0 + (value * 0.5),
                child: const Text(
                  '✨🎉✨',
                  style: TextStyle(fontSize: 80),
                ),
              ),
            );
          },
          onEnd: () => Navigator.of(context).pop(),
        ),
      ),
    );
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
              context.push('/plans', extra: {
                'householdId': widget.householdId,
              });
            },
            onTime: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FamilyHealthDashboardPage(
                    householdId: widget.householdId,
                  ),
                ),
              );
            },
            onMoments: () {
              // Already on moments page, do nothing
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
            userSwitcher: _familyModeEnabled && widget.allMembers.isNotEmpty
                ? UserSwitcher(
                    members: widget.allMembers,
                    currentUser: UserContextService.getCurrentMember(
                      _currentMemberId,
                      widget.allMembers,
                    ),
                    onUserSelected: (member) async {
                      await UserContextService.setSelectedMember(member.id!);
                      setState(() {
                        _currentMemberId = member.id;
                      });
                      // Reload moments for new user context
                      _loadMoments();
                    },
                  )
                : null,
          ),
          
          // Body
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: RedesignTokens.primary),
                  )
                : RefreshIndicator(
              onRefresh: _loadMoments,
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  // Upcoming Carousel (Non-Sticky)
                  SliverToBoxAdapter(
                    child: _buildUpcomingSection(),
                  ),

                  // Completed Feed Section Header
                  if (_completedItems.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.auto_awesome,
                              size: 20,
                              color: RedesignTokens.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Yesterdays',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: RedesignTokens.ink,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  
                  // Completed Feed
                  if (_completedItems.isEmpty)
                    SliverFillRemaining(
                      child: _buildEmptyState(),
                    )
                  else
                    _buildCompletedFeed(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        isIdeasActive: false,
        isMomentsActive: true,
        isPlannerActive: false,
        isTimeActive: false,
        onIdeas: () => context.go('/'),
        onMoments: () {
          // Already on moments page
        },
        onPlanner: () {
          context.push('/plans', extra: {
            'householdId': widget.householdId,
          });
        },
        onTime: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FamilyHealthDashboardPage(
                householdId: widget.householdId,
              ),
            ),
          );
        },
      ),
    );
  }

  /// Build the upcoming section (non-sticky)
  Widget _buildUpcomingSection() {
    return Container(
      height: 180,
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header label
          Row(
            children: [
              const Icon(
                Icons.upcoming,
                size: 20,
                color: RedesignTokens.accentGold,
              ),
              const SizedBox(width: 8),
              Text(
                'Someday Soon',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: RedesignTokens.ink,
                ),
              ),
              const SizedBox(width: 4),
              if (_upcomingItems.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: RedesignTokens.accentGold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_upcomingItems.length}',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: RedesignTokens.accentGold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Carousel
          Expanded(
            child: _upcomingItems.isEmpty
                ? Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.event_available, color: RedesignTokens.slate.withOpacity(0.5), size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'No upcoming plans',
                          style: GoogleFonts.spaceGrotesk(
                            color: RedesignTokens.slate,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _upcomingItems.length + 1, // +1 for the "New" button
                    itemBuilder: (context, index) {
                      // Last item is the "New" button
                      if (index == _upcomingItems.length) {
                        return _buildNewExperienceButton();
                      }
                      
                      final item = _upcomingItems[index];
                      return AnimatedListItem(
                        index: index,
                        delay: const Duration(milliseconds: 50),
                        child: _buildUpcomingTile(item),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
  
  /// Build an upcoming tile
  Widget _buildUpcomingTile(_UpcomingItem item) {
    final now = DateTime.now();
    final withinHour = item.minutesToStart >= 0 && item.minutesToStart <= 60;
    
    return InkWell(
      onTap: () => _handleUpcomingTap(item),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: withinHour
              ? RedesignTokens.accentGold.withOpacity(0.1)
              : RedesignTokens.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: withinHour
                ? RedesignTokens.accentGold.withOpacity(0.3)
                : RedesignTokens.primary.withOpacity(0.1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              item.iconEmoji,
              style: const TextStyle(fontSize: 32),
              overflow: TextOverflow.visible,
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                item.title,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: RedesignTokens.ink,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getTimeUntilText(item.startAt),
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                color: withinHour ? RedesignTokens.accentGold : RedesignTokens.slate,
                fontWeight: withinHour ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build the "+New" experience button
  Widget _buildNewExperienceButton() {
    return InkWell(
      onTap: () {
        // Navigate to home page to make a new experience from an idea
        context.go('/');
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: RedesignTokens.accentGold.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: RedesignTokens.accentGold.withOpacity(0.3),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: RedesignTokens.accentGold.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add,
                size: 24,
                color: RedesignTokens.accentGold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'New',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: RedesignTokens.accentGold,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _getTimeUntilText(DateTime? startAt) {
    if (startAt == null) return 'Soon';
    
    final now = DateTime.now();
    final difference = startAt.difference(now);
    
    if (difference.isNegative) return 'Past';
    if (difference.inMinutes < 60) return 'In ${difference.inMinutes}m';
    if (difference.inHours < 24) return 'In ${difference.inHours}h';
    if (difference.inDays == 1) return 'Tomorrow';
    if (difference.inDays < 7) return 'In ${difference.inDays}d';
    return DateFormat('MMM d').format(startAt);
  }

  /// Build a modern participant chip matching the SimplifiedSuggestionCard style
  Widget _buildParticipantChip(FamilyMember member) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: RedesignTokens.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: RedesignTokens.primary.withOpacity(0.2),
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
              color: RedesignTokens.primary.withOpacity(0.15),
              shape: BoxShape.circle,
              border: member.photoUrl != null
                  ? Border.all(color: RedesignTokens.primary.withOpacity(0.3), width: 2)
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
                          style: TextStyle(
                            fontSize: 11,
                            color: RedesignTokens.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      member.avatarEmoji ?? member.name.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        color: RedesignTokens.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 8),
          // Name
          Text(
            member.name,
            style: TextStyle(
              fontSize: 13,
              color: RedesignTokens.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: RedesignTokens.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.photo_album_outlined,
                size: 64,
                color: RedesignTokens.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Moments Yet',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: RedesignTokens.ink,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Turn today\'s plans into beautiful memories',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                color: RedesignTokens.slate,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Plan Something'),
              style: ElevatedButton.styleFrom(
                backgroundColor: RedesignTokens.accentGold,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedFeed() {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        // Calculate if screen is wide enough for two-column layout
        final screenWidth = constraints.crossAxisExtent;
        final useGridLayout = screenWidth >= 1200;

        if (useGridLayout) {
          // Two-column grid layout (never more than 2 columns)
          return SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 24,
                crossAxisSpacing: 24,
                mainAxisExtent: 650, // Fixed height - minimizes white space
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = _completedItems[index];
                  return AnimatedListItem(
                    index: index,
                    delay: const Duration(milliseconds: 60),
                    child: WhimsicalCard(
                      child: _buildCompletedCard(item),
                    ),
                  );
                },
                childCount: _completedItems.length,
              ),
            ),
          );
        } else {
          // Single-column list layout
          return SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = _completedItems[index];
                  return AnimatedListItem(
                    index: index,
                    delay: const Duration(milliseconds: 60),
                    child: WhimsicalCard(
                      child: _buildCompletedCard(item),
                    ),
                  );
                },
                childCount: _completedItems.length,
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildCompletedCard(_CompletedItem item) {
    final showPhotoPrompt = item.mediaCount == 0 && 
                            item.canAddMedia && 
                            !_dismissedPhotoPrompts.contains(item.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover Image or "Add First Photo" Prompt
          _buildCoverSection(item, showPhotoPrompt),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Date
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: RedesignTokens.ink,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: RedesignTokens.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: RedesignTokens.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            DateFormat('MMM d').format(item.date),
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 13,
                              color: RedesignTokens.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Add Photo button (icon only)
                    if (item.canAddMedia)
                      IconButton(
                        icon: const Icon(Icons.add_a_photo, size: 20),
                        color: RedesignTokens.primary,
                        tooltip: 'Add Photo/Video',
                        onPressed: () => _handleAddPhoto(item),
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        padding: const EdgeInsets.all(4),
                      ),
                    // Journal button (icon only)
                    if (item.canJournal)
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        color: RedesignTokens.accentGold,
                        tooltip: 'Review',
                        onPressed: () => _handleJournal(item),
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        padding: const EdgeInsets.all(4),
                      ),
                    // More options menu
                    PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.more_vert,
                        color: RedesignTokens.slate,
                        size: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onSelected: (value) {
                        // TODO: Implement edit, delete, etc.
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('$value coming soon!')),
                        );
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 18),
                              SizedBox(width: 12),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, size: 18, color: Colors.red),
                              SizedBox(width: 12),
                              Text('Delete', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                // Summary/Review note
                if (item.summary != null && item.summary!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    item.summary!,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      color: RedesignTokens.slate,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                
                const SizedBox(height: 12),

                // Participants
                if (item.participants.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: item.participants.map((member) => _buildParticipantChip(member)).toList(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverSection(_CompletedItem item, bool showPhotoPrompt) {
    if (showPhotoPrompt) {
      // "Add First Photo" Prompt
      return Container(
        height: 450,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              RedesignTokens.primary.withOpacity(0.1),
              RedesignTokens.accentGold.withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add_a_photo,
                      size: 48,
                      color: RedesignTokens.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _handleAddPhoto(item),
                    icon: const Icon(Icons.add_a_photo, size: 18),
                    label: const Text('Add First Photo ✨'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: RedesignTokens.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'It takes 10 seconds—make this memory shine',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      color: RedesignTokens.slate,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else if (item.mediaUrls.isNotEmpty) {
      // Show photo carousel
      return _PhotoCarousel(
        photoUrls: item.mediaUrls,
        mediaCount: item.mediaCount,
      );
    } else {
      // Placeholder
      return Container(
        height: 450,
        decoration: BoxDecoration(
          color: RedesignTokens.primary.withOpacity(0.05),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: const Center(
          child: Icon(
            Icons.photo_album_outlined,
            size: 64,
            color: RedesignTokens.slate,
          ),
        ),
      );
    }
  }

  void _handleUpcomingTap(_UpcomingItem item) {
    // Open live card for planned experiences
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              child: _buildUpcomingDetail(item),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingDetail(_UpcomingItem item) {
    final exp = item.experience;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Drag handle
        Center(
          child: Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: RedesignTokens.slate.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        
        // Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: RedesignTokens.primary.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Text(
                item.iconEmoji,
                style: const TextStyle(fontSize: 32),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exp.activityName ?? 'Unnamed Activity',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: RedesignTokens.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: RedesignTokens.slate,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        exp.startAt != null
                            ? DateFormat('EEE, MMM d · h:mm a').format(exp.startAt!)
                            : 'No specific time',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          color: RedesignTokens.slate,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Participants
        if (item.participants.isNotEmpty) ...[
          Text(
            'Who\'s going',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: RedesignTokens.ink,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: item.participants.map((member) => _buildParticipantChip(member)).toList(),
          ),
          const SizedBox(height: 24),
        ],
        
        // Place
        if (exp.place != null) ...[
          Text(
            'Where',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: RedesignTokens.ink,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: RedesignTokens.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: RedesignTokens.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    exp.place!,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      color: RedesignTokens.ink,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
        
        // Actions
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  // Cancel/Delete
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Cancel this plan?'),
                      content: const Text('This will remove it from your upcoming list.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Keep it'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Cancel Plan'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  );
                  
                  if (confirm == true && mounted) {
                    try {
                      await _repository.updateExperience(
                        exp.id!,
                        {'status': 'cancelled'},
                      );
                      if (mounted) {
                        Navigator.pop(context);
                        _loadMoments();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Plan cancelled')),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    }
                  }
                },
                icon: const Icon(Icons.close, size: 18),
                label: const Text('Cancel'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: RedesignTokens.slate,
                  side: BorderSide(color: RedesignTokens.slate.withOpacity(0.3)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: () async {
                  // Mark as done - show debrief
                  Navigator.pop(context);
                  await _markExperienceAsCompleted(exp);
                },
                icon: const Icon(Icons.check_circle),
                label: const Text('Mark as Done'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: RedesignTokens.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _markExperienceAsCompleted(Experience exp) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExperienceDebriefModal(
        experience: exp,
        onComplete: () {
          Navigator.pop(context, true);
        },
      ),
    );

    if (result == true) {
      _loadMoments();
    }
  }

  void _handleJournal(_CompletedItem item) {
    if (item.experience != null) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => ExperienceDebriefModal(
          experience: item.experience!,
          onComplete: () {
            Navigator.pop(context);
            _loadMoments();
          },
        ),
      );
    }
  }
}

// Data Models
class _UpcomingItem {
  final String id;
  final String title;
  final DateTime startAt;
  final String iconEmoji;
  final List<FamilyMember> participants;
  final int minutesToStart;
  final Experience experience;

  _UpcomingItem({
    required this.id,
    required this.title,
    required this.startAt,
    required this.iconEmoji,
    required this.participants,
    required this.minutesToStart,
    required this.experience,
  });
}

class _CompletedItem {
  final String id;
  final String title;
  final DateTime date;
  final List<FamilyMember> participants;
  final List<String> mediaUrls; // Changed from single coverUrl to list
  final int mediaCount;
  final String type;
  final bool canAddMedia;
  final bool canJournal;
  final Experience? experience;
  final MerryMoment? moment;
  final String? summary; // Review note or moment description

  _CompletedItem({
    required this.id,
    required this.title,
    required this.date,
    required this.participants,
    this.mediaUrls = const [],
    required this.mediaCount,
    required this.type,
    required this.canAddMedia,
    required this.canJournal,
    this.experience,
    this.moment,
    this.summary,
  });
}

// Upcoming Carousel Delegate
class _UpcomingCarouselDelegate extends SliverPersistentHeaderDelegate {
  final List<_UpcomingItem> items;
  final Function(_UpcomingItem) onTap;

  _UpcomingCarouselDelegate({
    required this.items,
    required this.onTap,
  });

  @override
  double get minExtent => 165;

  @override
  double get maxExtent => 165;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header label
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                const Icon(
                  Icons.upcoming,
                  size: 20,
                  color: RedesignTokens.accentGold,
                ),
                const SizedBox(width: 8),
                Text(
                  'Someday Soon',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: RedesignTokens.ink,
                  ),
                ),
                const SizedBox(width: 4),
                if (items.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: RedesignTokens.accentGold.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${items.length}',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: RedesignTokens.accentGold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Carousel
          Expanded(
            child: items.isEmpty
                ? _buildEmptyUpcoming(context)
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    itemCount: items.length + 1, // +1 for "add" button
                    itemBuilder: (context, index) {
                      if (index == items.length) {
                        return _buildAddButton(context);
                      }
                      return AnimatedListItem(
                        index: index,
                        delay: const Duration(milliseconds: 50),
                        child: _buildUpcomingTile(context, items[index]),
                      );
                    },
                  ),
          ),
          Container(
            height: 1,
            color: RedesignTokens.primary.withOpacity(0.1),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyUpcoming(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.event_available, color: RedesignTokens.slate.withOpacity(0.5), size: 18),
                const SizedBox(width: 8),
                Text(
                  'No upcoming plans',
                  style: GoogleFonts.spaceGrotesk(
                    color: RedesignTokens.slate,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.add_circle_outline, size: 18),
              label: const Text('Plan Something'),
              style: OutlinedButton.styleFrom(
                foregroundColor: RedesignTokens.accentGold,
                side: const BorderSide(color: RedesignTokens.accentGold),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingTile(BuildContext context, _UpcomingItem item) {
    final now = DateTime.now();
    final withinHour = item.minutesToStart >= 0 && item.minutesToStart <= 60;
    final isToday = item.startAt.year == now.year && 
                    item.startAt.month == now.month && 
                    item.startAt.day == now.day;
    final isTomorrow = item.startAt.year == now.year && 
                       item.startAt.month == now.month && 
                       item.startAt.day == now.day + 1;
    
    // Determine time/date display
    String timeDisplay;
    String? dateDisplay;
    
    if (item.minutesToStart < 0) {
      // In the past or no specific time
      timeDisplay = 'Soon';
      dateDisplay = null;
    } else if (withinHour) {
      // Within the hour
      timeDisplay = '${item.minutesToStart}min';
      dateDisplay = null;
    } else if (isToday) {
      // Later today
      timeDisplay = DateFormat('h:mm a').format(item.startAt);
      dateDisplay = 'Today';
    } else if (isTomorrow) {
      // Tomorrow
      timeDisplay = DateFormat('h:mm a').format(item.startAt);
      dateDisplay = 'Tomorrow';
    } else {
      // Future date
      timeDisplay = DateFormat('h:mm a').format(item.startAt);
      dateDisplay = DateFormat('EEE, MMM d').format(item.startAt);
    }
    
    return GestureDetector(
      onTap: () => onTap(item),
      child: Container(
        width: 110,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Progress ring for items <60min
                if (withinHour && item.minutesToStart >= 0)
                  SizedBox(
                    width: 64,
                    height: 64,
                    child: CircularProgressIndicator(
                      value: 1.0 - (item.minutesToStart / 60),
                      strokeWidth: 3,
                      backgroundColor: RedesignTokens.accentGold.withOpacity(0.1),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        RedesignTokens.accentGold,
                      ),
                    ),
                  ),
                // Icon circle
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: RedesignTokens.primary.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      item.iconEmoji,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                // "Soon" badge
                if (item.minutesToStart < 0)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: RedesignTokens.accentGold,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: RedesignTokens.accentGold.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        'SOON',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              item.title,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: RedesignTokens.ink,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            // Date and time on same line
            Text.rich(
              TextSpan(
                children: [
                  if (dateDisplay != null) ...[
                    TextSpan(
                      text: '$dateDisplay ',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: RedesignTokens.accentGold,
                      ),
                    ),
                  ],
                  TextSpan(
                    text: timeDisplay,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 10,
                      color: withinHour ? RedesignTokens.accentGold : RedesignTokens.slate,
                      fontWeight: withinHour ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 100,
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: RedesignTokens.accentGold.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add,
                size: 32,
                color: RedesignTokens.accentGold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'New',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: RedesignTokens.accentGold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;
}

// Helper function to detect if a URL is a video
bool _isVideoUrl(String url) {
  final videoExtensions = ['.mp4', '.mov', '.avi', '.mkv', '.m4v', '.webm'];
  final lowerUrl = url.toLowerCase();
  return videoExtensions.any((ext) => lowerUrl.endsWith(ext));
}

// Video Player Widget for individual videos in carousel
class _VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const _VideoPlayerWidget({required this.videoUrl});

  @override
  State<_VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<_VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    try {
      debugPrint('🎬 Initializing video: ${widget.videoUrl}');
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
        ..setLooping(true)
        ..setVolume(0); // Muted by default
      
      await _controller.initialize();
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        debugPrint('✅ Video initialized successfully');
        _controller.play(); // Autoplay
      }
    } catch (e) {
      debugPrint('❌ Video error: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    if (!kIsWeb) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use WebVideoPlayer for web platform
    if (kIsWeb) {
      return WebVideoPlayer(videoUrl: widget.videoUrl);
    }

    // Mobile video player implementation
    if (_hasError) {
      return Container(
        height: 450,
        color: RedesignTokens.primary.withOpacity(0.1),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.videocam_off, size: 48, color: RedesignTokens.slate),
                const SizedBox(height: 12),
                const Text(
                  'Video not available',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: RedesignTokens.ink,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This video format may not be supported',
                  style: TextStyle(
                    fontSize: 13,
                    color: RedesignTokens.slate,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.videoUrl.split('/').last,
                    style: TextStyle(
                      fontSize: 11,
                      color: RedesignTokens.slate,
                      fontFamily: 'monospace',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return Container(
        height: 450,
        color: RedesignTokens.primary.withOpacity(0.1),
        child: const Center(
          child: CircularProgressIndicator(color: RedesignTokens.primary),
        ),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: 450,
          width: double.infinity,
          color: Colors.black,
          child: Center(
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),
          ),
        ),
        // Video indicator overlay
        Positioned(
          top: 12,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.play_circle_outline, size: 14, color: Colors.white),
                SizedBox(width: 4),
                Text(
                  'Video',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Auto-rotating Photo/Video Carousel Widget
class _PhotoCarousel extends StatefulWidget {
  final List<String> photoUrls;
  final int mediaCount;

  const _PhotoCarousel({
    required this.photoUrls,
    required this.mediaCount,
  });

  @override
  State<_PhotoCarousel> createState() => _PhotoCarouselState();
}

class _PhotoCarouselState extends State<_PhotoCarousel> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    // Start auto-rotate if multiple photos (every 4 seconds)
    if (widget.photoUrls.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
        if (!mounted) return;
        
        final nextPage = (_currentPage + 1) % widget.photoUrls.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Stack(
        children: [
          // Photo PageView
          SizedBox(
            height: 450,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: widget.photoUrls.length,
              itemBuilder: (context, index) {
                final mediaUrl = widget.photoUrls[index];
                final isVideo = _isVideoUrl(mediaUrl);
                
                if (isVideo) {
                  return _VideoPlayerWidget(videoUrl: mediaUrl);
                } else {
                  return Image.network(
                    mediaUrl,
                    height: 450,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 450,
                        color: RedesignTokens.primary.withOpacity(0.1),
                        child: const Center(
                          child: Icon(Icons.image_not_supported, size: 48),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
          
          // Page indicators (if multiple photos)
          if (widget.photoUrls.length > 1)
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      widget.photoUrls.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: index == _currentPage ? 20 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: index == _currentPage
                              ? Colors.white
                              : Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          
          // Photo count badge
          if (widget.mediaCount > 1)
            Positioned(
              bottom: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.photo_library, size: 14, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.mediaCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

