import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/video_player_card.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:video_player/video_player.dart';

class ExploreVideosScreen extends ConsumerStatefulWidget {
  const ExploreVideosScreen({super.key});

  @override
  ConsumerState<ExploreVideosScreen> createState() => _ExploreVideosScreenState();
}

class _ExploreVideosScreenState extends ConsumerState<ExploreVideosScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  int _currentVideoNumber = 1;
  final String _baseVideoUrl = 'https://rai-teen-videos.s3.eu-central-1.amazonaws.com/video';
  bool _isLoadingMore = false;

  // Mock data for financial education videos
  final List<Map<String, dynamic>> _videos = [
    {
      'id': 'v1',
      'title': 'How to Start Investing with Just USD100',
      'description': 'Learn how to begin your investment journey with as little as 100. I\'ll show you the best platforms and strategies for beginners.',
      'username': 'FinanceSage',
      'userAvatar': 'FS',
      'shares': 3620,
      'isSaved': false,
      'category': 'Investing',
      'videoUrl': 'https://rai-teen-videos.s3.eu-central-1.amazonaws.com/video1.mp4',
    },
    {
      'id': 'v2',
      'title': 'Understanding Credit Scores Simply',
      'description': 'Credit scores demystified! Learn what makes up your score and how to improve it in this 60-second financial tip.',
      'username': 'CreditPro',
      'userAvatar': 'CP',
      'shares': 2140,
      'isSaved': false,
      'category': 'Credit',
      'videoUrl': 'https://rai-teen-videos.s3.eu-central-1.amazonaws.com/video2.mp4',
    },
    {
      'id': 'v3',
      'title': 'Crypto Basics for Beginners',
      'description': 'Confused about cryptocurrency? Here\'s a simple breakdown of what it is and how it works. No technical jargon!',
      'username': 'CryptoClarity',
      'userAvatar': 'CC',
      'shares': 5270,
      'isSaved': true,
      'category': 'Crypto',
      'videoUrl': 'https://rai-teen-videos.s3.eu-central-1.amazonaws.com/video3.mp4',
    },
    {
      'id': 'v4',
      'title': 'Save 500 in 30 Days Challenge',
      'description': 'Join the 30-day savings challenge! Ill share daily tips to help you save your first 500 emergency fund.',
      'username': 'BudgetBabe',
      'userAvatar': 'BB',
      'shares': 6840,
      'isSaved': false,
      'category': 'Saving',
      'videoUrl': 'https://rai-teen-videos.s3.eu-central-1.amazonaws.com/video4.mp4',
    },
  ];

  @override
  void initState() {
    super.initState();
    _setupRefreshListener();
  }

  void _setupRefreshListener() {
    _pageController.addListener(() {
      if (_pageController.position.pixels >= _pageController.position.maxScrollExtent * 0.8 && !_isLoadingMore) {
        _loadNextVideo();
      }
    });
  }

  void _loadNextVideo() {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
      _currentVideoNumber = _currentVideoNumber >= 4 ? 1 : _currentVideoNumber + 1;

      // Create new video entry
      final newVideo = Map<String, dynamic>.from(_videos[_currentVideoNumber - 1]);
      newVideo['videoUrl'] = '$_baseVideoUrl$_currentVideoNumber.mp4';
      newVideo['id'] = 'v${_videos.length + 1}';

      _videos.add(newVideo);
      _isLoadingMore = false;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Video Feed with RefreshIndicator
          RefreshIndicator(
            onRefresh: () async {
              _loadNextVideo();
            },
            child: PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: _videos.length,
              itemBuilder: (context, index) {
                final video = _videos[index];
                return VisibilityDetector(
                  key: Key('video-${video['id']}'),
                  onVisibilityChanged: (visibilityInfo) {
                    if (visibilityInfo.visibleFraction > 0.5) {
                      setState(() {
                        _currentPage = index;
                      });
                    }
                  },
                  child: VideoPlayerCard(
                    title: video['title'] as String,
                    description: video['description'] as String,
                    username: video['username'] as String,
                    userAvatar: video['userAvatar'] as String,
                    shares: video['shares'] as int,
                    isSaved: video['isSaved'] as bool,
                    category: video['category'] as String,
                    thumbnailUrl: video['videoUrl'] as String,
                    onShare: () {
                      setState(() {
                        _videos[index]['shares']++;
                      });
                    },
                    onSave: () {
                      setState(() {
                        _videos[index]['isSaved'] = !_videos[index]['isSaved'] as bool;
                      });
                    },
                    onUserTap: () {
                      // Navigate to user profile
                    },
                  ),
                );
              },
            ),
          ),

          // Modern title at the top
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Text(
                'Learn',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
