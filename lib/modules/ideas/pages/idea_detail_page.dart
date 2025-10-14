import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/theme_colors.dart';
import '../../family/models/family_models.dart';
import '../../family/models/pod_model.dart';
import '../models/idea_models.dart';
import '../services/ideas_api_service.dart';
import '../widgets/idea_composer.dart';

// Access MerryWayTheme constants
class MerryWayTheme {
  static const Color primarySoftBlue = Color(0xFF91C8E4);
  static const Color accentLavender = Color(0xFFB4A7D6);
  static const Color accentGolden = Color(0xFFFFD700);
  static const Color accentSoftPink = Color(0xFFFFB6C1);
  static const Color textDark = Color(0xFF2D3436);
  static const Color textMuted = Color(0xFF636E72);
  static const Color softBg = Color(0xFFF5F5F5);
}

class IdeaDetailPage extends StatefulWidget {
  final String ideaId;
  final String householdId;
  final String currentMemberId;
  final bool isParent;
  final List<FamilyMember> allMembers;
  final List<Pod> allPods;

  const IdeaDetailPage({
    Key? key,
    required this.ideaId,
    required this.householdId,
    required this.currentMemberId,
    required this.isParent,
    required this.allMembers,
    required this.allPods,
  }) : super(key: key);

  @override
  State<IdeaDetailPage> createState() => _IdeaDetailPageState();
}

class _IdeaDetailPageState extends State<IdeaDetailPage> {
  final _apiService = IdeasApiService();
  final _commentController = TextEditingController();

  Idea? _idea;
  List<IdeaComment> _comments = [];
  bool _isLoading = true;
  bool _isSubmittingComment = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadIdea();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadIdea() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final idea = await _apiService.getIdea(widget.ideaId);
      setState(() {
        _idea = idea;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadComments() async {
    try {
      final comments = await _apiService.getComments(widget.ideaId);
      setState(() {
        _comments = comments.where((c) => !c.isDeleted).toList();
      });
    } catch (e) {
      print('Error loading comments: $e');
    }
  }

  Future<void> _toggleLike() async {
    if (_idea == null) return;

    final wasLiked = _idea!.isLikedByMe;

    // Optimistic update
    setState(() {
      _idea = _idea!.copyWith(
        isLikedByMe: !wasLiked,
      );
    });

    try {
      if (wasLiked) {
        await _apiService.unlikeIdea(widget.ideaId, widget.currentMemberId);
      } else {
        await _apiService.likeIdea(widget.ideaId, widget.currentMemberId);
      }
      await _loadIdea(); // Refresh to get updated count
    } catch (e) {
      // Revert on error
      setState(() {
        _idea = _idea!.copyWith(
          isLikedByMe: wasLiked,
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _postComment() async {
    if (_commentController.text.trim().isEmpty) return;

    setState(() => _isSubmittingComment = true);

    try {
      final comment = IdeaComment(
        ideaId: widget.ideaId,
        memberId: widget.currentMemberId,
        body: _commentController.text.trim(),
      );

      await _apiService.postComment(comment);
      _commentController.clear();
      await _loadComments();
      await _loadIdea(); // Refresh to get updated count
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error posting comment: $e')),
      );
    } finally {
      setState(() => _isSubmittingComment = false);
    }
  }

  Future<void> _approveIdea() async {
    if (_idea == null) return;

    try {
      await _apiService.approveIdea(widget.ideaId, widget.currentMemberId);
      await _loadIdea();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Idea approved!'),
          backgroundColor: MerryWayTheme.primarySoftBlue,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error approving: $e')),
      );
    }
  }

  Future<void> _archiveIdea() async {
    if (_idea == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archive Idea?'),
        content:
            const Text('This idea will no longer appear in the feed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Archive'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _apiService.updateIdea(widget.ideaId, {
          'state': IdeaState.archived.toDbString(),
        });
        Navigator.pop(context); // Go back
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Idea archived')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error archiving: $e')),
        );
      }
    }
  }

  Future<void> _editIdea() async {
    if (_idea == null) return;

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => IdeaComposer(
          householdId: widget.householdId,
          currentMemberId: widget.currentMemberId,
          allMembers: widget.allMembers,
          allPods: widget.allPods,
          existingIdea: _idea,
        ),
      ),
    );

    if (result == true) {
      await _loadIdea();
    }
  }

  Future<void> _makeExperience() async {
    // TODO: Implement promote to experience flow
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Promote to Experience - Coming soon!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _idea == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(_error ?? 'Idea not found'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    final idea = _idea!;
    final creator = widget.allMembers.firstWhere(
      (m) => m.id == idea.creatorMemberId,
      orElse: () => FamilyMember(
        id: idea.creatorMemberId,
        name: 'Unknown',
        age: 0,
        role: MemberRole.parent,
      ),
    );
    final canEdit = widget.isParent || idea.creatorMemberId == widget.currentMemberId;

    return Scaffold(
      backgroundColor: MerryWayTheme.softBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Edit button
          if (canEdit)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: _editIdea,
            ),
          // More menu
          if (canEdit)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'archive') {
                  _archiveIdea();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'archive',
                  child: Row(
                    children: [
                      Icon(Icons.archive_outlined, size: 20),
                      SizedBox(width: 12),
                      Text('Archive'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadIdea();
          await _loadComments();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Pending approval banner
            if (idea.state == IdeaState.pendingApproval) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: MerryWayTheme.accentGolden.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: MerryWayTheme.accentGolden,
                    width: 2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.hourglass_empty, color: MerryWayTheme.accentGolden),
                        SizedBox(width: 8),
                        Text(
                          'Awaiting Parent Approval',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This idea needs to be approved by a parent before others can see it.',
                      style: TextStyle(fontSize: 14),
                    ),
                    if (widget.isParent) ...[
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _approveIdea,
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Approve This Idea'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MerryWayTheme.accentGolden,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Title
            Text(
              idea.title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: MerryWayTheme.textDark,
              ),
            ),
            const SizedBox(height: 12),

            // Creator & visibility chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Creator chip
                Chip(
                  avatar: Text(
                    creator.avatarEmoji ?? creator.name.substring(0, 1),
                    style: const TextStyle(fontSize: 12),
                  ),
                  label: Text(creator.name),
                  visualDensity: VisualDensity.compact,
                  backgroundColor: MerryWayTheme.primarySoftBlue.withOpacity(0.1),
                ),
                // Visibility chip
                Chip(
                  label: Text(idea.visibility.displayName),
                  visualDensity: VisualDensity.compact,
                  backgroundColor: MerryWayTheme.accentLavender.withOpacity(0.1),
                ),
                // State chip
                Chip(
                  label: Text(idea.state.displayName),
                  visualDensity: VisualDensity.compact,
                  backgroundColor: _getStateColor(idea.state).withOpacity(0.1),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Badges (duration, cost, indoor/outdoor, min age, needs adult)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (idea.durationMinutes != null)
                  _buildBadge(Icons.access_time, '${idea.durationMinutes}min'),
                if (idea.costBand != null)
                  _buildBadge(Icons.attach_money, _formatCost(idea.costBand!)),
                if (idea.indoorOutdoor != null)
                  _buildBadge(
                    idea.indoorOutdoor == 'indoor'
                        ? Icons.home
                        : Icons.wb_sunny,
                    idea.indoorOutdoor!,
                  ),
                if (idea.minAge != null)
                  _buildBadge(Icons.child_care, 'Age ${idea.minAge}+'),
                if (idea.needsAdult)
                  _buildBadge(Icons.supervisor_account, 'Adult needed'),
                if (idea.messLevel != null)
                  _buildBadge(Icons.cleaning_services, 'Mess: ${idea.messLevel}'),
                if (idea.setupMinutes != null)
                  _buildBadge(Icons.construction, 'Setup: ${idea.setupMinutes}min'),
              ],
            ),
            const SizedBox(height: 16),

            // Summary
            if (idea.summary != null && idea.summary!.isNotEmpty) ...[
              Text(
                idea.summary!,
                style: const TextStyle(
                  fontSize: 16,
                  color: MerryWayTheme.textDark,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Details (markdown)
            if (idea.detailsMd != null && idea.detailsMd!.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  idea.detailsMd!,
                  style: const TextStyle(
                    fontSize: 15,
                    color: MerryWayTheme.textDark,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Location
            if (idea.locationHint != null && idea.locationHint!.isNotEmpty) ...[
              _buildInfoRow(Icons.place_outlined, idea.locationHint!),
              const SizedBox(height: 12),
            ],

            // Default pod
            if (idea.defaultPodId != null) ...[
              _buildInfoRow(
                Icons.group_outlined,
                'Designed for ${_getPodName(idea.defaultPodId!)}',
              ),
              const SizedBox(height: 12),
            ],

            // Tags
            if (idea.tags.isNotEmpty) ...[
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: idea.tags.map((tag) {
                  return Chip(
                    label: Text('#$tag'),
                    visualDensity: VisualDensity.compact,
                    backgroundColor: MerryWayTheme.softBg,
                    labelStyle: const TextStyle(fontSize: 12),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Actions
            Row(
              children: [
                // Like button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _toggleLike,
                    icon: Icon(
                      idea.isLikedByMe ? Icons.favorite : Icons.favorite_border,
                      color: idea.isLikedByMe
                          ? MerryWayTheme.accentSoftPink
                          : MerryWayTheme.textMuted,
                    ),
                    label: Text('${idea.likesCount}'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: MerryWayTheme.textDark,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Make it an Experience button
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _makeExperience,
                    icon: const Icon(Icons.celebration),
                    label: const Text('Make it an Experience'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MerryWayTheme.primarySoftBlue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Comments section
            _buildCommentsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: MerryWayTheme.primarySoftBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: MerryWayTheme.primarySoftBlue),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: MerryWayTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: MerryWayTheme.textMuted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: MerryWayTheme.textDark,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCommentsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Comments (${_comments.length})',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: MerryWayTheme.textDark,
            ),
          ),
          const SizedBox(height: 16),

          // Comment input
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: 'Add a comment...',
                    filled: true,
                    fillColor: MerryWayTheme.softBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                  maxLines: null,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _isSubmittingComment ? null : _postComment,
                icon: _isSubmittingComment
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                color: MerryWayTheme.primarySoftBlue,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Comments list
          if (_comments.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No comments yet. Be the first!',
                  style: TextStyle(color: MerryWayTheme.textMuted),
                ),
              ),
            )
          else
            ..._comments.map((comment) {
              final author = widget.allMembers.firstWhere(
                (m) => m.id == comment.memberId,
                orElse: () => FamilyMember(
                  id: comment.memberId,
                  name: 'Unknown',
                  age: 0,
                  role: MemberRole.parent,
                ),
              );

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: MerryWayTheme.softBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          author.avatarEmoji ?? author.name.substring(0, 1),
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          author.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatCommentTime(comment.createdAt),
                          style: const TextStyle(
                            fontSize: 12,
                            color: MerryWayTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      comment.body,
                      style: const TextStyle(
                        fontSize: 14,
                        color: MerryWayTheme.textDark,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Color _getStateColor(IdeaState state) {
    switch (state) {
      case IdeaState.draft:
        return Colors.grey;
      case IdeaState.pendingApproval:
        return MerryWayTheme.accentGolden;
      case IdeaState.active:
        return Colors.green;
      case IdeaState.archived:
        return Colors.grey;
    }
  }

  String _formatCost(String cost) {
    switch (cost) {
      case 'free':
        return 'Free';
      case 'low':
        return '\$';
      case 'medium':
        return '\$\$';
      case 'high':
        return '\$\$\$';
      default:
        return cost;
    }
  }

  String _getPodName(String podId) {
    try {
      return widget.allPods.firstWhere((p) => p.id == podId).name;
    } catch (_) {
      return 'Unknown Group';
    }
  }

  String _formatCommentTime(DateTime? time) {
    if (time == null) return '';

    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(time);
    }
  }
}

