import 'package:flutter/material.dart';
import '../models/pod_model.dart';
import '../models/rule_models.dart';
import '../services/rules_service.dart';

class PodRulesWidget extends StatefulWidget {
  final Pod pod;
  final VoidCallback onRulesChanged;

  const PodRulesWidget({
    super.key,
    required this.pod,
    required this.onRulesChanged,
  });

  @override
  State<PodRulesWidget> createState() => _PodRulesWidgetState();
}

class _PodRulesWidgetState extends State<PodRulesWidget> {
  late RulesService rulesService;
  List<PodRule> rules = [];
  bool isLoading = true;
  bool isExpanded = false;
  final newRuleController = TextEditingController();
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    rulesService = RulesService();
    _loadRules();
  }

  Future<void> _loadRules() async {
    if (widget.pod.id == null) {
      setState(() => isLoading = false);
      return;
    }

    try {
      final loadedRules = await rulesService.getPodRules(widget.pod.id!);
      setState(() {
        rules = loadedRules;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading pod rules: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _addRule() async {
    if (newRuleController.text.isEmpty || widget.pod.id == null) return;

    try {
      final rule = await rulesService.addPodRule(
        podId: widget.pod.id!,
        ruleText: newRuleController.text,
        category: selectedCategory,
      );

      setState(() {
        rules.add(rule);
        newRuleController.clear();
        selectedCategory = null;
      });

      widget.onRulesChanged();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pod rule added! 📝')),
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

  Future<void> _deleteRule(String ruleId) async {
    try {
      await rulesService.deletePodRule(ruleId);
      setState(() {
        rules.removeWhere((r) => r.id == ruleId);
      });
      widget.onRulesChanged();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    newRuleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pod Rules',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                IconButton(
                  onPressed: () => setState(() => isExpanded = !isExpanded),
                  icon: AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.expand_more),
                  ),
                ),
              ],
            ),

            // Rules list
            if (isLoading)
              const SizedBox(
                height: 40,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (rules.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'No pod rules yet',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF8B8B8B),
                      ),
                ),
              )
            else
              Column(
                children: rules.map((rule) => _buildRuleTile(rule)).toList(),
              ),

            // Expanded input
            if (isExpanded) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              // Category selector
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['time', 'health', 'safety', 'preference']
                      .map((cat) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(cat.capitalize()),
                              selected: selectedCategory == cat,
                              onSelected: (selected) {
                                setState(() {
                                  selectedCategory = selected ? cat : null;
                                });
                              },
                            ),
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 12),
              // Input field
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: newRuleController,
                      decoration: InputDecoration(
                        hintText: 'Add a pod rule...',
                        hintStyle: const TextStyle(fontSize: 13),
                        suffixIcon: IconButton(
                          onPressed: _addRule,
                          icon: const Icon(Icons.check),
                        ),
                      ),
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Pod rules apply to all members in this pod',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF8B8B8B),
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRuleTile(PodRule rule) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: _getCategoryColor(rule.category),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                _getCategoryEmoji(rule.category),
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              rule.ruleText,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: () => _deleteRule(rule.id ?? ''),
            icon: const Icon(Icons.close, size: 18),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String? category) {
    switch (category) {
      case 'time':
        return const Color(0xFFB4D7E8);
      case 'health':
        return const Color(0xFFE5C17D);
      case 'safety':
        return const Color(0xFFF4A6B8);
      case 'preference':
        return const Color(0xFFD9B9E0);
      default:
        return const Color(0xFFE0E0E0);
    }
  }

  String _getCategoryEmoji(String? category) {
    switch (category) {
      case 'time':
        return '⏰';
      case 'health':
        return '❤️';
      case 'safety':
        return '🛡️';
      case 'preference':
        return '💡';
      default:
        return '📝';
    }
  }
}

extension on String {
  String capitalize() => '${this[0].toUpperCase()}${substring(1)}';
}

