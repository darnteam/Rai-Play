import 'package:flutter/material.dart';
import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:fl_chart/fl_chart.dart';

class BankRushScreen extends StatefulWidget {
  const BankRushScreen({super.key});

  @override
  State<BankRushScreen> createState() => _BankRushScreenState();
}

class _BankRushScreenState extends State<BankRushScreen> with TickerProviderStateMixin {
  // Game state
  int _round = 1;
  double _checking = 50;
  double _savings = 0;
  int _xp = 0;
  int _bankIQ = 0;
  int _goalsAchieved = 0;
  String _character = '';
  String _characterDesc = '';
  String _goal = '';
  String _feedback = '';
  bool _showIntro = true;
  bool _showCharacterSelect = false;
  bool _gameOver = false;
  int _tabIndex = 0;
  String _event = '';
  String _eventFeedback = '';
  bool _showEvent = false;
  bool _showQuiz = false;
  String _quizQ = '';
  List<String> _quizA = [];
  int _quizCorrect = 0;
  String _quizFeedback = '';
  bool _showConfetti = false;

  // Animation controllers
  late AnimationController _balanceController;
  late AnimationController _xpController;
  late AnimationController _waveController;
  late AnimationController _cardController;
  late Animation<double> _balanceAnim;
  late Animation<double> _xpAnim;
  late Animation<double> _waveAnim;
  late Animation<double> _cardAnim;
  late ConfettiController _confettiController;

  // Animations
  late Animation<double> _checkingAnim;
  late Animation<double> _savingsAnim;
  late Animation<double> _cardScaleAnim;

  // Chart data
  List<FlSpot> _checkingHistory = [];
  List<FlSpot> _savingsHistory = [];
  double _maxBalance = 50;

  final List<Map<String, dynamic>> _characters = [
    {
      'name': 'Maya the Maker',
      'desc': 'Wants to buy a laptop 💻',
      'goal': 'Buy a laptop (€300)',
    },
    {
      'name': 'Leo the Learner',
      'desc': 'Saving for a school trip 🚌',
      'goal': 'Go on a school trip (€200)',
    },
    {
      'name': 'Sam the Saver',
      'desc': 'Building an emergency fund 🚑',
      'goal': 'Emergency fund (€150)',
    },
  ];
  final List<Map<String, dynamic>> _offers = [
    {'item': 'New sneakers', 'price': 45.0},
    {'item': 'Music ticket', 'price': 20.0},
    {'item': 'Game pass', 'price': 15.0},
    {'item': 'Fast food', 'price': 10.0},
    {'item': 'Headphones', 'price': 30.0},
  ];
  final List<Map<String, dynamic>> _events = [
    {'event': '⚠️ Subscription charged €10 — forgot to cancel!', 'effect': -10},
    {'event': '🏧 ATM fee of €3 — could\'ve used a partner ATM!', 'effect': -3},
    {'event': '🎉 You received €25 for helping a neighbor!', 'effect': 25},
    {'event': '💻 Bank app shows suspicious transaction — what do you do?', 'effect': 0},
  ];
  final List<Map<String, dynamic>> _quizzes = [
    {
      'q': 'What is compound interest?',
      'a': ['Interest on interest', 'A bank fee', 'A type of loan'],
      'correct': 0,
    },
    {
      'q': 'Why use savings for emergencies?',
      'a': ['It earns interest', 'It is safe and accessible', 'It is risky'],
      'correct': 1,
    },
    {
      'q': 'What is an overdraft?',
      'a': ['Spending more than you have', 'A bonus', 'A savings account'],
      'correct': 0,
    },
  ];
  final List<Map<String, dynamic>> _goals = [
    {'goal': 'Buy a bike', 'amount': 100.0, 'achieved': false},
    {'goal': 'Attend event', 'amount': 60.0, 'achieved': false},
    {'goal': 'Go on trip', 'amount': 200.0, 'achieved': false},
  ];

  @override
  void initState() {
    super.initState();
    _balanceController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _xpController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _waveController = AnimationController(duration: const Duration(milliseconds: 2000), vsync: this)..repeat();
    _cardController = AnimationController(duration: const Duration(milliseconds: 400), vsync: this);

    _balanceAnim = CurvedAnimation(parent: _balanceController, curve: Curves.easeOutBack);
    _xpAnim = CurvedAnimation(parent: _xpController, curve: Curves.easeOutBack);
    _waveAnim = CurvedAnimation(parent: _waveController, curve: Curves.easeInOut);
    _cardAnim = CurvedAnimation(parent: _cardController, curve: Curves.easeOutBack);

    _checkingAnim = Tween<double>(begin: 50, end: 50).animate(
      CurvedAnimation(parent: _balanceController, curve: Curves.easeOutBack),
    );
    _savingsAnim = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _balanceController, curve: Curves.easeOutBack),
    );
    _cardScaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeOutBack),
    );

    _confettiController = ConfettiController(duration: const Duration(seconds: 2));

    Future.delayed(const Duration(milliseconds: 1200), () {
      setState(() {
        _showIntro = false;
        _showCharacterSelect = true;
      });
    });
    _updateBalanceHistory();
  }

  void _updateBalanceHistory() {
    _checkingHistory.add(FlSpot(_checkingHistory.length.toDouble(), _checking));
    _savingsHistory.add(FlSpot(_savingsHistory.length.toDouble(), _savings));
    _maxBalance = [_checking, _savings].reduce(max);
  }

  @override
  void dispose() {
    _balanceController.dispose();
    _xpController.dispose();
    _waveController.dispose();
    _cardController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _selectCharacter(int idx) {
    setState(() {
      _character = _characters[idx]['name'];
      _characterDesc = _characters[idx]['desc'];
      _goal = _characters[idx]['goal'];
      _showCharacterSelect = false;
    });
  }

  void _nextRound() {
    setState(() {
      _round++;
      _tabIndex = 0;
      _showEvent = false;
      _showQuiz = false;
      _feedback = '';
      if (_round > 10) {
        _gameOver = true;
        _showConfetti = true;
      } else {
        _triggerEvent();
        _triggerQuiz();
      }
    });
  }

  void _triggerEvent() {
    final events = [
      {'text': 'Unexpected medical bill! Pay €50 from checking.', 'amount': -50.0},
      {'text': 'Found €20 on the street! Added to checking.', 'amount': 20.0},
      {'text': 'Won a small lottery! €100 added to checking.', 'amount': 100.0},
      {'text': 'Phone bill due. Pay €30 from checking.', 'amount': -30.0},
      {'text': 'Birthday gift from grandma! €50 added to checking.', 'amount': 50.0},
    ];

    final event = events[Random().nextInt(events.length)];
    setState(() {
      _event = event['text'] as String;
      final amount = event['amount'] as double;

      if (_checking + amount < 0) {
        _eventFeedback = 'Insufficient funds! You need to manage your money better.';
        _bankIQ -= 5;
      } else {
        _checking += amount;
        _eventFeedback = amount > 0 ? 'Success! Your balance increased.' : 'Payment processed successfully.';
        _bankIQ += 5;
        _xp += 10;
      }

      _updateBalanceHistory();
      _balanceController.forward(from: 0);
      _cardController.forward(from: 0);
    });
  }

  void _triggerQuiz() {
    final random = Random();
    final quiz = _quizzes[random.nextInt(_quizzes.length)];
    _quizQ = quiz['q'];
    _quizA = List<String>.from(quiz['a']);
    _quizCorrect = quiz['correct'];
    _showQuiz = true;
  }

  void _handleQuiz(int idx) {
    setState(() {
      if (idx == _quizCorrect) {
        _quizFeedback = 'Correct! 🎉 +10 XP';
        _xp += 10;
        _bankIQ += 5;
      } else {
        _quizFeedback = 'Oops! The right answer was: ${_quizA[_quizCorrect]}';
      }
      _showQuiz = false;
    });
  }

  void _handleBankAction(String action, [double? amount]) {
    setState(() {
      final transferAmount = amount ?? 10.0;
      switch (action) {
        case 'deposit':
          if (_checking >= transferAmount) {
            _checking -= transferAmount;
            _savings += transferAmount;
            _feedback = 'Successfully deposited €${transferAmount.toStringAsFixed(2)} to savings!';
            _xp += 10;
          } else {
            _feedback = 'Insufficient funds in checking account!';
          }
          break;
        case 'withdraw':
          if (_savings >= transferAmount) {
            _savings -= transferAmount;
            _checking += transferAmount;
            _feedback = 'Successfully withdrew €${transferAmount.toStringAsFixed(2)} from savings!';
            _xp += 5;
          } else {
            _feedback = 'Insufficient funds in savings account!';
          }
          break;
        case 'transfer':
          if (_checking >= transferAmount) {
            _checking -= transferAmount;
            _savings += transferAmount;
            _feedback = 'Successfully transferred €${transferAmount.toStringAsFixed(2)} to savings!';
            _xp += 8;
          } else {
            _feedback = 'Insufficient funds for transfer!';
          }
          break;
      }
      _updateBalanceHistory();
      _balanceController.forward(from: 0);
    });
  }

  void _handleSpend(int idx) {
    final offer = _offers[idx];
    setState(() {
      final price = offer['price'] as double;
      if (_checking >= price) {
        _checking -= price;
        _feedback = 'Bought ${offer['item']} for €${price.toStringAsFixed(2)}.';
      } else {
        _feedback = 'Not enough in checking!';
      }
    });
  }

  void _handleGoal(int idx) {
    setState(() {
      final amount = _goals[idx]['amount'] as double;
      if (_savings >= amount && !_goals[idx]['achieved']) {
        _savings -= amount;
        _goals[idx]['achieved'] = true;
        _goalsAchieved++;
        _feedback = 'Goal achieved: ${_goals[idx]['goal']}!';
        _xp += 15;
      } else {
        _feedback = 'Not enough in savings!';
      }
    });
  }

  Widget _buildGameHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Round $_round/10',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'XP: $_xp',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.psychology, color: Colors.lightBlueAccent, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Bank IQ: $_bankIQ',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildAccountCards(),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountCards() {
    return Row(
      children: [
        Expanded(
          child: _buildAccountCard(
            'Checking',
            _checking,
            Icons.account_balance_wallet,
            Colors.greenAccent,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildAccountCard(
            'Savings',
            _savings,
            Icons.savings,
            Colors.amberAccent,
          ),
        ),
      ],
    );
  }

  Widget _buildAccountCard(String title, double balance, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '€${balance.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceChart() {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(8),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: _checkingHistory,
              isCurved: true,
              color: Colors.blue,
              barWidth: 3,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.withOpacity(0.1),
              ),
            ),
            LineChartBarData(
              spots: _savingsHistory,
              isCurved: true,
              color: Colors.green,
              barWidth: 3,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.green.withOpacity(0.1),
              ),
            ),
          ],
          minY: 0,
          maxY: _maxBalance * 1.1,
        ),
      ),
    );
  }

  Widget _buildHUD() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade800, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Week $_round',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildStatPill('XP', _xp.toString(), Icons.star),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildAccountCard(
                  'Checking',
                  _checking,
                  Icons.account_balance_wallet,
                  Colors.blue.shade300,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAccountCard(
                  'Savings',
                  _savings,
                  Icons.savings,
                  Colors.green.shade300,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard() {
    return AnimatedBuilder(
      animation: _cardAnim,
      builder: (context, child) => Transform.scale(
        scale: _cardAnim.value,
        child: Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.event_note, color: Colors.blue),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Financial Event',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      _event,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionButton('Deposit', Icons.arrow_upward, Colors.green),
                        _buildActionButton('Withdraw', Icons.arrow_downward, Colors.red),
                        _buildActionButton('Transfer', Icons.swap_horiz, Colors.blue),
                      ],
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

  Widget _buildActionButton(String label, IconData icon, Color color) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _handleBankAction(label),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuiz() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.quiz, color: Colors.blue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Financial Quiz',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _quizQ,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ...List.generate(
                  _quizA.length,
                  (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _handleQuiz(i),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).primaryColor.withOpacity(0.3),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _quizA[i],
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).primaryColor,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ),
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

  Widget _buildGameOver() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            particleDrag: 0.05,
            emissionFrequency: 0.05,
            numberOfParticles: 20,
            gravity: 0.1,
            shouldLoop: false,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple,
            ],
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _goalsAchieved >= 2 ? Colors.green.shade50 : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(
                  _goalsAchieved >= 2 ? Icons.emoji_events : Icons.star,
                  size: 48,
                  color: _goalsAchieved >= 2 ? Colors.amber : Colors.orange,
                ),
                const SizedBox(height: 16),
                Text(
                  _goalsAchieved >= 2 ? 'Congratulations!' : 'Game Over',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _goalsAchieved >= 2 ? Colors.green.shade700 : Colors.orange.shade700,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  _goalsAchieved >= 2 ? 'You\'ve mastered personal finance!' : 'Keep practicing to improve your financial skills!',
                  style: TextStyle(
                    color: _goalsAchieved >= 2 ? Colors.green.shade600 : Colors.orange.shade600,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildFinalStats(),
          const SizedBox(height: 24),
          _buildAchievements(),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: Colors.grey.shade700,
                  ),
                  icon: const Icon(Icons.exit_to_app),
                  label: const Text('Exit Game'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Share functionality
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  icon: const Icon(Icons.share),
                  label: const Text('Share Results'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFinalStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Final Stats',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total Savings',
                  '€${_savings.toStringAsFixed(2)}',
                  Icons.savings,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  'Bank IQ',
                  _bankIQ.toString(),
                  Icons.psychology,
                  Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'XP Earned',
                  _xp.toString(),
                  Icons.star,
                  Colors.amber,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  'Goals Achieved',
                  '$_goalsAchieved/3',
                  Icons.flag,
                  Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements() {
    final achievements = [
      if (_savings >= 1000) 'Savings Master 💰',
      if (_bankIQ >= 80) 'Financial Genius 🧠',
      if (_xp >= 500) 'Experience Champion ⭐',
      if (_goalsAchieved >= 2) 'Goal Crusher 🎯',
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Achievements',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade700,
                ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: achievements.map((achievement) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.shade200.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  achievement,
                  style: TextStyle(
                    color: Colors.purple.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[50],
      body: SafeArea(
        child: Column(
          children: [
            if (_showIntro)
              Expanded(
                child: _buildIntroScreen(),
              ),
            if (_showCharacterSelect)
              Expanded(
                child: _buildCharacterSelect(),
              ),
            if (!_showIntro && !_showCharacterSelect && !_gameOver)
              Expanded(
                child: Column(
                  children: [
                    _buildGameHeader(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text('Round $_round / 10', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    // Tabbed dashboard
                    TabBar(
                      controller: TabController(length: 4, vsync: this, initialIndex: _tabIndex),
                      onTap: (idx) => setState(() => _tabIndex = idx),
                      tabs: const [
                        Tab(icon: Icon(Icons.account_balance), text: 'Bank'),
                        Tab(icon: Icon(Icons.shopping_cart), text: 'Spend'),
                        Tab(icon: Icon(Icons.flag), text: 'Goals'),
                        Tab(icon: Icon(Icons.lightbulb), text: 'Tips'),
                      ],
                    ),
                    Expanded(
                      child: IndexedStack(
                        index: _tabIndex,
                        children: [
                          // Bank tab
                          SingleChildScrollView(
                            child: Column(
                              children: [
                                const SizedBox(height: 16),
                                Text('Checking: €${_checking.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                Text('Savings: €${_savings.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () => _handleBankAction('deposit', 10),
                                      child: const Text('Deposit €10'),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () => _handleBankAction('withdraw', 10),
                                      child: const Text('Withdraw €10'),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () => _handleBankAction('transfer', 20),
                                      child: const Text('Transfer €20'),
                                    ),
                                  ],
                                ),
                                if (_checking < 10)
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('⚠️ Low balance! Avoid overdraft fees.', style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.bold)),
                                  ),
                                if (_feedback.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(_feedback, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                              ],
                            ),
                          ),
                          // Spend tab
                          SingleChildScrollView(
                            child: Column(
                              children: [
                                const SizedBox(height: 16),
                                ...List.generate(
                                    _offers.length,
                                    (i) => Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 4),
                                          child: ElevatedButton(
                                            onPressed: () => _handleSpend(i),
                                            child: Text('${_offers[i]['item']} for €${_offers[i]['price']}'),
                                          ),
                                        )),
                                if (_feedback.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(_feedback, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                              ],
                            ),
                          ),
                          // Goals tab
                          SingleChildScrollView(
                            child: Column(
                              children: [
                                const SizedBox(height: 16),
                                ...List.generate(
                                    _goals.length,
                                    (i) => Card(
                                          child: ListTile(
                                            title: Text(_goals[i]['goal']),
                                            subtitle: Text('€${_goals[i]['amount']}'),
                                            trailing: _goals[i]['achieved']
                                                ? const Icon(Icons.check_circle, color: Colors.green)
                                                : ElevatedButton(
                                                    onPressed: () => _handleGoal(i),
                                                    child: const Text('Achieve'),
                                                  ),
                                          ),
                                        )),
                                if (_feedback.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(_feedback, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                              ],
                            ),
                          ),
                          // Tips tab
                          SingleChildScrollView(
                            child: Column(
                              children: [
                                const SizedBox(height: 16),
                                if (_showQuiz) _buildQuiz(),
                                if (!_showQuiz && _quizFeedback.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(_quizFeedback, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_showEvent) _buildEventCard(),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: ElevatedButton(
                        onPressed: _nextRound,
                        child: const Text('Next Round'),
                      ),
                    ),
                  ],
                ),
              ),
            if (_gameOver) _buildGameOver(),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    '🏦 Welcome to Bank Rush!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Learn to manage your money wisely! Make smart banking decisions, save for your goals, and build your financial future.\n\nChoose your character and navigate through 10 exciting rounds!',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.5,
                          color: Colors.grey[700],
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildCharacterSelect() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Choose Your Character',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
            ),
            const SizedBox(height: 24),
            ...List.generate(
              _characters.length,
              (i) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: InkWell(
                  onTap: () => _selectCharacter(i),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      _characters[i]['desc'].toString().split(' ').last,
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _characters[i]['name'],
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _characters[i]['desc'],
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.flag,
                                      size: 16,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _characters[i]['goal'],
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          right: 12,
                          top: 0,
                          bottom: 0,
                          child: Icon(
                            Icons.chevron_right,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatPill(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
