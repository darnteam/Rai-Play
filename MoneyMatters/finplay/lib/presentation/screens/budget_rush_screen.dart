import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import '../theme/app_theme.dart';

// Game state providers
final gameStateProvider = StateNotifierProvider<GameStateNotifier, GameState>((ref) {
  return GameStateNotifier();
});

final timerProvider = StateNotifierProvider<TimerNotifier, int>((ref) {
  return TimerNotifier();
});

// Game difficulty levels
enum Difficulty { easy, medium, hard, expert }

// Power-up types
enum PowerUpType { timeSlow, budgetBoost, scoreMultiplier, secondChance }

class PowerUp {
  final PowerUpType type;
  final String name;
  final String description;
  final String icon;
  final Duration duration;
  final double value;

  PowerUp({
    required this.type,
    required this.name,
    required this.description,
    required this.icon,
    required this.duration,
    required this.value,
  });
}

class Achievement {
  final String id;
  final String name;
  final String description;
  final String icon;
  final bool isUnlocked;
  final int requiredScore;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.isUnlocked,
    required this.requiredScore,
  });
}

// Game state classes
class GameState {
  final double budget;
  final List<Purchase> purchases;
  final bool isGameOver;
  final int score;
  final Difficulty difficulty;
  final List<PowerUp> activePowerUps;
  final List<Achievement> achievements;
  final int combo;
  final int highScore;

  GameState({
    required this.budget,
    required this.purchases,
    required this.isGameOver,
    required this.score,
    required this.difficulty,
    required this.activePowerUps,
    required this.achievements,
    required this.combo,
    required this.highScore,
  });

  GameState copyWith({
    double? budget,
    List<Purchase>? purchases,
    bool? isGameOver,
    int? score,
    Difficulty? difficulty,
    List<PowerUp>? activePowerUps,
    List<Achievement>? achievements,
    int? combo,
    int? highScore,
  }) {
    return GameState(
      budget: budget ?? this.budget,
      purchases: purchases ?? this.purchases,
      isGameOver: isGameOver ?? this.isGameOver,
      score: score ?? this.score,
      difficulty: difficulty ?? this.difficulty,
      activePowerUps: activePowerUps ?? this.activePowerUps,
      achievements: achievements ?? this.achievements,
      combo: combo ?? this.combo,
      highScore: highScore ?? this.highScore,
    );
  }
}

class Purchase {
  final String name;
  final double price;
  final bool isNeed;
  final DateTime timestamp;

  Purchase({
    required this.name,
    required this.price,
    required this.isNeed,
    required this.timestamp,
  });
}

class GameStateNotifier extends StateNotifier<GameState> {
  GameStateNotifier()
      : super(GameState(
          budget: 50.0,
          purchases: [],
          isGameOver: false,
          score: 0,
          difficulty: Difficulty.easy,
          activePowerUps: [],
          achievements: _initializeAchievements(),
          combo: 0,
          highScore: 0,
        ));

  static List<Achievement> _initializeAchievements() {
    return [
      Achievement(
        id: 'budget_master',
        name: 'Budget Master',
        description: 'Score 100 points in a single game',
        icon: '🏆',
        isUnlocked: false,
        requiredScore: 100,
      ),
      Achievement(
        id: 'combo_king',
        name: 'Combo King',
        description: 'Get a 5x combo',
        icon: '👑',
        isUnlocked: false,
        requiredScore: 50,
      ),
      Achievement(
        id: 'speed_demon',
        name: 'Speed Demon',
        description: 'Complete a game in under 30 seconds',
        icon: '⚡',
        isUnlocked: false,
        requiredScore: 75,
      ),
      Achievement(
        id: 'perfect_balance',
        name: 'Perfect Balance',
        description: 'End with exactly 0 budget',
        icon: '⚖️',
        isUnlocked: false,
        requiredScore: 150,
      ),
    ];
  }

  void setDifficulty(Difficulty difficulty) {
    state = state.copyWith(
      difficulty: difficulty,
      budget: _getInitialBudget(difficulty),
    );
  }

  double _getInitialBudget(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return 50.0;
      case Difficulty.medium:
        return 40.0;
      case Difficulty.hard:
        return 30.0;
      case Difficulty.expert:
        return 20.0;
    }
  }

  void activatePowerUp(PowerUp powerUp) {
    final newPowerUps = [...state.activePowerUps, powerUp];
    state = state.copyWith(activePowerUps: newPowerUps);

    // Remove power-up after duration
    Future.delayed(powerUp.duration, () {
      if (!state.isGameOver) {
        final updatedPowerUps = state.activePowerUps.where((p) => p != powerUp).toList();
        state = state.copyWith(activePowerUps: updatedPowerUps);
      }
    });
  }

  void makePurchase(Purchase purchase) {
    if (state.budget >= purchase.price) {
      final newBudget = state.budget - purchase.price;
      final newPurchases = [...state.purchases, purchase];

      // Calculate combo
      int newCombo = purchase.isNeed ? state.combo + 1 : 0;

      // Calculate score with power-ups and combo
      final baseScore = _calculateBaseScore(purchase, newBudget);
      final finalScore = _applyPowerUps(baseScore);
      final newScore = state.score + finalScore;

      // Check for achievements
      final newAchievements = _checkAchievements(newScore, newCombo, newBudget);

      state = state.copyWith(
        budget: newBudget,
        purchases: newPurchases,
        score: newScore,
        combo: newCombo,
        achievements: newAchievements,
        isGameOver: newBudget <= 0,
        highScore: newScore > state.highScore ? newScore : state.highScore,
      );
    }
  }

  int _calculateBaseScore(Purchase purchase, double remainingBudget) {
    int score = 0;

    // Base score from purchase type
    if (purchase.isNeed) {
      score += 10;
      // Combo bonus
      score += (state.combo * 2);
    } else {
      score -= 5;
    }

    // Difficulty bonus
    switch (state.difficulty) {
      case Difficulty.easy:
        score = (score * 1.0).round();
        break;
      case Difficulty.medium:
        score = (score * 1.5).round();
        break;
      case Difficulty.hard:
        score = (score * 2.0).round();
        break;
      case Difficulty.expert:
        score = (score * 3.0).round();
        break;
    }

    // Budget efficiency bonus
    if (remainingBudget > 0 && remainingBudget <= 5) {
      score += 20;
    }

    return score;
  }

  int _applyPowerUps(int baseScore) {
    int finalScore = baseScore;

    for (var powerUp in state.activePowerUps) {
      if (powerUp.type == PowerUpType.scoreMultiplier) {
        finalScore = (finalScore * powerUp.value).round();
      }
    }

    return finalScore;
  }

  List<Achievement> _checkAchievements(int newScore, int combo, double budget) {
    final achievements = [...state.achievements];

    // Check each achievement condition
    for (int i = 0; i < achievements.length; i++) {
      if (!achievements[i].isUnlocked) {
        bool shouldUnlock = false;

        switch (achievements[i].id) {
          case 'budget_master':
            shouldUnlock = newScore >= 100;
            break;
          case 'combo_king':
            shouldUnlock = combo >= 5;
            break;
          case 'perfect_balance':
            shouldUnlock = budget == 0;
            break;
        }

        if (shouldUnlock) {
          achievements[i] = Achievement(
            id: achievements[i].id,
            name: achievements[i].name,
            description: achievements[i].description,
            icon: achievements[i].icon,
            isUnlocked: true,
            requiredScore: achievements[i].requiredScore,
          );
        }
      }
    }

    return achievements;
  }

  void skipPurchase(Purchase purchase) {
    // Penalize skipping needs
    if (purchase.isNeed) {
      state = state.copyWith(
        score: state.score - 5,
      );
    }
  }

  void endGame() {
    state = state.copyWith(isGameOver: true);
  }
}

class TimerNotifier extends StateNotifier<int> {
  TimerNotifier() : super(60);

  void tick() {
    if (state > 0) {
      state--;
    }
  }

  void reset() {
    state = 60;
  }
}

// Shopping items database
final List<Map<String, dynamic>> _shoppingItems = [
  {'name': 'Lunch Wrap', 'price': 5.0, 'isNeed': true, 'emoji': '🍔', 'category': 'Food', 'effect': 'Restores energy'},
  {'name': 'Bus Fare', 'price': 3.0, 'isNeed': true, 'emoji': '🚌', 'category': 'Transport', 'effect': 'Essential travel'},
  {'name': 'New T-shirt', 'price': 15.0, 'isNeed': false, 'emoji': '👕', 'category': 'Clothing', 'effect': 'Style boost'},
  {'name': 'School Supplies', 'price': 8.0, 'isNeed': true, 'emoji': '📚', 'category': 'Education', 'effect': 'Learning boost'},
  {'name': 'Movie Ticket', 'price': 12.0, 'isNeed': false, 'emoji': '🎬', 'category': 'Entertainment', 'effect': 'Fun boost'},
  {'name': 'Snacks', 'price': 4.0, 'isNeed': false, 'emoji': '🍿', 'category': 'Food', 'effect': 'Small happiness boost'},
  {'name': 'Phone Credit', 'price': 10.0, 'isNeed': true, 'emoji': '📱', 'category': 'Communication', 'effect': 'Connectivity boost'},
  {'name': 'New Game', 'price': 25.0, 'isNeed': false, 'emoji': '🎮', 'category': 'Entertainment', 'effect': 'Major fun boost'},
  {'name': 'Gym Membership', 'price': 20.0, 'isNeed': true, 'emoji': '💪', 'category': 'Health', 'effect': 'Health boost'},
  {'name': 'Concert Tickets', 'price': 30.0, 'isNeed': false, 'emoji': '🎵', 'category': 'Entertainment', 'effect': 'Major happiness boost'},
];

class BudgetRushScreen extends ConsumerStatefulWidget {
  const BudgetRushScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<BudgetRushScreen> createState() => _BudgetRushScreenState();
}

class _BudgetRushScreenState extends ConsumerState<BudgetRushScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late ConfettiController _confettiController;
  Map<String, dynamic>? _currentItem;
  bool _isItemVisible = false;
  bool _showTutorial = true;
  int _tutorialStep = 0;

  // Power-ups available in the game
  final List<PowerUp> _availablePowerUps = [
    PowerUp(
      type: PowerUpType.timeSlow,
      name: 'Time Freeze',
      description: 'Slows down time for 10 seconds',
      icon: '⏰',
      duration: const Duration(seconds: 10),
      value: 0.5,
    ),
    PowerUp(
      type: PowerUpType.budgetBoost,
      name: 'Budget Boost',
      description: 'Adds 10% to your budget',
      icon: '💰',
      duration: const Duration(seconds: 15),
      value: 1.1,
    ),
    PowerUp(
      type: PowerUpType.scoreMultiplier,
      name: 'Score Multiplier',
      description: '2x score for 15 seconds',
      icon: '✨',
      duration: const Duration(seconds: 15),
      value: 2.0,
    ),
    PowerUp(
      type: PowerUpType.secondChance,
      name: 'Second Chance',
      description: 'One free mistake',
      icon: '🎯',
      duration: const Duration(seconds: 30),
      value: 1.0,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 0.3, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _startGame();
  }

  void _startGame() {
    ref.read(timerProvider.notifier).reset();
    _showNextItem();
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      ref.read(timerProvider.notifier).tick();
      if (ref.read(timerProvider) > 0) {
        _startTimer();
      } else {
        _endGame();
      }
    });
  }

  void _showNextItem() {
    setState(() {
      _isItemVisible = false;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() {
        _currentItem = _shoppingItems[Random().nextInt(_shoppingItems.length)];
        _isItemVisible = true;
      });
      _controller.forward(from: 0);
    });
  }

  void _handlePurchase() {
    if (_currentItem != null) {
      final gameState = ref.read(gameStateProvider);
      if (gameState.budget >= _currentItem!['price']) {
        final purchase = Purchase(
          name: _currentItem!['name'],
          price: _currentItem!['price'],
          isNeed: _currentItem!['isNeed'],
          timestamp: DateTime.now(),
        );
        ref.read(gameStateProvider.notifier).makePurchase(purchase);

        // Check if game should end after purchase
        final newGameState = ref.read(gameStateProvider);
        if (newGameState.isGameOver) {
          _endGame();
        } else {
          _showNextItem();
        }
      } else {
        // Show message that budget is too low
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Not enough budget for this item!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _handleSkip() {
    if (_currentItem != null) {
      final purchase = Purchase(
        name: _currentItem!['name'],
        price: _currentItem!['price'],
        isNeed: _currentItem!['isNeed'],
        timestamp: DateTime.now(),
      );
      ref.read(gameStateProvider.notifier).skipPurchase(purchase);
      _showNextItem();
    }
  }

  void _endGame() {
    ref.read(gameStateProvider.notifier).endGame();
    _confettiController.play();
    _showEndGameDialog();
  }

  void _showEndGameDialog() {
    final gameState = ref.read(gameStateProvider);
    final needsCount = gameState.purchases.where((p) => p.isNeed).length;
    final wantsCount = gameState.purchases.where((p) => !p.isNeed).length;
    final needsPercentage = gameState.purchases.isEmpty ? 0 : (needsCount / gameState.purchases.length * 100).round();

    // Check for newly unlocked achievements
    final newAchievements = gameState.achievements.where((a) => a.isUnlocked).toList();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Stack(
        children: [
          AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🎉', style: TextStyle(fontSize: 32)),
                const SizedBox(width: 8),
                const Text('Game Over!'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Score section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Score: ${gameState.score}',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (gameState.score > gameState.highScore)
                        const Text(
                          'New High Score! 🏆',
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Stats grid
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatBox('Needs', needsCount, Colors.green),
                    _buildStatBox('Wants', wantsCount, Colors.orange),
                    _buildStatBox(
                      'Budget Left',
                      null,
                      Theme.of(context).primaryColor,
                      value: '€${gameState.budget.toStringAsFixed(2)}',
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Achievements section
                if (newAchievements.isNotEmpty) ...[
                  const Text(
                    'Achievements Unlocked! 🌟',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...newAchievements.map((achievement) => ListTile(
                        leading: Text(achievement.icon, style: const TextStyle(fontSize: 24)),
                        title: Text(achievement.name),
                        subtitle: Text(achievement.description),
                      )),
                  const SizedBox(height: 16),
                ],

                // Feedback message
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: needsPercentage >= 70 ? Colors.green[50] : Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: needsPercentage >= 70 ? Colors.green : Colors.orange,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _getFeedbackMessage(needsPercentage, gameState.budget),
                        style: TextStyle(
                          color: needsPercentage >= 70 ? Colors.green[700] : Colors.orange[700],
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getFeedbackTip(needsPercentage, gameState.budget),
                        style: TextStyle(
                          color: needsPercentage >= 70 ? Colors.green[600] : Colors.orange[600],
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('Exit'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _startGame();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                child: const Text('Play Again'),
              ),
            ],
          ),
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
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String label, int? count, Color color, {String? value}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value ?? count.toString(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  String _getFeedbackMessage(int needsPercentage, double remainingBudget) {
    if (needsPercentage >= 70 && remainingBudget > 5) {
      return 'Budget Master! 🏆\nYou made excellent choices!';
    } else if (needsPercentage >= 50) {
      return 'Good Balance! 🌟\nYou\'re getting better at this!';
    } else {
      return 'Keep Learning! 📚\nFocus on your needs first!';
    }
  }

  String _getFeedbackTip(int needsPercentage, double remainingBudget) {
    if (needsPercentage >= 70 && remainingBudget > 5) {
      return 'Tip: Try a harder difficulty for more challenges!';
    } else if (needsPercentage >= 50) {
      return 'Tip: Build longer combos by choosing needs consecutively!';
    } else {
      return 'Tip: Remember the 50/30/20 rule - Needs/Wants/Savings!';
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);
    final timeLeft = ref.watch(timerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Background with animated gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.primaryColor.withOpacity(0.1),
                  theme.primaryColor.withOpacity(0.05),
                ],
              ),
            ),
          ),

          // Main game content
          SafeArea(
            child: Column(
              children: [
                // Game header with stats
                _buildGameHeader(gameState, timeLeft, theme),

                // Power-ups row
                if (!_showTutorial) _buildPowerUpsRow(gameState),

                // Main game area
                Expanded(
                  child: _showTutorial
                      ? Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _getTutorialText(),
                                style: Theme.of(context).textTheme.headlineSmall,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 32),
                              ElevatedButton(
                                onPressed: _nextTutorialStep,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.primaryColor,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: Text(
                                  _tutorialStep < 3 ? 'Next' : 'Start Game',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : _buildGameArea(gameState),
                ),

                // Action buttons
                if (!_showTutorial) _buildActionButtons(),
              ],
            ),
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
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameHeader(GameState gameState, int timeLeft, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Budget display
              _buildStatCard(
                'Budget',
                '€${gameState.budget.toStringAsFixed(2)}',
                Icons.account_balance_wallet,
                theme.primaryColor,
              ),

              // Score display
              _buildStatCard(
                'Score',
                gameState.score.toString(),
                Icons.stars,
                Colors.amber,
              ),

              // Time display
              _buildStatCard(
                'Time',
                timeLeft.toString(),
                Icons.timer,
                Colors.red,
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Combo indicator
          if (gameState.combo > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.purple,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.flash_on, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${gameState.combo}x Combo!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 8),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: timeLeft / 60,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                timeLeft > 10 ? theme.primaryColor : Colors.red,
              ),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPowerUpsRow(GameState gameState) {
    return Container(
      height: 85,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _availablePowerUps.length,
        itemBuilder: (context, index) {
          final powerUp = _availablePowerUps[index];
          final isActive = gameState.activePowerUps.contains(powerUp);

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: isActive ? null : () => _activatePowerUp(powerUp),
              child: Container(
                width: 60,
                decoration: BoxDecoration(
                  color: isActive ? Theme.of(context).primaryColor : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: isActive ? Theme.of(context).primaryColor.withOpacity(0.3) : Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      powerUp.icon,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      powerUp.name,
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGameArea(GameState gameState) {
    return Center(
      child: _currentItem != null && _isItemVisible
          ? AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _slideAnimation.value * 100),
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: _buildItemCard(),
                  ),
                );
              },
            )
          : const SizedBox(),
    );
  }

  Widget _buildItemCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Item emoji with animated background
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _currentItem!['isNeed'] ? Colors.green[50] : Colors.orange[50],
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (_currentItem!['isNeed'] ? Colors.green : Colors.orange).withOpacity(0.2),
                    blurRadius: 12,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _currentItem!['emoji'],
                  style: const TextStyle(fontSize: 40),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Item name
            Text(
              _currentItem!['name'],
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Price
            Text(
              '€${_currentItem!['price'].toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),

            // Category and effect
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _currentItem!['isNeed'] ? Colors.green[100] : Colors.orange[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _currentItem!['isNeed'] ? 'Need' : 'Want',
                    style: TextStyle(
                      color: _currentItem!['isNeed'] ? Colors.green[800] : Colors.orange[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _currentItem!['category'],
                    style: TextStyle(
                      color: Colors.blue[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Effect
            Text(
              _currentItem!['effect'],
              style: TextStyle(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            onPressed: _handleSkip,
            icon: Icons.close,
            label: 'Skip',
            color: Colors.red,
          ),
          _buildActionButton(
            onPressed: _handlePurchase,
            icon: Icons.check,
            label: 'Buy',
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: 32,
          vertical: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 4,
      ),
      icon: Icon(icon),
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _activatePowerUp(PowerUp powerUp) {
    ref.read(gameStateProvider.notifier).activatePowerUp(powerUp);

    // Visual feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text(powerUp.icon),
            const SizedBox(width: 8),
            Text('${powerUp.name} activated!'),
          ],
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  String _getTutorialText() {
    switch (_tutorialStep) {
      case 0:
        return 'Welcome to Budget Rush! 🎮\nLearn to manage your money wisely.';
      case 1:
        return 'Swipe RIGHT to buy items you need,\nLEFT to skip items you don\'t need.';
      case 2:
        return 'Build combos by making smart choices!\nPower-ups will help you score higher.';
      case 3:
        return 'Ready to start? Let\'s go! 🚀';
      default:
        return '';
    }
  }

  void _nextTutorialStep() {
    if (_tutorialStep < 3) {
      setState(() {
        _tutorialStep++;
      });
    } else {
      setState(() {
        _showTutorial = false;
      });
      _startGame();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _confettiController.dispose();
    super.dispose();
  }
}
