import 'package:flutter/material.dart';
import 'dart:async';
import 'package:lottie/lottie.dart';
import '../widgets/draggable_item.dart';
import '../widgets/budgeting_screen.dart';
import '../widgets/planning_screen.dart';
import '../widgets/customer_serving.dart';
import '../widgets/summary_screen.dart';
import '../screens/quest_map_screen.dart';

enum ItemCategory { needs, wants }

class GameItem {
  final String name;
  final double cost;
  final ItemCategory category;
  final String icon;
  final int stock;
  final String description;

  const GameItem({
    required this.name,
    required this.cost,
    required this.category,
    required this.icon,
    required this.stock,
    required this.description,
  });
}

class Location {
  final String name;
  final double footTraffic;
  final double risk;
  final String icon;

  const Location({
    required this.name,
    required this.footTraffic,
    required this.risk,
    required this.icon,
  });
}

class LemonadeBudgetGame extends StatefulWidget {
  const LemonadeBudgetGame({Key? key}) : super(key: key);

  @override
  State<LemonadeBudgetGame> createState() => _LemonadeBudgetGameState();
}

class _LemonadeBudgetGameState extends State<LemonadeBudgetGame> with SingleTickerProviderStateMixin {
  // Game state
  int _currentScreen = 0;
  double _budget = 20.0;
  double _spent = 0.0;
  double _saved = 0.0;
  int _customersServed = 0;
  double _profit = 0.0;
  int _xp = 0;
  int _coins = 0;
  bool _showIntro = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Quest tracking
  int _currentQuest = 0;
  final List<Map<String, dynamic>> _quests = [
    {
      'title': 'First Steps',
      'description': 'Complete your first lemonade stand setup',
      'isCompleted': false,
      'isUnlocked': true,
      'requirements': {
        'customersServed': 20,
        'profit': 20.0,
      },
    },
    {
      'title': 'Growing Business',
      'description': 'Serve 50 customers and make a profit of \$50',
      'isCompleted': false,
      'isUnlocked': false,
      'requirements': {
        'customersServed': 50,
        'profit': 50.0,
      },
    },
    {
      'title': 'Business Expert',
      'description': 'Serve 100 customers and make a profit of \$100',
      'isCompleted': false,
      'isUnlocked': false,
      'requirements': {
        'customersServed': 100,
        'profit': 100.0,
      },
    },
  ];

  // Game settings
  double _pricePerCup = 1.0;
  Location? _selectedLocation;

  // Inventory tracking
  Map<String, int> _stock = {
    'Lemons': 0,
    'Sugar': 0,
    'Cups': 0,
  };

  Map<String, bool> _upgrades = {
    'Sign': false,
    'Music': false,
    'Umbrella': false,
  };

  // Game items
  final List<GameItem> _items = [
    GameItem(
      name: 'Lemons',
      cost: 3.0,
      category: ItemCategory.needs,
      icon: '🍋',
      stock: 10,
      description: 'Essential for making lemonade',
    ),
    GameItem(
      name: 'Sugar',
      cost: 2.0,
      category: ItemCategory.needs,
      icon: '🍬',
      stock: 20,
      description: 'Makes the lemonade sweet',
    ),
    GameItem(
      name: 'Basic Cups',
      cost: 1.0,
      category: ItemCategory.needs,
      icon: '🥤',
      stock: 30,
      description: 'For serving lemonade',
    ),
    GameItem(
      name: 'Sign',
      cost: 2.0,
      category: ItemCategory.wants,
      icon: '📝',
      stock: 1,
      description: 'Attracts more customers',
    ),
    GameItem(
      name: 'Balloons',
      cost: 1.5,
      category: ItemCategory.wants,
      icon: '🎈',
      stock: 5,
      description: 'Makes the stand more attractive',
    ),
    GameItem(
      name: 'Music',
      cost: 2.0,
      category: ItemCategory.wants,
      icon: '🎵',
      stock: 1,
      description: 'Creates a fun atmosphere',
    ),
    GameItem(
      name: 'Fancy Cups',
      cost: 3.0,
      category: ItemCategory.wants,
      icon: '🥤',
      stock: 15,
      description: 'Customers pay more for fancy cups',
    ),
  ];

  // Location options
  final List<Location> _locations = [
    Location(name: 'School', footTraffic: 0.8, risk: 0.3, icon: '🏫'),
    Location(name: 'Park', footTraffic: 0.6, risk: 0.2, icon: '🌳'),
    Location(name: 'Market', footTraffic: 1.0, risk: 0.5, icon: '🏪'),
  ];

  // Game screens
  final List<String> _screens = [
    'Intro',
    'Budgeting',
    'Planning',
    'Sales',
    'Summary',
  ];

  // Location-based customer settings
  final Map<String, Map<String, dynamic>> _locationSettings = {
    'School': {
      'baseCustomers': 30,
      'priceSensitivity': 0.8,
      'maxPrice': 2.0,
    },
    'Park': {
      'baseCustomers': 20,
      'priceSensitivity': 0.6,
      'maxPrice': 3.0,
    },
    'Market': {
      'baseCustomers': 40,
      'priceSensitivity': 0.4,
      'maxPrice': 4.0,
    },
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);

    // Start intro animation
    Future.delayed(const Duration(milliseconds: 500), () {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _nextScreen() {
    setState(() {
      _currentScreen++;
      _animationController.reset();
      _animationController.forward();

      // Show feedback when moving from customer serving to summary
      if (_currentScreen == 4) {
        _showFeedbackDialog();
      }
    });
  }

  void _previousScreen() {
    setState(() {
      _currentScreen--;
      _animationController.reset();
      _animationController.forward();
    });
  }

  void _handleItemSelected(GameItem item) {
    setState(() {
      if (_spent + item.cost <= _budget) {
        _spent += item.cost;
        _saved = _budget - _spent;
        _stock[item.name] = (item.stock);
        if (item.category == ItemCategory.wants) {
          _upgrades[item.name] = true;
        }
      }
    });
  }

  void _handleItemDeselected(GameItem item) {
    setState(() {
      _spent -= item.cost;
      _saved = _budget - _spent;
      _stock[item.name] = 0;
      if (item.category == ItemCategory.wants) {
        _upgrades[item.name] = false;
      }
    });
  }

  void _handleLocationSelected(Location location) {
    setState(() {
      _selectedLocation = location;
    });
  }

  void _handlePriceSet(double price) {
    setState(() {
      _pricePerCup = price;
    });
  }

  void _checkQuestCompletion() {
    if (_currentQuest < _quests.length) {
      final quest = _quests[_currentQuest];
      final requirements = quest['requirements'] as Map<String, dynamic>;

      if (!quest['isCompleted'] && _customersServed >= requirements['customersServed'] && _profit >= requirements['profit']) {
        setState(() {
          _quests[_currentQuest]['isCompleted'] = true;

          // Unlock next quest if available
          if (_currentQuest + 1 < _quests.length) {
            _quests[_currentQuest + 1]['isUnlocked'] = true;
          }

          // Show completion dialog
          _showQuestCompletionDialog();
        });
      }
    }
  }

  void _showQuestCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Quest Completed! 🎉'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _quests[_currentQuest]['title'],
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(_quests[_currentQuest]['description']),
            const SizedBox(height: 16),
            if (_currentQuest + 1 < _quests.length) ...[
              const Text(
                'New Quest Unlocked:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(_quests[_currentQuest + 1]['title']),
              Text(_quests[_currentQuest + 1]['description']),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (_currentQuest + 1 < _quests.length) {
                setState(() {
                  _currentQuest++;
                });
              }
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  int _calculateCustomerCount() {
    if (_selectedLocation == null) return 0;

    final settings = _locationSettings[_selectedLocation!.name]!;
    final baseCustomers = settings['baseCustomers'] as int;
    final priceSensitivity = settings['priceSensitivity'] as double;
    final maxPrice = settings['maxPrice'] as double;

    // Calculate price impact
    double priceImpact = 1.0;
    if (_pricePerCup > maxPrice) {
      priceImpact = 0.3; // Significant reduction for prices above max
    } else if (_pricePerCup > maxPrice * 0.8) {
      priceImpact = 0.6; // Moderate reduction for high prices
    } else if (_pricePerCup > maxPrice * 0.5) {
      priceImpact = 0.8; // Slight reduction for medium prices
    }

    // Apply upgrades impact
    double upgradeMultiplier = 1.0;
    if (_upgrades['Sign'] == true) upgradeMultiplier += 0.2;
    if (_upgrades['Music'] == true) upgradeMultiplier += 0.1;
    if (_upgrades['Umbrella'] == true) upgradeMultiplier += 0.15;

    return (baseCustomers * priceImpact * upgradeMultiplier).round();
  }

  void _showFeedbackDialog() {
    final expectedCustomers = _calculateCustomerCount();
    final actualCustomers = _customersServed;
    final expectedProfit = expectedCustomers * _pricePerCup;
    final actualProfit = _profit;

    // Calculate location impact
    final locationSettings = _locationSettings[_selectedLocation!.name]!;
    final baseCustomers = locationSettings['baseCustomers'] as int;
    final maxPrice = locationSettings['maxPrice'] as double;

    // Calculate price impact
    double priceImpact = 1.0;
    String priceFeedback = '';
    if (_pricePerCup > maxPrice) {
      priceImpact = 0.3;
      priceFeedback = 'Your price is too high for this location. Customers are very price-sensitive here.';
    } else if (_pricePerCup > maxPrice * 0.8) {
      priceImpact = 0.6;
      priceFeedback = 'Your price is a bit high for this location. Consider lowering it to attract more customers.';
    } else if (_pricePerCup > maxPrice * 0.5) {
      priceImpact = 0.8;
      priceFeedback = 'Your price is reasonable, but you could attract more customers by lowering it slightly.';
    } else {
      priceFeedback = 'Your price is competitive for this location. Good choice!';
    }

    // Calculate upgrade impact
    double upgradeMultiplier = 1.0;
    List<String> upgradeFeedback = [];
    if (_upgrades['Sign'] == true) {
      upgradeMultiplier += 0.2;
      upgradeFeedback.add('Your sign is helping attract more customers (+20%)');
    } else {
      upgradeFeedback.add('Adding a sign could help attract more customers (+20%)');
    }
    if (_upgrades['Music'] == true) {
      upgradeMultiplier += 0.1;
      upgradeFeedback.add('The music is creating a nice atmosphere (+10%)');
    } else {
      upgradeFeedback.add('Music could help create a better atmosphere (+10%)');
    }
    if (_upgrades['Umbrella'] == true) {
      upgradeMultiplier += 0.15;
      upgradeFeedback.add('The umbrella is providing comfort for customers (+15%)');
    } else {
      upgradeFeedback.add('An umbrella could make customers more comfortable (+15%)');
    }

    // Location feedback
    String locationFeedback = '';
    if (_selectedLocation!.name == 'Park' && actualCustomers < 15) {
      locationFeedback = 'The park location has lower foot traffic. Consider the school or market for more customers.';
    } else if (_selectedLocation!.name == 'School') {
      locationFeedback = 'The school location has good foot traffic and price-sensitive customers.';
    } else if (_selectedLocation!.name == 'Market') {
      locationFeedback = 'The market location has high foot traffic and customers are less price-sensitive.';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Business Insights'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Location Analysis
              const Text(
                'Location Analysis',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text('Base customers at ${_selectedLocation!.name}: $baseCustomers'),
              Text(locationFeedback),
              const SizedBox(height: 16),

              // Price Analysis
              const Text(
                'Price Analysis',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text('Current price: \$${_pricePerCup.toStringAsFixed(2)}'),
              Text('Maximum recommended price: \$${maxPrice.toStringAsFixed(2)}'),
              Text(priceFeedback),
              const SizedBox(height: 16),

              // Upgrade Analysis
              const Text(
                'Upgrade Analysis',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...upgradeFeedback.map((feedback) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('• $feedback'),
                  )),
              const SizedBox(height: 16),

              // Performance Summary
              const Text(
                'Performance Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text('Expected customers: $expectedCustomers'),
              Text('Actual customers: $actualCustomers'),
              Text('Expected profit: \$${expectedProfit.toStringAsFixed(2)}'),
              Text('Actual profit: \$${actualProfit.toStringAsFixed(2)}'),
              if (actualProfit < 25) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: const Text(
                    'Tip: Try adjusting your price or choosing a different location to increase your customer base.',
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  void _handleCustomerServed() {
    setState(() {
      _customersServed++;
      _profit += _pricePerCup;
      _xp += 10;
      _coins += 5;
      _checkQuestCompletion();
    });
  }

  void _handleOutOfStock() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Out of stock! Make sure you have enough supplies.'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _handlePlayAgain() {
    setState(() {
      _currentScreen = 0;
      _budget = 20.0;
      _spent = 0.0;
      _saved = 0.0;
      _customersServed = 0;
      _profit = 0.0;
      _xp = 0;
      _coins = 0;
      _pricePerCup = 1.0;
      _selectedLocation = null;
      _stock = {
        'Lemons': 0,
        'Sugar': 0,
        'Cups': 0,
      };
      _upgrades = {
        'Sign': false,
        'Music': false,
        'Umbrella': false,
      };
    });
  }

  void _handleGameCompletion() {
    // Show completion dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Quest Completed! 🎉',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Congratulations! You completed the Lemonade Budget quest!',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Quest Summary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildStatRow('Customers Served', '$_customersServed'),
                      _buildStatRow('Total Profit', '\$${_profit.toStringAsFixed(2)}'),
                      _buildStatRow('XP Earned', '$_xp'),
                      _buildStatRow('Coins Earned', '$_coins'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Next Quest Unlocked!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Climbing the Savings Tower',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Each week, help Alice choose to spend or save. Skip temptations to unlock a Savings Booster!',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // First pop the dialog
                    Navigator.of(dialogContext).pop();
                    // Pop back to main navigation with completion status
                    Navigator.of(context).pop({'gameCompleted': true});
                  },
                  child: const Text('Return to Quest Map'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSummary() {
    setState(() {
      _currentScreen = 4; // Show summary screen
    });
  }

  void _handleContinue() {
    _handleGameCompletion();
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            LinearProgressIndicator(
              value: (_currentScreen + 1) / _screens.length,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
            ),

            // Quest progress
            if (_currentScreen > 0) _buildQuestProgress(),

            // Main content
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _buildCurrentScreen(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentScreen) {
      case 0:
        return _buildIntroScreen();
      case 1:
        return BudgetingScreen(
          budget: _budget,
          spent: _spent,
          saved: _saved,
          onItemSelected: _handleItemSelected,
          onItemDeselected: _handleItemDeselected,
          onFinish: _nextScreen,
        );
      case 2:
        return PlanningScreen(
          locations: _locations,
          onLocationSelected: _handleLocationSelected,
          onPriceSet: _handlePriceSet,
          currentPrice: _pricePerCup,
          onFinish: () {
            if (_selectedLocation != null) {
              _nextScreen();
            }
          },
        );
      case 3:
        return CustomerServing(
          customersServed: _customersServed,
          profit: _profit,
          stock: _stock,
          upgrades: _upgrades,
          onCustomerServed: _handleCustomerServed,
          onFinish: _nextScreen,
        );
      case 4:
        return SummaryScreen(
          customersServed: _customersServed,
          profit: _profit,
          xp: _xp,
          coins: _coins,
          stock: _stock,
          upgrades: _upgrades,
          onPlayAgain: _handlePlayAgain,
          onContinue: _handleContinue,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildIntroScreen() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/lottie/alice.json',
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 32),
            const Text(
              'The Lemonade Budget',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            const Text(
              'Help Alice start her lemonade stand business! Learn about budgeting, pricing, and customer service.',
              style: TextStyle(
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _nextScreen,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 50),
              ),
              child: const Text(
                'Start Game',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestProgress() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Current Quest',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _quests[_currentQuest]['title'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(_quests[_currentQuest]['description']),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: _customersServed / _quests[_currentQuest]['requirements']['customersServed'],
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Progress: $_customersServed/${_quests[_currentQuest]['requirements']['customersServed']} customers',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
