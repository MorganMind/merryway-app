import 'package:flutter/material.dart';
import '../../core/theme/theme_colors.dart';
import '../../family/models/family_models.dart';
import '../../family/models/pod_model.dart';
import '../models/idea_models.dart';
import '../services/ideas_api_service.dart';
import '../widgets/idea_card.dart';
import '../widgets/idea_composer.dart';
import 'idea_detail_page.dart';

// Access MerryWayTheme constants
class MerryWayTheme {
  static const Color primarySoftBlue = Color(0xFF91C8E4);
  static const Color accentLavender = Color(0xFFB4A7D6);
  static const Color accentGolden = Color(0xFFFFD700);
  static const Color textDark = Color(0xFF2D3436);
  static const Color textMuted = Color(0xFF636E72);
  static const Color softBg = Color(0xFFF5F5F5);
}

class MyIdeasPage extends StatefulWidget {
  final String householdId;
  final String currentMemberId;
  final bool isParent;
  final List<FamilyMember> allMembers;
  final List<Pod> allPods;

  const MyIdeasPage({
    Key? key,
    required this.householdId,
    required this.currentMemberId,
    required this.isParent,
    required this.allMembers,
    required this.allPods,
  }) : super(key: key);

  @override
  State<MyIdeasPage> createState() => _MyIdeasPageState();
}

class _MyIdeasPageState extends State<MyIdeasPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _apiService = IdeasApiService();

  List<Idea> _draftIdeas = [];
  List<Idea> _pendingIdeas = [];
  List<Idea> _activeIdeas = [];
  List<Idea> _archivedIdeas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadIdeas();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadIdeas() async {
    setState(() => _isLoading = true);

    try {
      // Load drafts
      final drafts = await _apiService.listIdeas(
        householdId: widget.householdId,
        creatorMemberId: widget.currentMemberId,
        state: IdeaState.draft,
      );

      // Load pending
      final pending = await _apiService.listIdeas(
        householdId: widget.householdId,
        creatorMemberId: widget.currentMemberId,
        state: IdeaState.pendingApproval,
      );

      // Load active
      final active = await _apiService.listIdeas(
        householdId: widget.householdId,
        creatorMemberId: widget.currentMemberId,
        state: IdeaState.active,
      );

      // Load archived
      final archived = await _apiService.listIdeas(
        householdId: widget.householdId,
        creatorMemberId: widget.currentMemberId,
        state: IdeaState.archived,
      );

      setState(() {
        _draftIdeas = drafts;
        _pendingIdeas = pending;
        _activeIdeas = active;
        _archivedIdeas = archived;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading ideas: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading ideas: $e')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createNewIdea() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => IdeaComposer(
          householdId: widget.householdId,
          currentMemberId: widget.currentMemberId,
          allMembers: widget.allMembers,
          allPods: widget.allPods,
        ),
      ),
    );

    if (result == true) {
      _loadIdeas();
    }
  }

  Future<void> _toggleLike(Idea idea) async {
    try {
      if (idea.isLikedByMe) {
        await _apiService.unlikeIdea(idea.id!, widget.currentMemberId);
      } else {
        await _apiService.likeIdea(idea.id!, widget.currentMemberId);
      }
      _loadIdeas();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _openIdeaDetail(Idea idea) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IdeaDetailPage(
          ideaId: idea.id!,
          householdId: widget.householdId,
          currentMemberId: widget.currentMemberId,
          isParent: widget.isParent,
          allMembers: widget.allMembers,
          allPods: widget.allPods,
        ),
      ),
    ).then((_) => _loadIdeas());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MerryWayTheme.softBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Ideas',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: MerryWayTheme.textDark,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: MerryWayTheme.primarySoftBlue,
          unselectedLabelColor: MerryWayTheme.textMuted,
          indicatorColor: MerryWayTheme.primarySoftBlue,
          labelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          tabs: [
            Tab(
              child: _buildTabLabel('Draft', _draftIdeas.length),
            ),
            Tab(
              child: _buildTabLabel('Pending', _pendingIdeas.length),
            ),
            Tab(
              child: _buildTabLabel('Active', _activeIdeas.length),
            ),
            Tab(
              child: _buildTabLabel('Archived', _archivedIdeas.length),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildIdeasList(_draftIdeas, 'No drafts yet'),
                _buildIdeasList(_pendingIdeas, 'No pending ideas'),
                _buildIdeasList(_activeIdeas, 'No active ideas'),
                _buildIdeasList(_archivedIdeas, 'No archived ideas'),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewIdea,
        icon: const Icon(Icons.add),
        label: const Text('New Idea'),
        backgroundColor: MerryWayTheme.primarySoftBlue,
      ),
    );
  }

  Widget _buildTabLabel(String label, int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label),
        if (count > 0) ...[
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: MerryWayTheme.primarySoftBlue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildIdeasList(List<Idea> ideas, String emptyMessage) {
    if (ideas.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 64,
                color: MerryWayTheme.textMuted.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                emptyMessage,
                style: const TextStyle(
                  fontSize: 16,
                  color: MerryWayTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadIdeas,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: ideas.length,
        itemBuilder: (context, index) {
          final idea = ideas[index];
          return IdeaCard(
            idea: idea,
            allMembers: widget.allMembers,
            onTap: () => _openIdeaDetail(idea),
            onLike: () => _toggleLike(idea),
          );
        },
      ),
    );
  }
}

