import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/redesign_tokens.dart';
import '../models/invite_models.dart';
import '../services/user_preferences_service.dart';
import 'onboarding_success_screen.dart';

/// Screen for user onboarding after joining a family
class OnboardingScreen extends StatefulWidget {
  final String householdId;
  final String householdName;
  final String memberName;

  const OnboardingScreen({
    super.key,
    required this.householdId,
    required this.householdName,
    required this.memberName,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  // Onboarding data
  TravelRadius? _travelRadius;
  MessTolerance? _messTolerance;
  CostCeiling? _costCeiling;
  bool _quietHoursEnabled = false;
  List<String> _selectedInterests = [];

  final List<String> _availableInterests = [
    'outdoors', 'crafts', 'library', 'food_spots', 'rainy_day',
    'free', 'hikes', 'games', 'movies', 'music', 'sports', 'art'
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Welcome, ${widget.memberName}!',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: RedesignTokens.ink,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Progress Indicator
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: (_currentPage + 1) / 3,
                    backgroundColor: RedesignTokens.canvas,
                    valueColor: const AlwaysStoppedAnimation<Color>(RedesignTokens.primary),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '${_currentPage + 1}/3',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    color: RedesignTokens.slate,
                  ),
                ),
              ],
            ),
          ),

          // Page Content
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (page) {
                setState(() => _currentPage = page);
              },
              children: [
                _buildBasicsPage(),
                _buildPreferencesPage(),
                _buildInterestsPage(),
              ],
            ),
          ),

          // Navigation
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (_currentPage > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousPage,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: RedesignTokens.primary,
                        side: const BorderSide(color: RedesignTokens.primary),
                      ),
                      child: Text(
                        'Back',
                        style: GoogleFonts.spaceGrotesk(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                if (_currentPage > 0) const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _canContinue() ? _nextPage : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: RedesignTokens.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      _currentPage == 2 ? 'Finish' : 'Next',
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicsPage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Let\'s get to know you',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: RedesignTokens.ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tell us a bit about your preferences so we can suggest better activities.',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              color: RedesignTokens.slate,
            ),
          ),
          const SizedBox(height: 32),

          // Travel Radius
          Text(
            'How far are you willing to travel?',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: RedesignTokens.ink,
            ),
          ),
          const SizedBox(height: 12),
          ...TravelRadius.values.map((radius) => RadioListTile<TravelRadius>(
            title: Text(_getTravelRadiusLabel(radius)),
            subtitle: Text(_getTravelRadiusDescription(radius)),
            value: radius,
            groupValue: _travelRadius,
            onChanged: (value) {
              setState(() => _travelRadius = value);
            },
          )),

          const SizedBox(height: 24),

          // Mess Tolerance
          Text(
            'How comfortable are you with mess?',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: RedesignTokens.ink,
            ),
          ),
          const SizedBox(height: 12),
          ...MessTolerance.values.map((tolerance) => RadioListTile<MessTolerance>(
            title: Text(_getMessToleranceLabel(tolerance)),
            subtitle: Text(_getMessToleranceDescription(tolerance)),
            value: tolerance,
            groupValue: _messTolerance,
            onChanged: (value) {
              setState(() => _messTolerance = value);
            },
          )),
        ],
      ),
    );
  }

  Widget _buildPreferencesPage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activity Preferences',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: RedesignTokens.ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Help us understand your activity preferences.',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              color: RedesignTokens.slate,
            ),
          ),
          const SizedBox(height: 32),

          // Cost Ceiling
          Text(
            'What\'s your typical budget for activities?',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: RedesignTokens.ink,
            ),
          ),
          const SizedBox(height: 12),
          ...CostCeiling.values.map((ceiling) => RadioListTile<CostCeiling>(
            title: Text(_getCostCeilingLabel(ceiling)),
            subtitle: Text(_getCostCeilingDescription(ceiling)),
            value: ceiling,
            groupValue: _costCeiling,
            onChanged: (value) {
              setState(() => _costCeiling = value);
            },
          )),

          const SizedBox(height: 24),

          // Quiet Hours
          SwitchListTile(
            title: Text(
              'Enable Quiet Hours',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: RedesignTokens.ink,
              ),
            ),
            subtitle: Text(
              'Get suggestions for quieter activities during certain times',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                color: RedesignTokens.slate,
              ),
            ),
            value: _quietHoursEnabled,
            onChanged: (value) {
              setState(() => _quietHoursEnabled = value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInterestsPage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What do you enjoy?',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: RedesignTokens.ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select at least 3 interests to help us suggest better activities.',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              color: RedesignTokens.slate,
            ),
          ),
          const SizedBox(height: 24),

          // Interest Chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableInterests.map((interest) => FilterChip(
              label: Text(_getInterestLabel(interest)),
              selected: _selectedInterests.contains(interest),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedInterests.add(interest);
                  } else {
                    _selectedInterests.remove(interest);
                  }
                });
              },
            )).toList(),
          ),

          const SizedBox(height: 16),

          if (_selectedInterests.length < 3)
            Text(
              'Please select at least 3 interests (${_selectedInterests.length}/3)',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                color: RedesignTokens.accentGold,
              ),
            ),
        ],
      ),
    );
  }

  bool _canContinue() {
    switch (_currentPage) {
      case 0:
        return _travelRadius != null && _messTolerance != null;
      case 1:
        return _costCeiling != null;
      case 2:
        return _selectedInterests.length >= 3;
      default:
        return false;
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  Future<void> _finishOnboarding() async {
    try {
      await UserPreferencesService.updateUserPreferences(
        travelRadius: _travelRadius,
        messTolerance: _messTolerance,
        costCeiling: _costCeiling,
        quietHoursEnabled: _quietHoursEnabled,
        interests: _selectedInterests,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OnboardingSuccessScreen(
            householdName: widget.householdName,
            memberName: widget.memberName,
          ),
        ),
      );
    } catch (e) {
      _showErrorSnackBar('Failed to save preferences: $e');
    }
  }

  // Helper methods for labels and descriptions
  String _getTravelRadiusLabel(TravelRadius radius) {
    switch (radius) {
      case TravelRadius.walkable: return 'Walking distance';
      case TravelRadius.shortDrive: return 'Short drive (15-30 min)';
      case TravelRadius.noTravel: return 'Stay at home';
    }
  }

  String _getTravelRadiusDescription(TravelRadius radius) {
    switch (radius) {
      case TravelRadius.walkable: return 'Activities within walking distance';
      case TravelRadius.shortDrive: return 'Activities within a short drive';
      case TravelRadius.noTravel: return 'Home-based activities only';
    }
  }

  String _getMessToleranceLabel(MessTolerance tolerance) {
    switch (tolerance) {
      case MessTolerance.low: return 'Low mess';
      case MessTolerance.medium: return 'Some mess is okay';
      case MessTolerance.high: return 'Mess is fine';
    }
  }

  String _getMessToleranceDescription(MessTolerance tolerance) {
    switch (tolerance) {
      case MessTolerance.low: return 'Clean, organized activities';
      case MessTolerance.medium: return 'Some cleanup is acceptable';
      case MessTolerance.high: return 'Messy activities are welcome';
    }
  }

  String _getCostCeilingLabel(CostCeiling ceiling) {
    switch (ceiling) {
      case CostCeiling.low: return '\$ - Budget friendly';
      case CostCeiling.medium: return '\$\$ - Moderate cost';
      case CostCeiling.high: return '\$\$\$ - Premium activities';
    }
  }

  String _getCostCeilingDescription(CostCeiling ceiling) {
    switch (ceiling) {
      case CostCeiling.low: return 'Free or low-cost activities';
      case CostCeiling.medium: return 'Moderately priced activities';
      case CostCeiling.high: return 'Higher-end activities and experiences';
    }
  }

  String _getInterestLabel(String interest) {
    switch (interest) {
      case 'outdoors': return 'Outdoors';
      case 'crafts': return 'Crafts';
      case 'library': return 'Library';
      case 'food_spots': return 'Food & Dining';
      case 'rainy_day': return 'Rainy Day';
      case 'free': return 'Free Activities';
      case 'hikes': return 'Hiking';
      case 'games': return 'Games';
      case 'movies': return 'Movies';
      case 'music': return 'Music';
      case 'sports': return 'Sports';
      case 'art': return 'Art';
      default: return interest;
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
