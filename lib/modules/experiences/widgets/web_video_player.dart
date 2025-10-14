import 'package:flutter/material.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
// ignore: undefined_prefixed_name
import 'dart:ui_web' as ui_web;
import '../../../modules/core/theme/redesign_tokens.dart';

/// Web-specific video player using HTML5 video element
class WebVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const WebVideoPlayer({super.key, required this.videoUrl});

  @override
  State<WebVideoPlayer> createState() => _WebVideoPlayerState();
}

class _WebVideoPlayerState extends State<WebVideoPlayer> {
  late String _viewId;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _viewId = 'video-${DateTime.now().millisecondsSinceEpoch}-${widget.videoUrl.hashCode}';
    _registerVideoElement();
  }

  void _registerVideoElement() {
    // ignore: undefined_prefixed_name
    ui_web.platformViewRegistry.registerViewFactory(_viewId, (int viewId) {
      final videoElement = html.VideoElement()
        ..src = widget.videoUrl
        ..autoplay = true
        ..loop = true
        ..muted = true
        ..controls = false
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'contain'
        ..style.backgroundColor = '#000000';
      
      // Set playsInline attribute
      videoElement.setAttribute('playsinline', 'true');
      videoElement.setAttribute('webkit-playsinline', 'true');
      
      videoElement.onLoadedMetadata.listen((event) {
        debugPrint('✅ Web video loaded: ${widget.videoUrl}');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });
      
      videoElement.onError.listen((event) {
        debugPrint('❌ Web video error: ${widget.videoUrl}');
        if (mounted) {
          setState(() {
            _hasError = true;
            _isLoading = false;
          });
        }
      });

      // Start loading
      videoElement.load();
      
      return videoElement;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                const Text(
                  'This video format may not be supported on web',
                  style: TextStyle(
                    fontSize: 13,
                    color: RedesignTokens.slate,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
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
          child: HtmlElementView(viewType: _viewId),
        ),
        // Loading indicator
        if (_isLoading)
          Container(
            height: 450,
            color: RedesignTokens.primary.withOpacity(0.1),
            child: const Center(
              child: CircularProgressIndicator(color: RedesignTokens.primary),
            ),
          ),
        // Video indicator badge
        if (!_isLoading && !_hasError)
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
                  Icon(Icons.videocam, size: 14, color: Colors.white),
                  SizedBox(width: 4),
                  Text(
                    'VIDEO',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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

