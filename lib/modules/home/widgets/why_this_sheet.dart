import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:go_router/go_router.dart';
import '../../../modules/core/theme/redesign_tokens.dart';
import '../../../modules/family/models/family_models.dart';
import '../../auth/services/user_context_service.dart';
import '../services/why_this_service.dart';
import '../../core/widgets/sparkle_loading.dart';

/// Bottom sheet for "Why This?" voice persuasion feature
class WhyThisSheet extends StatefulWidget {
  final ActivitySuggestion suggestion;
  final List<FamilyMember> allMembers;
  final List<String> activeParticipantIds;
  final String? currentMemberId;
  final String householdId;

  const WhyThisSheet({
    super.key,
    required this.suggestion,
    required this.allMembers,
    required this.activeParticipantIds,
    this.currentMemberId,
    required this.householdId,
  });

  @override
  State<WhyThisSheet> createState() => _WhyThisSheetState();
}

class _WhyThisSheetState extends State<WhyThisSheet> {
  bool _isLoading = true;
  String? _audioUrl;
  String _transcript = '';
  String _rationaleLine = '';
  String? _altSuggestionId;
  String? _errorMessage;

  // Audio player state
  AudioPlayer? _audioPlayer;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _showCaptions = true;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _setupAudioListeners();
    _loadWhyThis();
  }

  void _setupAudioListeners() {
    // Listen to player state
    _audioPlayer?.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
        });
        
        if (state.processingState == ProcessingState.completed) {
          _logAction(WhyThisAction.audioCompleted);
          setState(() {
            _isPlaying = false;
            _position = Duration.zero;
          });
        }
      }
    });

    // Listen to duration changes
    _audioPlayer?.durationStream.listen((duration) {
      if (mounted && duration != null) {
        setState(() => _duration = duration);
      }
    });

    // Listen to position changes
    _audioPlayer?.positionStream.listen((position) {
      if (mounted) {
        setState(() => _position = position);
      }
    });
  }

  Future<void> _setupAudio() async {
    if (_audioUrl == null || _audioUrl!.isEmpty) return;
    
    try {
      print('🎵 Setting up audio: $_audioUrl');
      await _audioPlayer?.setUrl(_audioUrl!);
      print('✅ Audio setup complete');
    } catch (e) {
      print('❌ Error setting up audio: $e');
    }
  }

  Future<void> _loadWhyThis() async {
    try {
      _logAction(WhyThisAction.opened);

      final participants = _getParticipants();
      final kidMode = await _isKidMode();

      // Use actual ID if available, otherwise fall back to activity name hash
      final suggestionId = widget.suggestion.id ?? widget.suggestion.activity.hashCode.toString();
      
      final response = await WhyThisService.generateRationale(
        suggestionId: suggestionId,
        shownSetId: suggestionId,
        householdId: widget.householdId,
        participants: participants,
        kidMode: kidMode,
      );

      if (mounted) {
        print('🎵 Why This Response:');
        print('  Audio URL: ${response.audioUrl}');
        print('  Transcript: ${response.transcript.substring(0, response.transcript.length > 50 ? 50 : response.transcript.length)}...');
        print('  Rationale: ${response.rationaleLine}');
        
        setState(() {
          _audioUrl = response.audioUrl;
          _transcript = response.transcript;
          _rationaleLine = response.rationaleLine;
          _altSuggestionId = response.altSuggestionId;
          _isLoading = false;
        });

        // Load audio source
        if (_audioUrl != null && _audioUrl!.isNotEmpty) {
          try {
            print('🎵 Loading audio from: $_audioUrl');
            await _audioPlayer?.setUrl(_audioUrl!);
            print('✅ Audio loaded successfully');
          } catch (e) {
            print('❌ Error loading audio: $e');
            // Audio failed to load, but we have transcript
          }
        } else {
          print('⚠️ No audio URL provided by backend');
        }
      }
    } catch (e) {
      print('Error loading why-this: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Could not load rationale. Please try again.';
          _transcript = 'This activity looks great for your family right now!';
        });
      }
    }
  }

  List<ParticipantInfo> _getParticipants() {
    return widget.activeParticipantIds
        .map((id) {
          final member = widget.allMembers.firstWhere(
            (m) => m.id == id,
            orElse: () => widget.allMembers.first,
          );
          return ParticipantInfo(
            memberId: member.id ?? id,
            ageRange: _getAgeRange(member.age),
            role: _getRole(member.role),
          );
        })
        .toList();
  }

  String _getAgeRange(int? age) {
    if (age == null) return '18+';
    if (age < 5) return '0-4';
    if (age < 7) return '5-6';
    if (age < 10) return '7-9';
    if (age < 13) return '10-12';
    if (age < 18) return '13-17';
    return '18+';
  }

  String _getRole(MemberRole role) {
    switch (role) {
      case MemberRole.parent:
        return 'adult';
      case MemberRole.caregiver:
        return 'adult';
      case MemberRole.teen:
        return 'teen';
      case MemberRole.child:
        return 'kid';
      default:
        return 'kid';
    }
  }

  Future<bool> _isKidMode() async {
    final currentUser = UserContextService.getCurrentMember(
      widget.currentMemberId,
      widget.allMembers,
    );
    return currentUser?.role == MemberRole.child || 
           currentUser?.role == MemberRole.teen;
  }

  void _logAction(String action) {
    // Use actual ID if available, otherwise fall back to activity name hash
    final suggestionId = widget.suggestion.id ?? widget.suggestion.activity.hashCode.toString();
    
    WhyThisService.logAction(
      suggestionId: suggestionId,
      action: action,
      shownSetId: suggestionId,
      durationPlayedMs: _position.inMilliseconds,
    );
  }

  Future<void> _retryRationale() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final suggestionId = widget.suggestion.id ?? widget.suggestion.activity.hashCode.toString();
      
      // Get current participants
      final List<ParticipantInfo> participants = widget.activeParticipantIds
          .map((id) => widget.allMembers.firstWhere((m) => m.id == id))
          .map((member) => ParticipantInfo(
                memberId: member.id!,
                ageRange: _getAgeRange(member.age),
                role: _getRole(member.role),
              ))
          .toList();

      // Call retry API
      final response = await WhyThisService.retryRationale(
        suggestionId: suggestionId,
        shownSetId: suggestionId,
        householdId: widget.householdId,
        participants: participants,
        kidMode: await _isKidMode(),
      );

      // Update state with new content
      setState(() {
        _audioUrl = response.audioUrl;
        _transcript = response.transcript;
        _rationaleLine = response.rationaleLine;
        _altSuggestionId = response.altSuggestionId;
        _isLoading = false;
      });

      // Log the retry action
      _logAction(WhyThisAction.audioStarted);

      // If we have new audio, set it up
      if (_audioUrl != null && _audioUrl!.isNotEmpty) {
        await _setupAudio();
      }

    } catch (e) {
      print('❌ Error retrying rationale: $e');
      setState(() {
        _errorMessage = 'Failed to generate new rationale: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _playPause() async {
    print('🎵 Play/Pause clicked. Audio URL: $_audioUrl, Is Playing: $_isPlaying');
    
    if (_audioUrl == null || _audioUrl!.isEmpty) {
      print('⚠️ No audio URL available');
      return;
    }

    try {
      if (_isPlaying) {
        print('⏸️ Pausing audio...');
        await _audioPlayer?.pause();
      } else {
        if (_position == Duration.zero) {
          print('▶️ Starting audio playback...');
          _logAction(WhyThisAction.audioStarted);
        }
        
        // If completed, restart from beginning
        if (_position == _duration && _duration > Duration.zero) {
          print('🔄 Restarting audio from beginning...');
          await _audioPlayer?.seek(Duration.zero);
        }
        
        await _audioPlayer?.play();
        print('▶️ Audio play called');
      }
    } catch (e) {
      print('❌ Error playing audio: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not play audio: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _seekTo(Duration position) async {
    try {
      await _audioPlayer?.seek(position);
    } catch (e) {
      print('Error seeking: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Container(
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Close button
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                _logAction(WhyThisAction.dismissed);
                context.pop();
              },
            ),
          ),
          
          // Scrollable content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Cover image (placeholder for now)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _buildPlaceholderImage(),
                  ),

                  const SizedBox(height: 16),

                  // Title
                  Text(
                    widget.suggestion.activity,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: RedesignTokens.ink,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Rationale chips
                  if (!_isLoading && _rationaleLine.isNotEmpty)
                    Text(
                      _rationaleLine,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        color: RedesignTokens.slate,
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Audio player or loading
                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(
                          color: RedesignTokens.primary,
                        ),
                      ),
                    )
                  else if (_errorMessage != null)
                    _buildErrorState()
                  else if (_audioUrl != null && _audioUrl!.isNotEmpty)
                    _buildAudioPlayer()
                  else
                    _buildTextOnly(),

                  const SizedBox(height: 24),

                  // Captions toggle
                  if (!_isLoading && _audioUrl != null && _audioUrl!.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Captions',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: RedesignTokens.ink,
                          ),
                        ),
                        Switch(
                          value: _showCaptions,
                          onChanged: (value) {
                            setState(() => _showCaptions = value);
                          },
                          activeColor: RedesignTokens.primary,
                        ),
                      ],
                    ),

                  // Captions
                  if (_showCaptions && _transcript.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: RedesignTokens.canvas,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: RedesignTokens.primary.withOpacity(0.1),
                        ),
                      ),
                      child: Text(
                        _transcript,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          height: 1.6,
                          color: RedesignTokens.ink,
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Action buttons
                  _buildActionButtons(),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 150,
      width: double.infinity,
      color: RedesignTokens.primary.withOpacity(0.1),
      child: Icon(
        Icons.image,
        size: 48,
        color: RedesignTokens.primary.withOpacity(0.3),
      ),
    );
  }

  Widget _buildAudioPlayer() {
    return Column(
      children: [
        // Play/Pause button
        Center(
          child: IconButton(
            icon: Icon(
              _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
            ),
            iconSize: 64,
            color: RedesignTokens.primary,
            onPressed: _playPause,
          ),
        ),

        const SizedBox(height: 12),

        // Progress bar
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: RedesignTokens.primary,
            inactiveTrackColor: RedesignTokens.primary.withOpacity(0.2),
            thumbColor: RedesignTokens.primary,
            overlayColor: RedesignTokens.primary.withOpacity(0.2),
          ),
          child: Slider(
            value: _position.inMilliseconds.toDouble(),
            max: _duration.inMilliseconds > 0
                ? _duration.inMilliseconds.toDouble()
                : 1.0,
            onChanged: (value) {
              _seekTo(Duration(milliseconds: value.toInt()));
            },
          ),
        ),

        // Time labels
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(_position),
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  color: RedesignTokens.slate,
                ),
              ),
              Text(
                _formatDuration(_duration),
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  color: RedesignTokens.slate,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextOnly() {
    return Column(
      children: [
        Icon(
          Icons.text_fields,
          size: 48,
          color: RedesignTokens.slate.withOpacity(0.5),
        ),
        const SizedBox(height: 8),
        Text(
          'Audio not available - read below',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            color: RedesignTokens.slate,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Column(
      children: [
        Icon(
          Icons.error_outline,
          size: 48,
          color: RedesignTokens.slate.withOpacity(0.5),
        ),
        const SizedBox(height: 8),
        Text(
          _errorMessage ?? 'Could not load audio',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            color: RedesignTokens.slate,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () {
            setState(() {
              _isLoading = true;
              _errorMessage = null;
            });
            _loadWhyThis();
          },
          child: Text(
            'Retry',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: RedesignTokens.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Primary: "I'm in"
        ElevatedButton(
          onPressed: () {
            _logAction(WhyThisAction.actionStart);
            context.pop();
            // The suggestion card's "Make it an experience" flow will handle this
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Great! Use "Make it an experience" to get started'),
                duration: Duration(seconds: 2),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: RedesignTokens.primary,
            foregroundColor: RedesignTokens.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: Text(
            "I'm in",
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Secondary: "Save for Soon"
        OutlinedButton(
          onPressed: () {
            _logAction(WhyThisAction.actionSave);
            // TODO: Implement wishbook save
            context.pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Saved to Soon'),
                duration: Duration(seconds: 2),
              ),
            );
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: RedesignTokens.primary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            side: BorderSide(color: RedesignTokens.primary, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Save for Soon',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const SizedBox(height: 12),

        // "Try Again" button
        TextButton.icon(
          onPressed: _isLoading ? null : _retryRationale,
          icon: _isLoading 
            ? const SizedBox(
                width: 16,
                height: 16,
                child: SparkleLoading(size: 16),
              )
            : const Icon(Icons.refresh, size: 16),
          label: Text(
            _isLoading ? 'Generating...' : 'Try Again',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              color: _isLoading ? RedesignTokens.slate : RedesignTokens.primary,
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Tertiary: "Show an alternative"
        if (_altSuggestionId != null && _altSuggestionId!.isNotEmpty)
          TextButton(
            onPressed: () {
              _logAction(WhyThisAction.actionAlt);
              context.pop();
              // TODO: Load alternative suggestion
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Loading alternative...'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: Text(
              'Show an alternative',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                color: RedesignTokens.primary,
              ),
            ),
          ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _audioPlayer?.dispose();
    super.dispose();
  }
}

