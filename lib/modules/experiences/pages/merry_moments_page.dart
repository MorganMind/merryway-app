import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../../modules/core/theme/theme_colors.dart';
import '../../../modules/family/models/family_models.dart';
import '../models/experience_models.dart';
import '../widgets/add_manual_moment_sheet.dart';

class MerryMomentsPage extends StatefulWidget {
  final String householdId;
  final List<FamilyMember> allMembers;

  const MerryMomentsPage({
    Key? key,
    required this.householdId,
    required this.allMembers,
  }) : super(key: key);

  @override
  State<MerryMomentsPage> createState() => _MerryMomentsPageState();
}

class _MerryMomentsPageState extends State<MerryMomentsPage> {
  List<MerryMoment> _moments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMoments();
  }

  Future<void> _loadMoments() async {
    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('merry_moments')
          .select()
          .eq('household_id', widget.householdId)
          .order('occurred_at', ascending: false);

      setState(() {
        _moments = (response as List)
            .map((json) => MerryMoment.fromJson(json))
            .toList();
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
      _loadMoments();
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

  List<FamilyMember> _getParticipants(MerryMoment moment) {
    return widget.allMembers
        .where((m) => moment.participantIds.contains(m.id))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Merry Moments',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: MerryWayTheme.textDark,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showAddManualMomentSheet,
            icon: const Icon(Icons.add_circle, color: MerryWayTheme.primarySoftBlue),
            tooltip: 'Add Manual Moment',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _moments.isEmpty
              ? _buildEmptyState()
              : _buildMomentsList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddManualMomentSheet,
        icon: const Icon(Icons.edit),
        label: const Text('Journal'),
        backgroundColor: MerryWayTheme.accentGolden,
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
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: MerryWayTheme.primarySoftBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.photo_album_outlined,
                size: 64,
                color: MerryWayTheme.primarySoftBlue,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Merry Moments yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: MerryWayTheme.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Complete experiences or add manual entries to start building your family\'s memory album!',
              style: TextStyle(
                fontSize: 15,
                color: MerryWayTheme.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showAddManualMomentSheet,
              icon: const Icon(Icons.add),
              label: const Text('Add Your First Moment'),
              style: ElevatedButton.styleFrom(
                backgroundColor: MerryWayTheme.primarySoftBlue,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMomentsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _moments.length,
      itemBuilder: (context, index) {
        final moment = _moments[index];
        final participants = _getParticipants(moment);
        final daysSince = _getDaysSinceText(moment.occurredAt);
        final dateStr = DateFormat('MMM d, y').format(moment.occurredAt);

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          child: InkWell(
            onTap: () {
              // TODO: Open detail view
            },
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
                                  ? MerryWayTheme.accentSoftPink
                                  : MerryWayTheme.accentGolden)
                              .withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          moment.isManual ? Icons.edit : Icons.celebration,
                          color: moment.isManual
                              ? MerryWayTheme.accentSoftPink
                              : MerryWayTheme.accentGolden,
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
                                color: MerryWayTheme.textDark,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$daysSince · $dateStr',
                              style: const TextStyle(
                                fontSize: 12,
                                color: MerryWayTheme.textMuted,
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
                        color: MerryWayTheme.textDark,
                      ),
                    ),
                  ],

                  // Place
                  if (moment.place != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.place_outlined,
                            size: 14, color: MerryWayTheme.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          moment.place!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: MerryWayTheme.textMuted,
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
                      runSpacing: 4,
                      children: participants.map((member) {
                        return Chip(
                          avatar: Text(
                            member.avatarEmoji ?? member.name.substring(0, 1),
                            style: const TextStyle(fontSize: 12),
                          ),
                          label: Text(
                            member.name,
                            style: const TextStyle(fontSize: 11),
                          ),
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          backgroundColor: MerryWayTheme.primarySoftBlue.withOpacity(0.1),
                        );
                      }).toList(),
                    ),
                  ],

                  // Media count
                  if (moment.mediaIds.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: MerryWayTheme.primarySoftBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.photo_library,
                              size: 14, color: MerryWayTheme.primarySoftBlue),
                          const SizedBox(width: 4),
                          Text(
                            '${moment.mediaIds.length} ${moment.mediaIds.length == 1 ? 'photo' : 'photos'}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: MerryWayTheme.primarySoftBlue,
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
      },
    );
  }
}

