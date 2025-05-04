import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import '../../theme/app_theme.dart';

// Game state providers
final gameStateProvider = StateNotifierProvider<GameStateNotifier, GameState>((ref) {
  return GameStateNotifier();
});

// Game state classes
class GameState {
  final double capital;
  final int currentRound;
  final List<Investment> investments;
  final List<InvestmentRound> rounds;
  final bool isGameOver;
  final int score;
  final Map<String, int> assetCounts;

  GameState({
    required this.capital,
    required this.currentRound,
    required this.investments,
    required this.rounds,
    required this.isGameOver,
    required this.score,
    required this.assetCounts,
  });

  GameState copyWith({
    double? capital,
    int? currentRound,
    List<Investment>? investments,
    List<InvestmentRound>? rounds,
    bool? isGameOver,
    int? score,
    Map<String, int>? assetCounts,
  }) {
    return GameState(
      capital: capital ?? this.capital,
      currentRound: currentRound ?? this.currentRound,
      investments: investments ?? this.investments,
      rounds: rounds ?? this.rounds,
      isGameOver: isGameOver ?? this.isGameOver,
      score: score ?? this.score,
      assetCounts: assetCounts ?? this.assetCounts,
    );
  }
}

class Investment {
  final String name;
  final String emoji;
  final double amount;
  final double returnRate;
  final String type;
  final int riskLevel;

  Investment({
    required this.name,
    required this.emoji,
    required this.amount,
    required this.returnRate,
    required this.type,
    required this.riskLevel,
  });
}

class InvestmentRound {
  final int roundNumber;
  final List<Investment> options;
  final List<Investment> selected;
  final double roundReturn;
  final String? marketEvent;

  InvestmentRound({
    required this.roundNumber,
    required this.options,
    required this.selected,
    required this.roundReturn,
    this.marketEvent,
  });
}

class GameStateNotifier extends StateNotifier<GameState> {
  GameStateNotifier()
      : super(GameState(
          capital: 100.0,
          currentRound: 1,
          investments: [],
          rounds: [
            InvestmentRound(
              roundNumber: 1,
              options: _initialInvestmentOptions(),
              selected: [],
              roundReturn: 0,
            ),
          ],
          isGameOver: false,
          score: 0,
          assetCounts: {},
        ));

  static List<Investment> _initialInvestmentOptions() {
    final random = Random();
    final options = [
      Investment(
        name: 'Safe Bond',
        emoji: '📈',
        amount: 20.0,
        returnRate: 2.0 + random.nextDouble() * 3,
        type: 'Bond',
        riskLevel: 1,
      ),
      Investment(
        name: 'Real Estate',
        emoji: '🏡',
        amount: 30.0,
        returnRate: 4.0 + random.nextDouble() * 6,
        type: 'Real Estate',
        riskLevel: 2,
      ),
      Investment(
        name: 'Tech Startup',
        emoji: '🚀',
        amount: 40.0,
        returnRate: -10.0 + random.nextDouble() * 30,
        type: 'Tech',
        riskLevel: 3,
      ),
      Investment(
        name: 'CryptoCoin',
        emoji: '🪙',
        amount: 50.0,
        returnRate: -30.0 + random.nextDouble() * 70,
        type: 'Crypto',
        riskLevel: 4,
      ),
      Investment(
        name: 'Index Fund',
        emoji: '💼',
        amount: 25.0,
        returnRate: 5.0 + random.nextDouble() * 5,
        type: 'Index',
        riskLevel: 2,
      ),
    ];
    options.shuffle();
    return options.take(3).toList();
  }

  void selectInvestment(Investment investment) {
    if (state.currentRound > 5) return;

    final currentRound = state.rounds.isEmpty ? null : state.rounds.last;
    if (currentRound != null && currentRound.selected.length >= 2) return;

    final newSelected = [...(currentRound?.selected ?? []), investment].cast<Investment>();
    final newRounds = [...state.rounds];

    if (currentRound == null) {
      newRounds.add(InvestmentRound(
        roundNumber: 1,
        options: _generateInvestmentOptions(),
        selected: newSelected,
        roundReturn: 0,
      ));
    } else {
      newRounds[newRounds.length - 1] = InvestmentRound(
        roundNumber: currentRound.roundNumber,
        options: currentRound.options,
        selected: newSelected,
        roundReturn: currentRound.roundReturn,
        marketEvent: currentRound.marketEvent,
      );
    }

    state = state.copyWith(rounds: newRounds);
  }

  void deselectInvestment(Investment investment) {
    if (state.rounds.isEmpty) return;

    final currentRound = state.rounds.last;
    final newSelected = currentRound.selected.where((i) => i != investment).toList().cast<Investment>();

    final newRounds = [...state.rounds];
    newRounds[newRounds.length - 1] = InvestmentRound(
      roundNumber: currentRound.roundNumber,
      options: currentRound.options,
      selected: newSelected,
      roundReturn: currentRound.roundReturn,
      marketEvent: currentRound.marketEvent,
    );

    state = state.copyWith(rounds: newRounds);
  }

  void completeRound() {
    if (state.rounds.isEmpty || state.rounds.last.selected.isEmpty) return;

    final currentRound = state.rounds.last;
    final roundReturn = _calculateRoundReturn(currentRound.selected);
    final marketEvent = _generateMarketEvent(currentRound.selected);

    final newRounds = [...state.rounds];
    newRounds[newRounds.length - 1] = InvestmentRound(
      roundNumber: currentRound.roundNumber,
      options: currentRound.options,
      selected: currentRound.selected,
      roundReturn: roundReturn,
      marketEvent: marketEvent,
    );

    final newCapital = state.capital + roundReturn;
    final newScore = _calculateScore(newCapital, newRounds);
    final newAssetCounts = _updateAssetCounts(currentRound.selected);

    state = state.copyWith(
      capital: newCapital,
      rounds: newRounds,
      score: newScore,
      assetCounts: newAssetCounts,
      isGameOver: state.currentRound >= 5,
    );

    if (state.currentRound < 5) {
      state = state.copyWith(
        currentRound: state.currentRound + 1,
        rounds: [
          ...newRounds,
          InvestmentRound(
            roundNumber: state.currentRound + 1,
            options: _generateInvestmentOptions(),
            selected: [],
            roundReturn: 0,
          )
        ],
      );
    }
  }

  List<Investment> _generateInvestmentOptions() {
    final random = Random();
    final options = [
      Investment(
        name: 'Safe Bond',
        emoji: '📈',
        amount: 20.0,
        returnRate: 2.0 + random.nextDouble() * 3,
        type: 'Bond',
        riskLevel: 1,
      ),
      Investment(
        name: 'Real Estate',
        emoji: '🏡',
        amount: 30.0,
        returnRate: 4.0 + random.nextDouble() * 6,
        type: 'Real Estate',
        riskLevel: 2,
      ),
      Investment(
        name: 'Tech Startup',
        emoji: '🚀',
        amount: 40.0,
        returnRate: -10.0 + random.nextDouble() * 30,
        type: 'Tech',
        riskLevel: 3,
      ),
      Investment(
        name: 'CryptoCoin',
        emoji: '🪙',
        amount: 50.0,
        returnRate: -30.0 + random.nextDouble() * 70,
        type: 'Crypto',
        riskLevel: 4,
      ),
      Investment(
        name: 'Index Fund',
        emoji: '💼',
        amount: 25.0,
        returnRate: 5.0 + random.nextDouble() * 5,
        type: 'Index',
        riskLevel: 2,
      ),
    ];
    options.shuffle();
    return options.take(3).toList();
  }

  double _calculateRoundReturn(List<Investment> investments) {
    double totalReturn = 0;
    final random = Random();

    // Market condition affects all investments
    double marketMultiplier = 1.0 + (random.nextDouble() * 0.4 - 0.2); // -20% to +20%

    for (var investment in investments) {
      // Base return calculation
      double baseReturn = investment.amount * (investment.returnRate / 100);

      // Risk-based volatility
      double volatility = investment.riskLevel * 0.1; // Higher risk = higher volatility
      double randomFactor = 1.0 + (random.nextDouble() * volatility * 2 - volatility);

      // Calculate final return with market conditions and volatility
      double finalReturn = baseReturn * marketMultiplier * randomFactor;

      // Add to total return
      totalReturn += finalReturn;
    }

    return double.parse(totalReturn.toStringAsFixed(2));
  }

  String? _generateMarketEvent(List<Investment> investments) {
    final random = Random();
    final events = [
      {'event': 'Market Crash! 📉', 'impact': -0.3},
      {'event': 'Bull Market! 📈', 'impact': 0.3},
      {'event': 'Interest Rates Rise 💹', 'impact': -0.1},
      {'event': 'Tech Boom! 🚀', 'impact': 0.2},
      {'event': 'Economic Recovery 📊', 'impact': 0.15},
      {'event': 'Global Recession 🌍', 'impact': -0.2},
      {'event': 'Crypto Surge ⚡', 'impact': 0.4},
      {'event': 'Real Estate Boom 🏘️', 'impact': 0.25},
    ];

    if (random.nextDouble() < 0.4) {
      // 40% chance of market event
      final event = events[random.nextInt(events.length)];
      return event['event'] as String;
    }
    return null;
  }

  int _calculateScore(double capital, List<InvestmentRound> rounds) {
    int score = 0;

    // Base score from capital growth
    double growthPercentage = ((capital - 100) / 100) * 100;
    if (growthPercentage >= 20) {
      score += 100;
    } else if (growthPercentage >= 10) {
      score += 75;
    } else if (growthPercentage >= 5) {
      score += 50;
    } else if (growthPercentage >= 0) {
      score += 25;
    }

    // Bonus for diversification
    final uniqueAssets = state.assetCounts.keys.length;
    score += uniqueAssets * 15;

    // Bonus for consistent positive returns
    int consecutivePositiveReturns = 0;
    int maxConsecutivePositiveReturns = 0;

    for (var round in rounds) {
      if (round.roundReturn > 0) {
        consecutivePositiveReturns++;
        maxConsecutivePositiveReturns = max(maxConsecutivePositiveReturns, consecutivePositiveReturns);
      } else {
        consecutivePositiveReturns = 0;
      }
    }

    score += maxConsecutivePositiveReturns * 10;

    // Risk management bonus
    int highRiskCount = 0;
    int lowRiskCount = 0;

    for (var round in rounds) {
      for (var investment in round.selected) {
        if (investment.riskLevel >= 3) {
          highRiskCount++;
        } else {
          lowRiskCount++;
        }
      }
    }

    // Balanced portfolio bonus
    if (highRiskCount > 0 && lowRiskCount > 0 && (highRiskCount / (highRiskCount + lowRiskCount)) <= 0.4) {
      score += 25; // Bonus for maintaining balanced risk
    }

    return score;
  }

  Map<String, int> _updateAssetCounts(List<Investment> investments) {
    final newCounts = Map<String, int>.from(state.assetCounts);
    for (var investment in investments) {
      newCounts[investment.type] = (newCounts[investment.type] ?? 0) + 1;
    }
    return newCounts;
  }
}

class InvestorIslandScreen extends ConsumerStatefulWidget {
  const InvestorIslandScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<InvestorIslandScreen> createState() => _InvestorIslandScreenState();
}

class _InvestorIslandScreenState extends ConsumerState<InvestorIslandScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late ConfettiController _confettiController;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  String? _feedbackMessage;
  Color _feedbackColor = Colors.green;
  String _mascotMood = '😃'; // 😃 happy, 😬 worried, 😢 sad
  bool _showRedFlash = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 16).chain(CurveTween(curve: Curves.elasticIn)).animate(_shakeController);
  }

  void _showRoundResult(InvestmentRound round) {
    final profit = round.roundReturn;
    setState(() {
      if (profit > 5) {
        _feedbackMessage = '🔥 Excellent Return! +€${profit.toStringAsFixed(2)}';
        _feedbackColor = Colors.green;
        _mascotMood = '🤑';
        _confettiController.play();
      } else if (profit > 0) {
        _feedbackMessage = '👍 Positive Return! +€${profit.toStringAsFixed(2)}';
        _feedbackColor = Colors.green;
        _mascotMood = '😃';
      } else if (profit > -5) {
        _feedbackMessage = '😬 Small Loss: €${profit.toStringAsFixed(2)}';
        _feedbackColor = Colors.orange;
        _mascotMood = '😅';
      } else {
        _feedbackMessage = '📉 Significant Loss: €${profit.toStringAsFixed(2)}';
        _feedbackColor = Colors.red;
        _mascotMood = '😢';
        _showRedFlash = true;
        _shakeController.forward(from: 0);
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) setState(() => _showRedFlash = false);
        });
      }
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(profit >= 0 ? '📈' : '📉', style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 8),
            Text('Year ${round.roundNumber} Results'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (round.marketEvent != null)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  round.marketEvent!,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).primaryColor,
                      ),
                ),
              ),
            const SizedBox(height: 16),
            Text(
              'Return: ${profit >= 0 ? '+' : ''}€${profit.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: profit >= 0 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            // ROI Percentage
            Text(
              'ROI: ${((profit / round.selected.fold(0.0, (sum, inv) => sum + inv.amount)) * 100).toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            // Investment Breakdown
            ...round.selected.map((investment) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${investment.emoji} ${investment.name}'),
                      Text('€${investment.amount.toStringAsFixed(2)}'),
                    ],
                  ),
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showGameOver() {
    final gameState = ref.read(gameStateProvider);
    final finalCapital = gameState.capital;
    final uniqueAssets = gameState.assetCounts.keys.length;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Stack(
        children: [
          AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🏆', style: TextStyle(fontSize: 32)),
                const SizedBox(width: 8),
                const Text('Game Over!'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Final Portfolio Value: €${finalCapital.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Text('Unique Assets: $uniqueAssets'),
                Text('Score: ${gameState.score}'),
                const SizedBox(height: 16),
                _getPerformanceGrade(finalCapital),
                if (uniqueAssets >= 3)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      '🏅 Diverse Investor Badge Unlocked!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
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
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    ref.read(gameStateProvider.notifier).state = GameState(
                      capital: 100.0,
                      currentRound: 1,
                      investments: [],
                      rounds: [],
                      isGameOver: false,
                      score: 0,
                      assetCounts: {},
                    );
                  });
                },
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
    _confettiController.play();
  }

  Widget _getPerformanceGrade(double finalCapital) {
    final growthPercentage = ((finalCapital - 100) / 100) * 100;

    if (growthPercentage >= 20) {
      return const Text(
        '🌟 Master Investor\nExceptional returns!',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.green,
        ),
        textAlign: TextAlign.center,
      );
    } else if (growthPercentage >= 10) {
      return const Text(
        '🏆 Expert Investor\nStrong performance!',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.green,
        ),
        textAlign: TextAlign.center,
      );
    } else if (growthPercentage >= 5) {
      return const Text(
        '👍 Smart Investor\nSolid returns!',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
        textAlign: TextAlign.center,
      );
    } else if (growthPercentage >= 0) {
      return const Text(
        '😊 Cautious Investor\nPreserved capital',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.orange,
        ),
        textAlign: TextAlign.center,
      );
    } else {
      return const Text(
        '📉 Learning Investor\nKeep practicing!',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.red,
        ),
        textAlign: TextAlign.center,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);
    final currentRound = gameState.rounds.isEmpty ? null : gameState.rounds.last;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Investor Island'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Stack(
        children: [
          // Animated Tropical Background
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(seconds: 1),
              color: Colors.lightBlue[100],
              child: Stack(
                children: [
                  // Ocean
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: AnimatedContainer(
                      duration: const Duration(seconds: 1),
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.blue[300],
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(60)),
                      ),
                    ),
                  ),
                  // Sun
                  Positioned(
                    top: 40,
                    left: 40,
                    child: AnimatedContainer(
                      duration: const Duration(seconds: 1),
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.yellow,
                      ),
                    ),
                  ),
                  // Clouds
                  Positioned(
                    top: 80,
                    right: 60,
                    child: Icon(Icons.cloud, size: 48, color: Colors.white.withOpacity(0.7)),
                  ),
                  Positioned(
                    top: 120,
                    left: 120,
                    child: Icon(Icons.cloud, size: 36, color: Colors.white.withOpacity(0.5)),
                  ),
                ],
              ),
            ),
          ),
          // Red flash overlay on loss
          if (_showRedFlash)
            Positioned.fill(
              child: Container(
                color: Colors.red.withOpacity(0.3),
              ),
            ),
          // Main content with shake animation
          AnimatedBuilder(
            animation: _shakeController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_showRedFlash ? _shakeAnimation.value * (Random().nextBool() ? 1 : -1) : 0, 0),
                child: child,
              );
            },
            child: Column(
              children: [
                // Progress and Capital
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Capital: €${gameState.capital.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        'Year ${gameState.currentRound}/5',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
                // Mascot
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 4),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: Text(
                      _mascotMood,
                      key: ValueKey(_mascotMood),
                      style: const TextStyle(fontSize: 48),
                    ),
                  ),
                ),
                // Feedback banner
                if (_feedbackMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      decoration: BoxDecoration(
                        color: _feedbackColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _feedbackColor, width: 1),
                      ),
                      child: Text(
                        _feedbackMessage!,
                        style: TextStyle(
                          color: _feedbackColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                // Progress Bar
                LinearProgressIndicator(
                  value: gameState.currentRound / 5,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                  minHeight: 8,
                ),
                // Investment Options
                Expanded(
                  child: currentRound == null
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: currentRound.options.length,
                          itemBuilder: (context, index) {
                            final investment = currentRound.options[index];
                            final isSelected = currentRound.selected.contains(investment);
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              margin: const EdgeInsets.only(bottom: 16),
                              child: GestureDetector(
                                onTap: () {
                                  if (isSelected) {
                                    ref.read(gameStateProvider.notifier).deselectInvestment(investment);
                                  } else if (currentRound.selected.length < 2) {
                                    ref.read(gameStateProvider.notifier).selectInvestment(investment);
                                  }
                                },
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: Card(
                                    elevation: isSelected ? 8 : 2,
                                    color: isSelected ? Colors.green[50] : Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                investment.emoji,
                                                style: const TextStyle(fontSize: 32),
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      investment.name,
                                                      style: Theme.of(context).textTheme.titleLarge,
                                                    ),
                                                    Text(
                                                      'Risk Level: ${'⭐' * investment.riskLevel}',
                                                      style: Theme.of(context).textTheme.bodyMedium,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              if (isSelected)
                                                const Icon(
                                                  Icons.check_circle,
                                                  color: Colors.green,
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          LinearProgressIndicator(
                                            value: investment.riskLevel / 4,
                                            backgroundColor: Colors.grey[200],
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              investment.riskLevel <= 2
                                                  ? Colors.green
                                                  : investment.riskLevel == 3
                                                      ? Colors.orange
                                                      : Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
                // Action Button
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: currentRound?.selected.isNotEmpty == true
                        ? () {
                            ref.read(gameStateProvider.notifier).completeRound();
                            if (currentRound != null) {
                              _showRoundResult(currentRound);
                            }
                            if (gameState.isGameOver) {
                              _showGameOver();
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text('Lock Investments'),
                  ),
                ),
              ],
            ),
          ),
          // Confetti for profit
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2,
              maxBlastForce: 5,
              minBlastForce: 2,
              emissionFrequency: 0.05,
              numberOfParticles: 30,
              gravity: 0.1,
              colors: const [
                Colors.green,
                Colors.yellow,
                Colors.orange,
                Colors.purple,
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _confettiController.dispose();
    _shakeController.dispose();
    super.dispose();
  }
}
