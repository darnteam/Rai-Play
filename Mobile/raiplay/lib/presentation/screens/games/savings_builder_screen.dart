import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import '../../theme/app_theme.dart';
import 'dart:math';
import 'dart:async';

class SavingsBuilderScreen extends ConsumerStatefulWidget {
  final Function(int score, int coins) onGameComplete;

  const SavingsBuilderScreen({
    Key? key,
    required this.onGameComplete,
  }) : super(key: key);

  @override
  ConsumerState<SavingsBuilderScreen> createState() => _SavingsBuilderScreenState();
}

class _SavingsBuilderScreenState extends ConsumerState<SavingsBuilderScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  late Animation<double> _piggyBankAnimation;
  late Animation<double> _scaleAnimation;
  late ConfettiController _confettiController;

  // Game state
  double _currentSavings = 0;
  double _weeklyAllowance = 20;
  double _goalAmount = 100;
  int _currentWeek = 1;
  int _streak = 0;
  bool _isPiggyBankHappy = true;
  List<String> _eventHistory = [];
  String _currentStory = "";
  bool _showStoryDialog = true;
  int _currentChapter = 0;
  String _playerName = "Adventurer";
  String _savingsGoal = "a new bike";
  int _friendshipLevel = 0;
  int _wisdomLevel = 0;
  int _score = 0;
  bool _isGameCompleted = false;

  // Character stats
  final Map<String, int> _characterStats = {
    'Patience': 0,
    'Discipline': 0,
    'Wisdom': 0,
    'Friendship': 0,
  };

  // Story chapters with branching paths
  final List<Map<String, dynamic>> _storyChapters = [
    {
      'title': 'Welcome to Your Savings Journey!',
      'content': 'Hi! I\'m Penny the Piggy Bank, your financial guide! What\'s your name?',
      'emoji': '🐷',
      'type': 'name_input',
      'choices': [],
      'background': 'assets/backgrounds/welcome.png',
    },
    {
      'title': 'Setting Your Dream Goal',
      'content': 'Every great journey starts with a goal! What would you like to save for?',
      'emoji': '🎯',
      'type': 'goal_input',
      'choices': [],
      'tips': ['Think about something meaningful to you!', 'It could be a toy, game, or something special.'],
    },
    {
      'title': 'Your First Decision',
      'content': 'Your weekly allowance of €20 has arrived! Time for your first financial decision.',
      'emoji': '💶',
      'type': 'decision',
      'choices': [
        {
          'text': 'Save it all!',
          'effect': 'save_all',
          'description': 'Show great discipline and save the full amount',
          'icon': Icons.savings,
        },
        {
          'text': 'Save half, spend half',
          'effect': 'save_half',
          'description': 'Balance saving with some fun',
          'icon': Icons.balance,
        },
        {
          'text': 'Spend it all',
          'effect': 'spend_all',
          'description': 'Enjoy now, but think about later',
          'icon': Icons.shopping_cart,
        },
      ],
    },
    {
      'title': 'Weekend Challenge',
      'content': 'Your friends are going to the arcade! They invite you to join them.',
      'emoji': '🎮',
      'type': 'event',
      'choices': [
        {
          'text': 'Join them (€15)',
          'effect': 'spend_15',
          'description': 'Have fun with friends but spend money',
          'icon': Icons.groups,
        },
        {
          'text': 'Suggest a free activity',
          'effect': 'free_activity',
          'description': 'Be creative and save money',
          'icon': Icons.park,
        },
        {
          'text': 'Focus on saving',
          'effect': 'save',
          'description': 'Stay committed to your goal',
          'icon': Icons.savings_outlined,
        },
      ],
    },
  ];

  // Special events with character interactions
  final List<Map<String, dynamic>> _specialEvents = [
    {
      'title': 'Lucky Discovery!',
      'description': 'You found a €5 coin while helping clean the house!',
      'emoji': '🪙',
      'type': 'bonus',
      'reward': 5,
      'character': 'Luna the Lucky Coin',
      'message': 'Sometimes good things come from doing good deeds!',
      'animation': 'coin_sparkle',
    },
    {
      'title': 'Smart Saver Tip',
      'description': 'You learned a valuable lesson about saving!',
      'emoji': '👨‍💼',
      'type': 'wisdom',
      'reward': 2,
      'character': 'Max the Money Manager',
      'message': 'Setting aside a fixed amount each week helps build good habits!',
      'animation': 'lightbulb_moment',
    },
    {
      'title': 'Community Spirit',
      'description': 'Your friends are inspired by your saving journey!',
      'emoji': '👥',
      'type': 'friendship',
      'reward': 3,
      'character': 'Penny the Piggy Bank',
      'message': 'Your good habits are spreading! Keep it up!',
      'animation': 'friendship_hearts',
    },
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startGame();
  }

  void _setupAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _confettiController = ConfettiController(duration: const Duration(seconds: 3));

    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _piggyBankAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  void _startGame() {
    setState(() {
      _showStoryDialog = true;
      _currentStory = _storyChapters[0]['content'];
      _isGameCompleted = false;
      _score = 0;
    });
  }

  void _handleChapterChoice(String choice) {
    setState(() {
      switch (_storyChapters[_currentChapter]['type']) {
        case 'name_input':
          _playerName = choice;
          _characterStats['Friendship'] = (_characterStats['Friendship'] ?? 0) + 1;
          _score += 10;
          break;

        case 'goal_input':
          _savingsGoal = choice;
          _characterStats['Wisdom'] = (_characterStats['Wisdom'] ?? 0) + 1;
          _score += 15;
          break;

        case 'decision':
          switch (choice) {
            case 'save_all':
              _currentSavings += _weeklyAllowance;
              _characterStats['Discipline'] = (_characterStats['Discipline'] ?? 0) + 2;
              _characterStats['Patience'] = (_characterStats['Patience'] ?? 0) + 1;
              _score += 25;
              _streak++;
              break;
            case 'save_half':
              _currentSavings += _weeklyAllowance / 2;
              _characterStats['Discipline'] = (_characterStats['Discipline'] ?? 0) + 1;
              _score += 15;
              break;
            case 'spend_all':
              _characterStats['Friendship'] = (_characterStats['Friendship'] ?? 0) + 1;
              _score += 5;
              _streak = 0;
              break;
          }
          break;

        case 'event':
          switch (choice) {
            case 'spend_15':
              if (_currentSavings >= 15) {
                _currentSavings -= 15;
                _characterStats['Friendship'] = (_characterStats['Friendship'] ?? 0) + 2;
                _score += 10;
              } else {
                _showInsufficientFundsDialog();
              }
              break;
            case 'free_activity':
              _characterStats['Wisdom'] = (_characterStats['Wisdom'] ?? 0) + 2;
              _characterStats['Friendship'] = (_characterStats['Friendship'] ?? 0) + 1;
              _score += 20;
              break;
            case 'save':
              _currentSavings += 5;
              _characterStats['Discipline'] = (_characterStats['Discipline'] ?? 0) + 2;
              _score += 15;
              _streak++;
              break;
          }
          break;
      }

      // Progress to next chapter
      _currentChapter++;
      if (_currentChapter < _storyChapters.length) {
        _currentStory = _storyChapters[_currentChapter]['content'];
        _controller.forward(from: 0);
      } else {
        _showGameCompletion();
      }

      // Check for special events
      if (Random().nextDouble() < 0.3) {
        _showRandomEvent();
      }

      // Update animations
      _updatePiggyBankMood();
    });
  }

  void _showInsufficientFundsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.amber),
            SizedBox(width: 8),
            Text('Not Enough Savings'),
          ],
        ),
        content: const Text(
          'You don\'t have enough savings for this choice. This is a good lesson in checking your balance before making spending decisions!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('I Understand'),
          ),
        ],
      ),
    );
  }

  void _showGameCompletion() {
    setState(() {
      _isGameCompleted = true;
    });

    _confettiController.play();

    // Calculate final score and rewards
    final coins = (_score * 0.1).ceil();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎉 '),
            Text(
              'Congratulations, $_playerName!',
              style: const TextStyle(color: Color(0xFFFFED00)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: -pi / 2,
              maxBlastForce: 5,
              minBlastForce: 2,
              emissionFrequency: 0.05,
              numberOfParticles: 50,
              gravity: 0.1,
            ),
            const SizedBox(height: 16),
            Text(
              'You\'ve completed your savings journey!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFED00).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFED00)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: Color(0xFFFFED00)),
                      const SizedBox(width: 8),
                      Text(
                        'Final Score: $_score',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: const Color(0xFFFFED00),
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Coins Earned: $coins',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Your Achievements:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildAchievementIcon(
                  Icons.savings,
                  'Saver',
                  _currentSavings >= _goalAmount / 2,
                ),
                _buildAchievementIcon(
                  Icons.psychology,
                  'Wise',
                  _characterStats['Wisdom']! >= 3,
                ),
                _buildAchievementIcon(
                  Icons.favorite,
                  'Friend',
                  _characterStats['Friendship']! >= 3,
                ),
                _buildAchievementIcon(
                  Icons.military_tech,
                  'Disciplined',
                  _characterStats['Discipline']! >= 3,
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              widget.onGameComplete(_score, coins);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Complete Journey'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _startGame();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFED00),
              foregroundColor: Colors.black,
            ),
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementIcon(IconData icon, String label, bool achieved) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: achieved ? const Color(0xFFFFED00) : Colors.grey.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: achieved ? Colors.black : Colors.grey,
            size: 24,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: achieved ? Colors.black : Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  void _updatePiggyBankMood() {
    setState(() {
      _isPiggyBankHappy = _currentSavings >= _goalAmount * 0.5;
      if (_isPiggyBankHappy) {
        _piggyBankAnimation.addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            _controller.reverse();
          }
        });
        _controller.forward();
      }
    });
  }

  void _showRandomEvent() {
    if (Random().nextDouble() < 0.3) {
      final event = _specialEvents[Random().nextInt(_specialEvents.length)];
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Text(event['emoji']),
              const SizedBox(width: 8),
              Expanded(child: Text(event['title'])),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(event['description']),
              const SizedBox(height: 16),
              Text(
                event['message'],
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _handleEventReward(event);
              },
              child: const Text('Accept'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Decline'),
            ),
          ],
        ),
      );
    }
  }

  void _handleEventReward(Map<String, dynamic> event) {
    setState(() {
      switch (event['type']) {
        case 'bonus':
          _currentSavings += event['reward'];
          _score += 15;
          break;
        case 'wisdom':
          _characterStats['Wisdom'] = (_characterStats['Wisdom'] ?? 0) + (event['reward'] as int);
          _score += 10;
          break;
        case 'friendship':
          _characterStats['Friendship'] = (_characterStats['Friendship'] ?? 0) + (event['reward'] as int);
          _score += 10;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFED00), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Background pattern
              Positioned.fill(
                child: CustomPaint(
                  painter: MoneyPatternPainter(),
                ),
              ),

              // Main content
              Column(
                children: [
                  // App Bar
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Text(
                          'Savings Builder',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(width: 40), // For balance
                      ],
                    ),
                  ),

                  // Game content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Progress card
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Current Savings',
                                            style: Theme.of(context).textTheme.titleMedium,
                                          ),
                                          Text(
                                            '€${_currentSavings.toStringAsFixed(2)}',
                                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                                  color: const Color(0xFFFFED00),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            'Goal: $_savingsGoal',
                                            style: Theme.of(context).textTheme.titleMedium,
                                          ),
                                          Text(
                                            '€${_goalAmount.toStringAsFixed(2)}',
                                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                  color: Colors.grey,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: LinearProgressIndicator(
                                          value: _currentSavings / _goalAmount,
                                          backgroundColor: Colors.grey[200],
                                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFED00)),
                                          minHeight: 20,
                                        ),
                                      ),
                                      Positioned.fill(
                                        child: Center(
                                          child: Text(
                                            '${((_currentSavings / _goalAmount) * 100).toStringAsFixed(0)}%',
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Story card
                          if (_showStoryDialog && _currentChapter < _storyChapters.length)
                            Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          _storyChapters[_currentChapter]['emoji'],
                                          style: const TextStyle(fontSize: 32),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _storyChapters[_currentChapter]['title'],
                                            style: Theme.of(context).textTheme.titleLarge,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      _currentStory,
                                      style: Theme.of(context).textTheme.bodyLarge,
                                    ),
                                    const SizedBox(height: 24),
                                    if (_storyChapters[_currentChapter]['type'] == 'name_input' || _storyChapters[_currentChapter]['type'] == 'goal_input')
                                      TextField(
                                        decoration: InputDecoration(
                                          hintText: _storyChapters[_currentChapter]['type'] == 'name_input' ? 'Enter your name' : 'Enter your savings goal',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          filled: true,
                                          fillColor: Colors.grey[100],
                                        ),
                                        onSubmitted: _handleChapterChoice,
                                      )
                                    else if (_storyChapters[_currentChapter]['choices'].isNotEmpty)
                                      ..._storyChapters[_currentChapter]['choices'].map<Widget>(
                                        (choice) => Padding(
                                          padding: const EdgeInsets.only(bottom: 8),
                                          child: ElevatedButton(
                                            onPressed: () => _handleChapterChoice(choice['effect']),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFFFFED00),
                                              foregroundColor: Colors.black,
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 24,
                                                vertical: 16,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(choice['icon'] as IconData),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        choice['text'],
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                      Text(
                                                        choice['description'],
                                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                              color: Colors.black87,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),

                          const SizedBox(height: 16),

                          // Stats card
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Text(
                                    'Your Progress',
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      _buildStatIndicator('Patience', _characterStats['Patience']!),
                                      _buildStatIndicator('Discipline', _characterStats['Discipline']!),
                                      _buildStatIndicator('Wisdom', _characterStats['Wisdom']!),
                                      _buildStatIndicator('Friendship', _characterStats['Friendship']!),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Confetti overlay
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirection: pi / 2,
                  maxBlastForce: 5,
                  minBlastForce: 2,
                  emissionFrequency: 0.05,
                  numberOfParticles: 50,
                  gravity: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatIndicator(String stat, int value) {
    return Column(
      children: [
        Text(
          stat,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Row(
          children: List.generate(
            5,
            (index) => Icon(
              Icons.star_rounded,
              size: 16,
              color: index < value ? const Color(0xFFFFED00) : Colors.grey[300],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _confettiController.dispose();
    super.dispose();
  }
}

class MoneyPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const spacing = 40.0;
    final symbolSize = spacing * 0.4;

    for (var x = 0.0; x < size.width; x += spacing) {
      for (var y = 0.0; y < size.height; y += spacing) {
        if ((x + y) % (spacing * 2) == 0) {
          // Draw € symbol
          canvas.drawCircle(
            Offset(x + spacing / 2, y + spacing / 2),
            symbolSize,
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
