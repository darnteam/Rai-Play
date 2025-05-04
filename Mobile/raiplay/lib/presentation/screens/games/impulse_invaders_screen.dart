import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

// A provider for the game score to access later
final impulseInvadersScoreProvider = StateProvider<int>((ref) => 0);

class ImpulseInvadersScreen extends ConsumerStatefulWidget {
  final int difficulty;
  final Function(int score, int coins) onGameComplete;

  const ImpulseInvadersScreen({
    Key? key,
    this.difficulty = 2,
    required this.onGameComplete,
  }) : super(key: key);

  @override
  ConsumerState<ImpulseInvadersScreen> createState() => _ImpulseInvadersScreenState();
}

class _ImpulseInvadersScreenState extends ConsumerState<ImpulseInvadersScreen> with TickerProviderStateMixin {
  // Game state variables
  int _score = 0;
  int _lives = 3;
  int _streak = 0;
  bool _isGameActive = false;
  bool _isGameOver = false;
  int _countdownSeconds = 3;
  double _gameSpeed = 1.0;
  final int _gameDuration = 60;
  int _remainingSeconds = 60;
  late Timer _gameTimer;
  late Timer _countdownTimer;

  // Piggy bank position
  double _piggyPosition = 0.5;
  bool _isMovingLeft = false;
  bool _isMovingRight = false;
  final double _moveSpeed = 0.015; // Adjust this value to change movement speed

  // Falling items
  final List<FallingItem> _fallingItems = [];
  final Random _random = Random();

  // Item types
  final List<Map<String, dynamic>> _wantItems = [
    {'emoji': '👟', 'name': 'Sneakers'},
    {'emoji': '🎮', 'name': 'Games'},
    {'emoji': '🎸', 'name': 'Guitar'},
    {'emoji': '📱', 'name': 'Phone'},
    {'emoji': '💻', 'name': 'Laptop'},
    {'emoji': '🎧', 'name': 'Headphones'},
    {'emoji': '👕', 'name': 'Clothes'},
    {'emoji': '🎪', 'name': 'Entertainment'},
  ];

  final List<Map<String, dynamic>> _needItems = [
    {'emoji': '🥖', 'name': 'Food'},
    {'emoji': '💊', 'name': 'Medicine'},
    {'emoji': '🏠', 'name': 'Rent'},
    {'emoji': '📚', 'name': 'Education'},
    {'emoji': '🚌', 'name': 'Transport'},
    {'emoji': '💡', 'name': 'Utilities'},
    {'emoji': '🧴', 'name': 'Toiletries'},
    {'emoji': '👔', 'name': 'Work Clothes'},
  ];

  // Animation controllers
  late AnimationController _piggyAnimationController;
  late Animation<double> _piggyAnimation;
  late AnimationController _scoreAnimationController;
  late Animation<double> _scoreAnimation;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startCountdown();
    _startPigMovement();
  }

  void _setupAnimations() {
    // Piggy animation
    _piggyAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _piggyAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _piggyAnimationController,
        curve: Curves.elasticInOut,
      ),
    );

    // Score animation
    _scoreAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scoreAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(
        parent: _scoreAnimationController,
        curve: Curves.easeOutBack,
      ),
    );

    // Shake animation
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: -5.0, end: 5.0).animate(
      CurvedAnimation(
        parent: _shakeController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _countdownSeconds--;
      });

      if (_countdownSeconds <= 0) {
        timer.cancel();
        _startGame();
      }
    });
  }

  void _startGame() {
    setState(() {
      _isGameActive = true;
      _remainingSeconds = _gameDuration;
    });

    // Start spawning items
    _spawnItems();

    // Start game timer
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remainingSeconds--;

        // Increase difficulty over time
        if (_remainingSeconds % 15 == 0 && _gameSpeed < 2.0) {
          _gameSpeed += 0.2;
        }
      });

      if (_remainingSeconds <= 0 || _lives <= 0) {
        _endGame();
      }
    });
  }

  void _startPigMovement() {
    Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_isMovingLeft) {
        setState(() {
          _piggyPosition -= _moveSpeed;
          _piggyPosition = _piggyPosition.clamp(0.1, 0.9);
        });
      }
      if (_isMovingRight) {
        setState(() {
          _piggyPosition += _moveSpeed;
          _piggyPosition = _piggyPosition.clamp(0.1, 0.9);
        });
      }
    });
  }

  void _spawnItems() {
    Timer.periodic(Duration(milliseconds: (1500 / _gameSpeed).round()), (timer) {
      if (!_isGameActive) {
        timer.cancel();
        return;
      }

      setState(() {
        // 60% chance of want item, 40% chance of need item
        final isWantItem = _random.nextDouble() > 0.4;
        final items = isWantItem ? _wantItems : _needItems;
        final item = items[_random.nextInt(items.length)];

        final posX = _random.nextDouble() * (MediaQuery.of(context).size.width - 60);

        _fallingItems.add(
          FallingItem(
            x: posX,
            y: 0,
            isWantItem: isWantItem,
            speed: 3.0 * _gameSpeed,
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            emoji: item['emoji'],
            name: item['name'],
          ),
        );
      });
    });

    Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!_isGameActive) {
        timer.cancel();
        return;
      }

      final size = MediaQuery.of(context).size;
      final piggyLeft = size.width * _piggyPosition - 40;
      final piggyRight = piggyLeft + 80;
      final piggyTop = size.height - 130;

      setState(() {
        for (int i = _fallingItems.length - 1; i >= 0; i--) {
          final item = _fallingItems[i];
          item.y += item.speed;

          final itemCenterX = item.x + 30;
          final itemBottom = item.y + 60;

          if (item.y > MediaQuery.of(context).size.height - 150) {
            bool collidedWithPiggy = itemCenterX >= piggyLeft && itemCenterX <= piggyRight && itemBottom >= piggyTop;

            if (collidedWithPiggy) {
              // Collect wants with pig
              if (item.isWantItem) {
                _streak++;
                int points = _streak > 3 ? 20 : 10;
                _score += points;
                ref.read(impulseInvadersScoreProvider.notifier).state = _score;
                _scoreAnimationController.forward().then((_) => _scoreAnimationController.reverse());
              } else {
                // Hit by need
                _streak = 0;
                _lives--;
                _shakeController.forward().then((_) => _shakeController.reverse());
                _piggyAnimationController.forward().then((_) => _piggyAnimationController.reverse());
              }
              _fallingItems.removeAt(i);
            } else {
              // Item missed
              _fallingItems.removeAt(i);
              if (item.isWantItem) {
                // Missed a want - lose a life
                _streak = 0;
                _lives--;
                _shakeController.forward().then((_) => _shakeController.reverse());
                _piggyAnimationController.forward().then((_) => _piggyAnimationController.reverse());
              }
            }
          }
        }
      });
    });
  }

  void _endGame() {
    setState(() {
      _isGameActive = false;
      _isGameOver = true;
    });

    _gameTimer.cancel();

    // Calculate coins based on score
    final coins = (_score * 0.1).ceil(); // 10% of score as coins

    // Call the callback with score and coins
    widget.onGameComplete(_score, coins);
  }

  @override
  void dispose() {
    _gameTimer.cancel();
    if (_countdownSeconds > 0) {
      _countdownTimer.cancel();
    }
    _piggyAnimationController.dispose();
    _scoreAnimationController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFED00),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Game header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        color: Colors.black,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),

                    // Score
                    ScaleTransition(
                      scale: _scoreAnimation,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Colors.black,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "$_score",
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Lives
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          ...List.generate(
                            3,
                            (index) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 2),
                              child: Icon(
                                Icons.favorite_rounded,
                                color: index < _lives ? Colors.red : Colors.red.withOpacity(0.3),
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Timer bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.timer_rounded,
                      color: Colors.black,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: _isGameActive ? _remainingSeconds / _gameDuration : 1.0,
                          backgroundColor: Colors.black.withOpacity(0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _remainingSeconds < 10 ? Colors.red : Colors.black,
                          ),
                          minHeight: 10,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "$_remainingSeconds s",
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),

              // Game area
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Touch controls
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTapDown: (_) => setState(() => _isMovingLeft = true),
                            onTapUp: (_) => setState(() => _isMovingLeft = false),
                            onTapCancel: () => setState(() => _isMovingLeft = false),
                            child: Container(color: Colors.transparent),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTapDown: (_) => setState(() => _isMovingRight = true),
                            onTapUp: (_) => setState(() => _isMovingRight = false),
                            onTapCancel: () => setState(() => _isMovingRight = false),
                            child: Container(color: Colors.transparent),
                          ),
                        ),
                      ],
                    ),

                    // Falling items
                    if (_isGameActive)
                      ..._fallingItems
                          .map((item) => Positioned(
                                left: item.x,
                                top: item.y,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: item.isWantItem ? const Color(0xFFFFED00) : Colors.black.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          item.emoji,
                                          style: const TextStyle(fontSize: 30),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        item.name,
                                        style: theme.textTheme.labelSmall?.copyWith(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),

                    // Pig
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 16),
                      curve: Curves.linear,
                      left: MediaQuery.of(context).size.width * _piggyPosition - 40,
                      bottom: 50,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            margin: const EdgeInsets.only(bottom: 5),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.arrow_back, color: Colors.black, size: 14),
                                SizedBox(width: 4),
                                Text("TAP & HOLD", style: TextStyle(color: Colors.black, fontSize: 10)),
                                SizedBox(width: 4),
                                Icon(Icons.arrow_forward, color: Colors.black, size: 14),
                              ],
                            ),
                          ),
                          ScaleTransition(
                            scale: _piggyAnimation,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFED00),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Text(
                                  "🐷",
                                  style: TextStyle(fontSize: 40),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Instructions (left)
                    Positioned(
                      left: 16,
                      bottom: MediaQuery.of(context).size.height * 0.3,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFED00),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text("👟", style: TextStyle(fontSize: 24)),
                            ),
                            const SizedBox(height: 8),
                            const Icon(Icons.arrow_back, color: Colors.black),
                            Text(
                              "COLLECT",
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Instructions (right)
                    Positioned(
                      right: 16,
                      bottom: MediaQuery.of(context).size.height * 0.3,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text("🥖", style: TextStyle(fontSize: 24)),
                            ),
                            const SizedBox(height: 8),
                            const Icon(Icons.arrow_forward, color: Colors.black),
                            Text(
                              "AVOID",
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Overlays
                    if (_countdownSeconds > 0)
                      Container(
                        color: Colors.black.withOpacity(0.7),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Get Ready!",
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "$_countdownSeconds",
                                style: theme.textTheme.displayLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 32),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFED00),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Text("👟", style: TextStyle(fontSize: 24)),
                                        ),
                                        const SizedBox(width: 16),
                                        Text(
                                          "Collect wants to save for them",
                                          style: theme.textTheme.titleMedium?.copyWith(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Text("🥖", style: TextStyle(fontSize: 24)),
                                        ),
                                        const SizedBox(width: 16),
                                        Text(
                                          "Let needs pass through",
                                          style: theme.textTheme.titleMedium?.copyWith(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    if (_isGameOver)
                      Container(
                        color: Colors.black.withOpacity(0.7),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Game Over!",
                                style: theme.textTheme.headlineLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      "🎯",
                                      style: TextStyle(fontSize: 64),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      "Score: $_score",
                                      style: theme.textTheme.headlineMedium?.copyWith(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Coins Earned: ${(_score * 0.1).ceil()}",
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        color: const Color(0xFFFFED00),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Text(
                                      "You've learned to save for what you want while managing your needs!",
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.bodyLarge?.copyWith(
                                        color: Colors.black54,
                                      ),
                                    ),
                                    const SizedBox(height: 32),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        ElevatedButton.icon(
                                          icon: const Icon(Icons.replay_rounded),
                                          label: const Text("Play Again"),
                                          onPressed: () {
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => ImpulseInvadersScreen(
                                                  difficulty: widget.difficulty,
                                                  onGameComplete: widget.onGameComplete,
                                                ),
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFFFFED00),
                                            foregroundColor: Colors.black,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 24,
                                              vertical: 12,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        ElevatedButton.icon(
                                          icon: const Icon(Icons.home_rounded),
                                          label: const Text("Home"),
                                          onPressed: () => Navigator.pop(context),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.black.withOpacity(0.1),
                                            foregroundColor: Colors.black,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 24,
                                              vertical: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FallingItem {
  double x;
  double y;
  final bool isWantItem;
  final double speed;
  final String id;
  final String emoji;
  final String name;
  bool isBeingCaught = false;

  FallingItem({
    required this.x,
    required this.y,
    required this.isWantItem,
    required this.speed,
    required this.id,
    required this.emoji,
    required this.name,
  });
}
