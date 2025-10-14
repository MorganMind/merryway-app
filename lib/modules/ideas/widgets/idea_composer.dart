import 'package:merryway/modules/core/theme/redesign_tokens.dart';
import 'package:flutter/material.dart';
import '../../family/models/family_models.dart';
import '../../family/models/pod_model.dart';
import '../models/idea_models.dart';
import '../services/ideas_api_service.dart';

// Access MerryWayTheme constants
class MerryWayTheme {
  static const Color primarySoftBlue = Color(0xFF91C8E4);
  static const Color accentLavender = Color(0xFFB4A7D6);
  static const Color accentGolden = Color(0xFFFFD700);
  static const Color textDark = Color(0xFF2D3436);
  static const Color textMuted = Color(0xFF636E72);
  static const Color softBg = Color(0xFFF5F5F5);
}

class IdeaComposer extends StatefulWidget {
  final String householdId;
  final String currentMemberId;
  final List<FamilyMember> allMembers;
  final List<Pod> allPods;
  final Idea? existingIdea; // For edit mode

  const IdeaComposer({
    Key? key,
    required this.householdId,
    required this.currentMemberId,
    required this.allMembers,
    required this.allPods,
    this.existingIdea,
  }) : super(key: key);

  @override
  State<IdeaComposer> createState() => _IdeaComposerState();
}

class _IdeaComposerState extends State<IdeaComposer> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _summaryController = TextEditingController();
  final _detailsController = TextEditingController();
  final _locationController = TextEditingController();
  final _tagsController = TextEditingController();

  bool _isLoading = false;
  IdeaVisibility _visibility = IdeaVisibility.household;
  List<String> _selectedPodIds = [];
  String? _defaultPodId;
  String? _indoorOutdoor;
  int? _minAge;
  bool _needsAdult = false;
  int? _durationMinutes;
  int? _setupMinutes;
  String? _messLevel;
  String? _costBand;

  @override
  void initState() {
    super.initState();
    
    if (widget.existingIdea != null) {
      _loadExistingIdea();
    }
  }

  void _loadExistingIdea() {
    final idea = widget.existingIdea!;
    _titleController.text = idea.title;
    _summaryController.text = idea.summary ?? '';
    _detailsController.text = idea.detailsMd ?? '';
    _locationController.text = idea.locationHint ?? '';
    _tagsController.text = idea.tags.join(', ');
    _visibility = idea.visibility;
    _selectedPodIds = List.from(idea.visiblePodIds);
    _defaultPodId = idea.defaultPodId;
    _indoorOutdoor = idea.indoorOutdoor;
    _minAge = idea.minAge;
    _needsAdult = idea.needsAdult;
    _durationMinutes = idea.durationMinutes;
    _setupMinutes = idea.setupMinutes;
    _messLevel = idea.messLevel;
    _costBand = idea.costBand;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _summaryController.dispose();
    _detailsController.dispose();
    _locationController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _saveIdea() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final tags = _tagsController.text
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      final idea = Idea(
        id: widget.existingIdea?.id,
        householdId: widget.householdId,
        creatorMemberId: widget.currentMemberId,
        title: _titleController.text.trim(),
        summary: _summaryController.text.trim().isEmpty
            ? null
            : _summaryController.text.trim(),
        detailsMd: _detailsController.text.trim().isEmpty
            ? null
            : _detailsController.text.trim(),
        tags: tags,
        locationHint: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        indoorOutdoor: _indoorOutdoor,
        minAge: _minAge,
        needsAdult: _needsAdult,
        durationMinutes: _durationMinutes,
        setupMinutes: _setupMinutes,
        messLevel: _messLevel,
        costBand: _costBand,
        defaultPodId: _defaultPodId,
        visibility: _visibility,
        visiblePodIds: _visibility == IdeaVisibility.podOnly ? _selectedPodIds : [],
      );

      final apiService = IdeasApiService();
      
      if (widget.existingIdea != null) {
        // Update existing
        await apiService.updateIdea(widget.existingIdea!.id!, idea.toJson());
      } else {
        // Create new
        await apiService.createIdea(idea);
      }

      if (mounted) {
        Navigator.of(context).pop(true); // Return true to indicate success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.existingIdea != null
                ? '✨ Idea updated!'
                : '✨ Idea saved!'),
            backgroundColor: RedesignTokens.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving idea: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingIdea != null;
    
    return Scaffold(
      backgroundColor: MerryWayTheme.softBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          isEdit ? 'Edit Idea' : 'New Idea',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: RedesignTokens.ink,
          ),
        ),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveIdea,
              child: Text(
                isEdit ? 'Update' : 'Save',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: RedesignTokens.primary,
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Title (required)
            _buildSectionTitle('Title'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'e.g., Pizza and Movie Night',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Title is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Summary
            _buildSectionTitle('Summary'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _summaryController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Quick one-liner about this idea...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Details (markdown)
            _buildSectionTitle('Details'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _detailsController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Add more details, tips, or instructions...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Tags
            _buildSectionTitle('Tags'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _tagsController,
              decoration: InputDecoration(
                hintText: 'family, fun, indoor (comma separated)',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Location Hint
            _buildSectionTitle('Location (optional)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _locationController,
              decoration: InputDecoration(
                hintText: 'e.g., Golden Gate Park',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.place_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Feasibility Hints
            _buildSectionTitle('Feasibility'),
            const SizedBox(height: 12),
            
            // Indoor/Outdoor
            Row(
              children: [
                Expanded(
                  child: _buildChipSelector<String?>(
                    label: 'Indoor/Outdoor',
                    options: const [null, 'indoor', 'outdoor', 'either'],
                    optionLabels: const {
                      null: 'Any',
                      'indoor': 'Indoor',
                      'outdoor': 'Outdoor',
                      'either': 'Either',
                    },
                    selected: _indoorOutdoor,
                    onSelected: (value) => setState(() => _indoorOutdoor = value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Duration
            _buildNumberInput(
              label: 'Duration (minutes)',
              value: _durationMinutes,
              onChanged: (value) => setState(() => _durationMinutes = value),
            ),
            const SizedBox(height: 12),

            // Setup Time
            _buildNumberInput(
              label: 'Setup Time (minutes)',
              value: _setupMinutes,
              onChanged: (value) => setState(() => _setupMinutes = value),
            ),
            const SizedBox(height: 12),

            // Min Age
            _buildNumberInput(
              label: 'Minimum Age',
              value: _minAge,
              onChanged: (value) => setState(() => _minAge = value),
            ),
            const SizedBox(height: 12),

            // Needs Adult
            CheckboxListTile(
              title: const Text('Requires Adult Supervision'),
              value: _needsAdult,
              onChanged: (value) => setState(() => _needsAdult = value ?? false),
              activeColor: RedesignTokens.primary,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 12),

            // Mess Level
            _buildChipSelector<String?>(
              label: 'Mess Level',
              options: const [null, 'low', 'medium', 'high'],
              optionLabels: const {
                null: 'Any',
                'low': 'Low',
                'medium': 'Medium',
                'high': 'High',
              },
              selected: _messLevel,
              onSelected: (value) => setState(() => _messLevel = value),
            ),
            const SizedBox(height: 12),

            // Cost Band
            _buildChipSelector<String?>(
              label: 'Cost',
              options: const [null, 'free', 'low', 'medium', 'high'],
              optionLabels: const {
                null: 'Any',
                'free': 'Free',
                'low': '\$',
                'medium': '\$\$',
                'high': '\$\$\$',
              },
              selected: _costBand,
              onSelected: (value) => setState(() => _costBand = value),
            ),
            const SizedBox(height: 24),

            // Default Pod
            _buildSectionTitle('Designed For (optional)'),
            const SizedBox(height: 8),
            _buildPodSelector(),
            const SizedBox(height: 24),

            // Visibility
            _buildSectionTitle('Who Can See This'),
            const SizedBox(height: 8),
            _buildVisibilitySelector(),
            if (_visibility == IdeaVisibility.podOnly) ...[
              const SizedBox(height: 12),
              _buildPodVisibilitySelector(),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: RedesignTokens.ink,
      ),
    );
  }

  Widget _buildChipSelector<T>({
    required String label,
    required List<T> options,
    required Map<T, String> optionLabels,
    required T selected,
    required Function(T) onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: RedesignTokens.slate,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selected == option;
            return ChoiceChip(
              label: Text(optionLabels[option]!),
              selected: isSelected,
              onSelected: (_) => onSelected(option),
              selectedColor: RedesignTokens.primary.withOpacity(0.2),
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? RedesignTokens.primary : RedesignTokens.ink,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNumberInput({
    required String label,
    required int? value,
    required Function(int?) onChanged,
  }) {
    final controller = TextEditingController(text: value?.toString() ?? '');
    
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: RedesignTokens.slate,
            ),
          ),
        ),
        SizedBox(
          width: 100,
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onChanged: (text) {
              final parsed = int.tryParse(text);
              onChanged(parsed);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPodSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<String?>(
        value: _defaultPodId,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        hint: const Text('Select a group...'),
        items: [
          const DropdownMenuItem<String?>(
            value: null,
            child: Text('No specific group'),
          ),
          ...widget.allPods.map((pod) {
            return DropdownMenuItem<String>(
              value: pod.id,
              child: Text('${pod.icon} ${pod.name}'),
            );
          }),
        ],
        onChanged: (value) => setState(() => _defaultPodId = value),
      ),
    );
  }

  Widget _buildVisibilitySelector() {
    return Column(
      children: IdeaVisibility.values.map((vis) {
        return RadioListTile<IdeaVisibility>(
          value: vis,
          groupValue: _visibility,
          title: Text(vis.displayName),
          subtitle: Text(_getVisibilitySubtitle(vis)),
          activeColor: RedesignTokens.primary,
          onChanged: (value) {
            if (value != null) {
              setState(() => _visibility = value);
            }
          },
        );
      }).toList(),
    );
  }

  String _getVisibilitySubtitle(IdeaVisibility vis) {
    switch (vis) {
      case IdeaVisibility.household:
        return 'All family members can see and use this idea';
      case IdeaVisibility.private:
        return 'Only you (and parents) can see this idea';
      case IdeaVisibility.podOnly:
        return 'Only members of selected groups can see this';
    }
  }

  Widget _buildPodVisibilitySelector() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: RedesignTokens.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Groups',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: RedesignTokens.ink,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.allPods.map((pod) {
              final isSelected = _selectedPodIds.contains(pod.id);
              return FilterChip(
                label: Text('${pod.icon} ${pod.name}'),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedPodIds.add(pod.id!);
                    } else {
                      _selectedPodIds.remove(pod.id);
                    }
                  });
                },
                selectedColor: RedesignTokens.primary.withOpacity(0.2),
                backgroundColor: Colors.white,
                checkmarkColor: RedesignTokens.primary,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

