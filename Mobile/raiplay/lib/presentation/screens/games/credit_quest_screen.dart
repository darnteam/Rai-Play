import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:confetti/confetti.dart';

class CreditQuestScreen extends StatefulWidget {
  const CreditQuestScreen({Key? key}) : super(key: key);

  @override
  State<CreditQuestScreen> createState() => _CreditQuestScreenState();
}

class _CreditQuestScreenState extends State<CreditQuestScreen> with TickerProviderStateMixin {
  // Game state
  int _year = 1;
  int _creditScore = 600;
  int _xp = 0;
  String _avatar = '🙂';
  String _character = '';
  String _characterDesc = '';
  String? _feedback;
  bool _showIntro = true;
  bool _showCharacterSelect = false;
  bool _showEvent = false;
  bool _showResult = false;
  int _eventIndex = 0;
  Timer? _decisionTimer;
  int _decisionTimeLeft = 5;
  bool _decisionMade = false;
  bool _gameOver = false;
  bool _carUnlocked = false;
  late AnimationController _scoreController;
  late AnimationController _avatarController;
  late AnimationController _waveController;
  late Animation<double> _scoreAnim;
  late Animation<double> _xpAnim;
  late Animation<double> _waveAnim;
  late ConfettiController _confettiController;
  int _displayedScore = 600;
  int _displayedXP = 0;
  String _yearTheme = '';
  final List<String> _yearThemes = [
    'College Dorm 🏫',
    'First Job 💼',
    'New Apartment 🏢',
    'Big Purchase 🚗',
    'Dream Achieved 🎉',
  ];
  final List<Color> _yearColors = [
    Colors.deepPurple[50]!,
    Colors.blue[50]!,
    Colors.green[50]!,
    Colors.orange[50]!,
    Colors.pink[50]!,
  ];

  final List<Map<String, dynamic>> _characters = [
    {
      'name': 'Dreamer Dani',
      'desc': 'Wants to travel the world 🌍',
      'avatar': '🧑‍🎤',
      'bonus': 20,
      'habit': 'occasional late payment',
    },
    {
      'name': 'Builder Ben',
      'desc': 'Wants to buy a house 🏠',
      'avatar': '👷‍♂️',
      'bonus': 10,
      'habit': 'pays on time',
    },
    {
      'name': 'Starter Sam',
      'desc': 'Needs a laptop for school 💻',
      'avatar': '🧑‍💻',
      'bonus': 15,
      'habit': 'spends on tech',
    },
  ];

  final List<List<Map<String, dynamic>>> _yearEvents = [
    // Year 1
    [
      {
        'event': 'Apply for first credit card',
        'good': 'Get approved and use responsibly',
        'bad': 'Overspend and miss a payment',
        'goodScore': 30,
        'badScore': -40,
        'emoji': '💳',
      },
      {
        'event': 'Pay phone bill early',
        'good': 'On-time payment boosts score',
        'bad': 'Forget to pay',
        'goodScore': 20,
        'badScore': -25,
        'emoji': '📱',
      },
      {
        'event': 'Identity theft warning',
        'good': 'Freeze credit, avoid loss',
        'bad': 'Ignore warning, lose points',
        'goodScore': 15,
        'badScore': -30,
        'emoji': '💣',
      },
    ],
    // Year 2
    [
      {
        'event': 'Get a car loan',
        'good': 'Make all payments on time',
        'bad': 'Miss a payment',
        'goodScore': 35,
        'badScore': -50,
        'emoji': '🚗',
      },
      {
        'event': 'Open a store credit card',
        'good': 'Use for small purchases only',
        'bad': 'Max out the card',
        'goodScore': 20,
        'badScore': -30,
        'emoji': '🛍️',
      },
      {
        'event': 'Pay rent late',
        'good': 'Pay on time',
        'bad': 'Pay late',
        'goodScore': 10,
        'badScore': -20,
        'emoji': '🏠',
      },
    ],
    // Year 3
    [
      {
        'event': 'Apply for student loan',
        'good': 'Make regular payments',
        'bad': 'Miss a payment',
        'goodScore': 25,
        'badScore': -35,
        'emoji': '🎓',
      },
      {
        'event': 'Get a new phone',
        'good': 'Trade in old phone',
        'bad': 'Buy on credit, miss payment',
        'goodScore': 10,
        'badScore': -20,
        'emoji': '📱',
      },
      {
        'event': 'Credit card fraud alert',
        'good': 'Report and freeze card',
        'bad': 'Ignore alert',
        'goodScore': 20,
        'badScore': -30,
        'emoji': '🚨',
      },
    ],
    // Year 4
    [
      {
        'event': 'Apply for apartment',
        'good': 'Good credit, get approved',
        'bad': 'Low score, get denied',
        'goodScore': 30,
        'badScore': -40,
        'emoji': '🏢',
      },
      {
        'event': 'Pay utilities',
        'good': 'Pay on time',
        'bad': 'Pay late',
        'goodScore': 10,
        'badScore': -15,
        'emoji': '💡',
      },
      {
        'event': 'Get a credit limit increase',
        'good': 'Accept and use responsibly',
        'bad': 'Overspend',
        'goodScore': 20,
        'badScore': -25,
        'emoji': '⬆️',
      },
    ],
    // Year 5
    [
      {
        'event': 'Apply for car loan',
        'good': 'Get approved',
        'bad': 'Get denied',
        'goodScore': 40,
        'badScore': -50,
        'emoji': '🚗',
      },
      {
        'event': 'Pay off all credit cards',
        'good': 'Score jumps',
        'bad': 'Miss a payment',
        'goodScore': 30,
        'badScore': -40,
        'emoji': '💳',
      },
      {
        'event': 'Surprise bonus!',
        'good': 'Use to pay debt',
        'bad': 'Spend it all',
        'goodScore': 25,
        'badScore': -20,
        'emoji': '🎁',
      },
    ],
  ];

  @override
  void initState() {
    super.initState();
    _scoreController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _avatarController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _waveController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));

    _scoreAnim = Tween<double>(begin: 600, end: 600).animate(_scoreController);
    _xpAnim = Tween<double>(begin: 0, end: 0).animate(_scoreController);
    _waveAnim = Tween<double>(begin: 0, end: 2 * pi).animate(_waveController);

    _yearTheme = _yearThemes[0];
    Future.delayed(const Duration(milliseconds: 1200), () {
      setState(() {
        _showIntro = false;
        _showCharacterSelect = true;
      });
    });
  }

  @override
  void dispose() {
    _scoreController.dispose();
    _avatarController.dispose();
    _waveController.dispose();
    _confettiController.dispose();
    _decisionTimer?.cancel();
    super.dispose();
  }

  void _selectCharacter(int idx) {
    setState(() {
      _character = _characters[idx]['avatar'];
      _characterDesc = _characters[idx]['desc'];
      _creditScore += (_characters[idx]['bonus'] as int);
      _displayedScore = _creditScore;
      _showCharacterSelect = false;
      _showEvent = true;
      _eventIndex = 0;
      _yearTheme = _yearThemes[0];
    });
  }

  void _startEventDecision() {
    _decisionMade = false;
    _decisionTimeLeft = 5;
    _decisionTimer?.cancel();
    _decisionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _decisionTimeLeft--;
        if (_decisionTimeLeft <= 0) {
          _decisionTimer?.cancel();
          if (!_decisionMade) _handleDecision(false);
        }
      });
    });
  }

  void _handleDecision(bool good) {
    _decisionMade = true;
    _decisionTimer?.cancel();
    final event = _yearEvents[_year - 1][_eventIndex];
    int scoreChange = good ? event['goodScore'] : event['badScore'];
    int xpChange = good ? 10 : 0;
    int oldScore = _creditScore;
    int oldXP = _xp;
    setState(() {
      _creditScore += scoreChange;
      _xp += xpChange;
      _feedback = good ? '🌟 ${event['good']}' : '⚠️ ${event['bad']}';
      _avatar = good ? '😃' : '😬';
      if (_creditScore >= 750) _carUnlocked = true;
      _showResult = true;
    });
    _scoreAnim = Tween<double>(begin: oldScore.toDouble(), end: _creditScore.toDouble()).animate(_scoreController);
    _xpAnim = Tween<double>(begin: oldXP.toDouble(), end: _xp.toDouble()).animate(_scoreController);
    _scoreController.forward(from: 0);
    _avatarController.forward(from: 0);
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _showResult = false;
        _avatar = '🙂';
        if (_eventIndex < 2) {
          _eventIndex++;
          _showEvent = true;
          _startEventDecision();
        } else if (_year < 5) {
          _year++;
          _eventIndex = 0;
          _showEvent = false;
          _yearTheme = _yearThemes[_year - 1];
          Future.delayed(const Duration(milliseconds: 900), () {
            setState(() {
              _showEvent = true;
              _startEventDecision();
            });
          });
        } else {
          _gameOver = true;
        }
      });
    });
  }

  Widget _buildHUD() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.8),
            Theme.of(context).primaryColor.withOpacity(0.6),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Hero(
                  tag: 'character_avatar',
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: Container(
                      key: ValueKey(_character),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(_character, style: const TextStyle(fontSize: 32)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _characterDesc,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Year $_year/5',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                _buildStatCard(
                  icon: Icons.star,
                  color: Colors.amber,
                  value: _xpAnim.value.round().toString(),
                  label: 'XP',
                ),
                const SizedBox(width: 8),
                _buildStatCard(
                  icon: Icons.trending_up,
                  color: _creditScore >= 750
                      ? Colors.green
                      : _creditScore >= 650
                          ? Colors.orange
                          : Colors.red,
                  value: _scoreAnim.value.round().toString(),
                  label: 'Score',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color color,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard() {
    final event = _yearEvents[_year - 1][_eventIndex];
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    event['emoji'],
                    style: const TextStyle(fontSize: 48),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  event['event'],
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                if (!_decisionMade) ...[
                  Text(
                    'Time to decide: $_decisionTimeLeft s',
                    style: TextStyle(
                      color: _decisionTimeLeft <= 2 ? Colors.red : Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Row(
                  children: [
                    Expanded(
                      child: _buildChoiceButton(
                        text: event['good'],
                        color: Colors.green,
                        onPressed: _decisionMade ? null : () => _handleDecision(true),
                        icon: Icons.check_circle_outline,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildChoiceButton(
                        text: event['bad'],
                        color: Colors.red,
                        onPressed: _decisionMade ? null : () => _handleDecision(false),
                        icon: Icons.cancel_outlined,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChoiceButton({
    required String text,
    required Color color,
    required VoidCallback? onPressed,
    required IconData icon,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: color),
        ),
        elevation: onPressed == null ? 0 : 2,
      ),
      child: Column(
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 4),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildResult() {
    return Center(
      child: AnimatedOpacity(
        opacity: _showResult ? 1 : 0,
        duration: const Duration(milliseconds: 400),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: Text(
                    _avatar,
                    key: ValueKey(_avatar),
                    style: const TextStyle(fontSize: 64),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _feedback?.startsWith('🌟') == true ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _feedback ?? '',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _feedback?.startsWith('🌟') == true ? Colors.green : Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameOver() {
    String badge = _creditScore >= 750
        ? '🏆 Credit Hero'
        : _creditScore >= 700
            ? '⭐ On-Time Payer'
            : '🔒 Credit Rookie';

    return Stack(
      children: [
        Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_carUnlocked) ...[
                  const Text(
                    '🎉',
                    style: TextStyle(fontSize: 64),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Congratulations!',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Car Loan Approved!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ] else ...[
                  const Text(
                    'Game Over',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                _buildScoreCard(),
                const SizedBox(height: 24),
                _buildBadgeCard(badge),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.exit_to_app),
                      label: const Text('Exit'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Share feature coming soon!')),
                        );
                      },
                      icon: const Icon(Icons.share),
                      label: const Text('Share'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
    );
  }

  Widget _buildScoreCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Final Credit Score',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _creditScore.toString(),
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: _creditScore >= 750
                    ? Colors.green
                    : _creditScore >= 650
                        ? Colors.orange
                        : Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: (_creditScore - 300) / 550,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                _creditScore >= 750
                    ? Colors.green
                    : _creditScore >= 650
                        ? Colors.orange
                        : Colors.red,
              ),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeCard(String badge) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Achievement Unlocked',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Text(
                badge.split(' ')[0],
                style: const TextStyle(fontSize: 32),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              badge.split(' ').sublist(1).join(' '),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated background
          AnimatedBuilder(
            animation: _waveAnim,
            builder: (context, child) {
              return CustomPaint(
                painter: WavePainter(
                  wavePhase: _waveAnim.value,
                  contextHeight: MediaQuery.of(context).size.height,
                  color: _yearColors[_year - 1],
                ),
                size: Size.infinite,
              );
            },
          ),
          Column(
            children: [
              _buildHUD(),
              if (_showIntro)
                Expanded(
                  child: _buildIntroScreen(),
                ),
              if (_showCharacterSelect)
                Expanded(
                  child: _buildCharacterSelect(),
                ),
              if (!_showIntro && !_showCharacterSelect)
                Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: LinearProgressIndicator(
                          value: _year / 5,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).primaryColor,
                          ),
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          _yearTheme,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (_showEvent) Expanded(child: _buildEventCard()),
                      if (_showResult) Expanded(child: _buildResult()),
                      if (_gameOver) Expanded(child: _buildGameOver()),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIntroScreen() {
    return Center(
      child: SingleChildScrollView(
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
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    "Welcome to Credit Quest!",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "You just turned 18. You've got dreams: 🚗 a car, 🏠 an apartment, 🎓 college — but you've got one thing to manage first... your CREDIT SCORE. Can you go from zero to credit hero in 5 years?",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[800],
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  const CircularProgressIndicator(),
                ],
              ),
            ),
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
              'Choose your character:',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            ...List.generate(
              _characters.length,
              (i) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: _buildCharacterCard(i),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCharacterCard(int index) {
    final character = _characters[index];
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () => _selectCharacter(index),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  character['avatar'],
                  style: const TextStyle(fontSize: 32),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      character['name'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      character['desc'],
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Bonus: +${character['bonus']} Credit Score',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios),
            ],
          ),
        ),
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  final double wavePhase;
  final double contextHeight;
  final Color color;

  WavePainter({
    required this.wavePhase,
    required this.contextHeight,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(0, contextHeight * 0.65);

    for (double i = 0; i <= size.width; i++) {
      path.lineTo(
        i,
        contextHeight * 0.65 + sin((i / size.width * 4 * pi) + wavePhase) * 10,
      );
    }

    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) {
    return oldDelegate.wavePhase != wavePhase;
  }
}
