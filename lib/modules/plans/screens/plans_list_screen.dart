import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/redesign_tokens.dart';
import '../models/plan_models.dart';
import '../services/plans_service.dart';
import '../widgets/plan_card.dart';
import 'plan_thread_screen.dart';

/// Main screen showing list of plans
class PlansListScreen extends StatefulWidget {
  final String householdId;

  const PlansListScreen({
    super.key,
    required this.householdId,
  });

  @override
  State<PlansListScreen> createState() => _PlansListScreenState();
}

class _PlansListScreenState extends State<PlansListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<PlanSummary> _activePlans = [];
  List<PlanSummary> _archivedPlans = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadPlans();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPlans() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final activePlans = await PlansService.getPlanSummaries(
        householdId: widget.householdId,
        status: 'active',
      );

      final archivedPlans = await PlansService.getPlanSummaries(
        householdId: widget.householdId,
        status: 'archived',
      );

      setState(() {
        _activePlans = activePlans;
        _archivedPlans = archivedPlans;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _createPlan() async {
    // Show dialog to get plan title
    final title = await _showCreatePlanDialog();
    if (title == null || title.isEmpty) return;

    try {
      final request = CreatePlanRequest(
        householdId: widget.householdId,
        title: title,
      );

      final plan = await PlansService.createPlan(request);

      if (mounted) {
        // Navigate to plan thread
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PlanThreadScreen(planId: plan.id),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create plan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<String?> _showCreatePlanDialog() async {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'New Plan',
          style: GoogleFonts.eczar(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: RedesignTokens.ink,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'e.g., Weekend Museum Trip',
            hintStyle: GoogleFonts.spaceGrotesk(
              color: RedesignTokens.slate,
            ),
            filled: true,
            fillColor: RedesignTokens.canvas,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          style: GoogleFonts.spaceGrotesk(
            fontSize: 15,
            color: RedesignTokens.ink,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.spaceGrotesk(
                color: RedesignTokens.slate,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: RedesignTokens.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Create',
              style: GoogleFonts.spaceGrotesk(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RedesignTokens.canvas,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Plans',
          style: GoogleFonts.eczar(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: RedesignTokens.ink,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: RedesignTokens.primary,
          unselectedLabelColor: RedesignTokens.slate,
          indicatorColor: RedesignTokens.primary,
          labelStyle: GoogleFonts.spaceGrotesk(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Archived'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPlansList(_activePlans, isActive: true),
                    _buildPlansList(_archivedPlans, isActive: false),
                  ],
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createPlan,
        backgroundColor: RedesignTokens.accentGold,
        icon: const Icon(Icons.add),
        label: Text(
          'New Plan',
          style: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildPlansList(List<PlanSummary> plans, {required bool isActive}) {
    if (plans.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isActive ? Icons.explore : Icons.archive,
                size: 64,
                color: RedesignTokens.slate.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                isActive ? 'No active plans' : 'No archived plans',
                style: GoogleFonts.eczar(
                  fontSize: 20,
                  color: RedesignTokens.slate,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isActive
                    ? 'Tap the button below to start planning!'
                    : 'Completed plans will appear here',
                textAlign: TextAlign.center,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  color: RedesignTokens.slate,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPlans,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: plans.length,
        itemBuilder: (context, index) {
          final plan = plans[index];
          return PlanCard(
            plan: plan,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PlanThreadScreen(planId: plan.id),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading plans',
              style: GoogleFonts.eczar(
                fontSize: 20,
                color: RedesignTokens.ink,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                color: RedesignTokens.slate,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPlans,
              style: ElevatedButton.styleFrom(
                backgroundColor: RedesignTokens.primary,
              ),
              child: Text(
                'Retry',
                style: GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

