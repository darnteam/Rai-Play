import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:io';

class VideoPlayerCard extends StatefulWidget {
  final String title;
  final String description;
  final String username;
  final String userAvatar;
  final int shares;
  final bool isSaved;
  final String category;
  final String thumbnailUrl;
  final VoidCallback onShare;
  final VoidCallback onSave;
  final VoidCallback onUserTap;

  const VideoPlayerCard({
    super.key,
    required this.title,
    required this.description,
    required this.username,
    required this.userAvatar,
    required this.shares,
    required this.isSaved,
    required this.category,
    required this.thumbnailUrl,
    required this.onShare,
    required this.onSave,
    required this.onUserTap,
  });

  @override
  State<VideoPlayerCard> createState() => _VideoPlayerCardState();
}

class _VideoPlayerCardState extends State<VideoPlayerCard> with WidgetsBindingObserver {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  String? _errorMessage;
  bool _isDisposed = false;
  Timer? _initTimer;
  int _retryCount = 0;
  static const int maxRetries = 3;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeVideo();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _controller?.play();
    } else if (state == AppLifecycleState.paused) {
      _controller?.pause();
    }
  }

  Future<void> _initializeVideo() async {
    if (_isDisposed) return;
    if (_retryCount >= maxRetries) {
      setState(() {
        _errorMessage = 'Unable to load video after several attempts';
        _isInitialized = false;
      });
      return;
    }

    try {
      await _disposeController();

      if (_isDisposed) return;

      final controller = VideoPlayerController.network(
        widget.thumbnailUrl,
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );

      _controller = controller;

      // Set up completion callback before initialization
      _initTimer?.cancel();
      _initTimer = Timer(const Duration(seconds: 10), () {
        if (!_isInitialized && !_isDisposed) {
          debugPrint('Video initialization timed out, retrying...');
          _retryCount++;
          _initializeVideo();
        }
      });

      // Initialize with error handling
      try {
        await controller.initialize();

        if (_isDisposed) {
          await _disposeController();
          return;
        }

        _initTimer?.cancel();
        setState(() {
          _isInitialized = true;
          _errorMessage = null;
          _retryCount = 0;
        });

        await controller.setLooping(true);
        await controller.play();
      } catch (initError) {
        debugPrint('Video initialization error: $initError');
        if (!_isDisposed) {
          _retryCount++;
          if (_retryCount < maxRetries) {
            debugPrint('Retrying video initialization (attempt $_retryCount)...');
            Future.delayed(Duration(seconds: _retryCount), _initializeVideo);
          } else {
            setState(() {
              _errorMessage = 'Failed to initialize video';
              _isInitialized = false;
            });
          }
        }
        await _disposeController();
      }
    } catch (e) {
      debugPrint('Video controller creation error: $e');
      if (!_isDisposed) {
        setState(() {
          _errorMessage = 'Failed to load video';
          _isInitialized = false;
        });
      }
    }
  }

  Future<void> _disposeController() async {
    _initTimer?.cancel();
    try {
      final controller = _controller;
      if (controller != null) {
        await controller.pause();
        await controller.dispose();
        _controller = null;
      }
    } catch (e) {
      debugPrint('Error disposing controller: $e');
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _disposeController();
    super.dispose();
  }

  @override
  void didUpdateWidget(VideoPlayerCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.thumbnailUrl != oldWidget.thumbnailUrl) {
      _retryCount = 0;
      _initializeVideo();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Video player or error message
          if (_isInitialized && _controller?.value.isInitialized == true)
            GestureDetector(
              onTap: () {
                final controller = _controller;
                if (controller != null) {
                  setState(() {
                    if (controller.value.isPlaying) {
                      controller.pause();
                    } else {
                      controller.play();
                    }
                  });
                }
              },
              child: AspectRatio(
                aspectRatio: _controller?.value.aspectRatio ?? 16 / 9,
                child: VideoPlayer(_controller!),
              ),
            )
          else if (_errorMessage != null)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.white.withOpacity(0.6),
                    size: 48,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      _retryCount = 0;
                      _initializeVideo();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          else
            const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),

          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),

                // Description
                Text(
                  widget.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),

                // User info and category
                Row(
                  children: [
                    GestureDetector(
                      onTap: widget.onUserTap,
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            radius: 16,
                            child: Text(
                              widget.userAvatar,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.username,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        widget.category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Action buttons
          Positioned(
            right: 16,
            bottom: 100,
            child: Column(
              children: [
                // Save button
                _buildActionButton(
                  icon: widget.isSaved ? Icons.bookmark : Icons.bookmark_border,
                  label: widget.isSaved ? 'Saved' : 'Save',
                  onTap: widget.onSave,
                  context: context,
                ),
                const SizedBox(height: 16),

                // Share button
                _buildActionButton(
                  icon: Icons.share,
                  label: 'Share',
                  onTap: widget.onShare,
                  context: context,
                ),
              ],
            ),
          ),

          // Play/Pause indicator (shows briefly when tapped)
          if (_isInitialized)
            Center(
              child: AnimatedOpacity(
                opacity: _controller?.value.isPlaying == true ? 0.0 : 0.7,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _controller?.value.isPlaying == true ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required BuildContext context,
  }) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(icon),
            color: Colors.white,
            onPressed: onTap,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white,
              ),
        ),
      ],
    );
  }
}
