import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/redesign_tokens.dart';
import '../models/plan_models.dart';

/// Bottom sheet for making a final decision
class DecisionSheet extends StatefulWidget {
  final List<ProposalWithVotes> proposals;
  final Function(String? proposalId, String summary) onDecide;

  const DecisionSheet({
    super.key,
    required this.proposals,
    required this.onDecide,
  });

  @override
  State<DecisionSheet> createState() => _DecisionSheetState();
}

class _DecisionSheetState extends State<DecisionSheet> {
  String? _selectedProposalId;
  final _summaryController = TextEditingController();

  @override
  void dispose() {
    _summaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Make a Decision',
                      style: GoogleFonts.eczar(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: RedesignTokens.ink,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Proposal selection
              Text(
                'Choose a proposal (optional):',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: RedesignTokens.ink,
                ),
              ),
              const SizedBox(height: 12),

              ...widget.proposals.map((pw) {
                final isSelected = _selectedProposalId == pw.proposal.id;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedProposalId =
                          isSelected ? null : pw.proposal.id;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? RedesignTokens.accentGold.withOpacity(0.1)
                          : RedesignTokens.canvas,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? RedesignTokens.accentGold
                            : RedesignTokens.slate.withOpacity(0.2),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: isSelected
                              ? RedesignTokens.accentGold
                              : RedesignTokens.slate,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            pw.proposal.activityName,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: RedesignTokens.ink,
                            ),
                          ),
                        ),
                        Text(
                          '↑${pw.upvotes}',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 13,
                            color: RedesignTokens.accentGold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 20),

              // Summary
              Text(
                'Summary:',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: RedesignTokens.ink,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _summaryController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Write a brief summary of the decision...',
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

              const SizedBox(height: 24),

              // Decide button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onDecide(
                      _selectedProposalId,
                      _summaryController.text.trim(),
                    );
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: RedesignTokens.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Finalize Decision',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

