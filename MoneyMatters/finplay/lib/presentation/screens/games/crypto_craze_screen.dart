import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:fl_chart/fl_chart.dart';

class CryptoCrazeScreen extends StatefulWidget {
  const CryptoCrazeScreen({Key? key}) : super(key: key);

  @override
  State<CryptoCrazeScreen> createState() => _CryptoCrazeScreenState();
}

class _CryptoCrazeScreenState extends State<CryptoCrazeScreen> with TickerProviderStateMixin {
  // Game state
  int _round = 1;
  double _portfolio = 1000;
  int _xp = 0;
  int _cryptoIQ = 0;
  String _news = '';
  String? _feedback;
  bool _showIntro = true;
  bool _showResult = false;
  bool _gameOver = false;
  String _badge = '';
  String _trend = '↔️';
  String _risk = '🟡';
  double _volatility = 0.5;
  String _lastMove = '';
  bool _minigameActive = false;
  bool _showEvent = true;
  final List<String> _badges = [];

  // Animation controllers
  late AnimationController _scoreController;
  late AnimationController _portfolioController;
  late AnimationController _chartController;
  late AnimationController _cardController;
  late AnimationController _waveController;
  late ConfettiController _confettiController;

  // Animations
  late Animation<double> _scoreAnim;
  late Animation<double> _portfolioAnim;
  late Animation<double> _waveAnim;
  late Animation<double> _chartAnim;

  // Price chart data
  List<FlSpot> _priceHistory = [];
  double _highestPrice = 1000;
  double _lowestPrice = 1000;
  final List<Map<String, dynamic>> _coins = [
    {
      'name': 'Bitcoin',
      'emoji': '₿',
      'volatility': 0.3,
      'risk': '🟡',
      'trend': '↔️',
    },
    {
      'name': 'Ethereum',
      'emoji': 'Ξ',
      'volatility': 0.4,
      'risk': '🟡',
      'trend': '↔️',
    },
    {
      'name': 'Dogecoin',
      'emoji': '🐕',
      'volatility': 0.8,
      'risk': '🔴',
      'trend': '↔️',
    },
    {
      'name': 'Stablecoin',
      'emoji': '🪙',
      'volatility': 0.1,
      'risk': '🟢',
      'trend': '↔️',
    },
    {
      'name': 'NFT Project',
      'emoji': '🎨',
      'volatility': 0.9,
      'risk': '🔴',
      'trend': '↔️',
    },
  ];
  int _selectedCoin = 0;
  final List<String> _newsFeed = [
    'DOGE is pumping! Elon just tweeted 🚀',
    'New NFT project promising 1000x gains',
    'Exchange X just got hacked',
    'Bitcoin hits all-time high!',
    'Ethereum gas fees spike',
    'Celebrity launches meme coin',
    'Stablecoins in the spotlight',
    'Rug pull alert! New scam coin trending',
    'Crypto market correction incoming',
    'NFTs are the future, or are they?',
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    Future.delayed(const Duration(milliseconds: 1200), () {
      setState(() {
        _showIntro = false;
        _setRoundState();
      });
    });
  }

  void _initializeAnimations() {
    _scoreController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _portfolioController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _chartController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _cardController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _waveController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));

    _scoreAnim = Tween<double>(begin: 0, end: 0).animate(_scoreController);
    _portfolioAnim = Tween<double>(begin: 1000, end: 1000).animate(_portfolioController);
    _waveAnim = Tween<double>(begin: 0, end: 2 * pi).animate(_waveController);
    _chartAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _chartController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scoreController.dispose();
    _portfolioController.dispose();
    _chartController.dispose();
    _cardController.dispose();
    _waveController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _setRoundState() {
    final random = Random();
    _news = _newsFeed[_round - 1];
    _selectedCoin = random.nextInt(_coins.length);
    _trend = ['⬆️', '⬇️', '↔️'][random.nextInt(3)];
    _risk = ['🟢', '🟡', '🔴'][random.nextInt(3)];
    _volatility = (random.nextDouble() * 0.8) + 0.1;
    _feedback = null;
    _minigameActive = false;
  }

  void _chooseMove(String move) {
    setState(() {
      _lastMove = move;
      _showResult = true;
    });
    Future.delayed(const Duration(seconds: 1), () {
      _applyMoveLogic(move);
      setState(() {
        _showResult = false;
        if (_round < 10) {
          _round++;
          _setRoundState();
        } else {
          _gameOver = true;
          _badge = _determineBadge();
        }
      });
    });
  }

  void _updatePriceHistory(double change) {
    final lastPrice = _priceHistory.isEmpty ? _portfolio : _priceHistory.last.y;
    final newPrice = lastPrice + change;
    _priceHistory.add(FlSpot(_priceHistory.length.toDouble(), newPrice));
    _highestPrice = _priceHistory.fold(0, (max, spot) => spot.y > max ? spot.y : max);
    _lowestPrice = _priceHistory.fold(double.infinity, (min, spot) => spot.y < min ? spot.y : min);
    _chartController.forward(from: 0);
  }

  void _applyMoveLogic(String move) {
    final random = Random();
    double change = 0;
    String feedback = '';

    if (move == 'Buy') {
      if (_news.contains('scam') || _coins[_selectedCoin]['risk'] == '🔴') {
        if (random.nextBool()) {
          change = -_portfolio * 0.3;
          feedback = '😬 Rug pull! Portfolio drained.';
          _badges.add('🛡 Scam Dodger');
          _minigameActive = true;
          _showRugPullMinigame();
        } else {
          change = -_portfolio * 0.1;
          feedback = '📉 Bought on hype, market crashed!';
        }
      } else if (_trend == '⬆️') {
        change = _portfolio * (_volatility * 0.2);
        feedback = '🚀 Nice buy! Market is up.';
        _xp += 10;
      } else {
        change = -_portfolio * (_volatility * 0.1);
        feedback = '📉 Market dipped after your buy.';
      }
    } else if (move == 'Hold') {
      if (_coins[_selectedCoin]['name'] == 'Stablecoin') {
        change = _portfolio * 0.01;
        feedback = '🎯 Steady as she goes!';
        _badges.add('🐢 Steady HODLer');
        _xp += 5;
      } else if (_trend == '⬇️') {
        change = -_portfolio * (_volatility * 0.1);
        feedback = '💎 Market dropped, but you held on.';
      } else {
        change = _portfolio * (_volatility * 0.05);
        feedback = '📈 Small gain for holding.';
        _xp += 2;
      }
    } else if (move == 'Sell') {
      if (_trend == '⬇️') {
        change = -_portfolio * (_volatility * 0.05);
        feedback = '😅 Sold on a dip. Ouch!';
      } else {
        change = _portfolio * (_volatility * 0.1);
        feedback = '💰 Sold for a profit!';
        _xp += 5;
      }
    }

    final oldPortfolio = _portfolio;
    _portfolio += change;
    _portfolioAnim = Tween<double>(
      begin: oldPortfolio,
      end: _portfolio,
    ).animate(CurvedAnimation(
      parent: _portfolioController,
      curve: Curves.easeOutBack,
    ));
    _portfolioController.forward(from: 0);

    _updatePriceHistory(change);
    _cryptoIQ += (change > 0 ? 2 : (change < 0 ? -2 : 0));
    _feedback = feedback;

    if (change > 0) {
      _confettiController.play();
    }
  }

  void _showRugPullMinigame() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rug Pull!'),
          content: const Text('Tap EXIT as fast as you can to escape the scam!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _feedback = 'You escaped the scam!';
                  _cryptoIQ += 5;
                });
              },
              child: const Text('EXIT'),
            ),
          ],
        );
      },
    );
  }

  String _determineBadge() {
    if (_badges.contains('🛡 Scam Dodger')) return '🛡 Scam Dodger';
    if (_badges.contains('🐢 Steady HODLer')) return '🐢 Steady HODLer';
    if (_portfolio > 1200) return '🎢 Volatility Surfer';
    if (_portfolio < 800) return '😬 FOMO Victim';
    return '💡 Crypto Learner';
  }

  Widget _buildPriceChart() {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(8),
      child: AnimatedBuilder(
        animation: _chartAnim,
        builder: (context, child) {
          return LineChart(
            LineChartData(
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: _priceHistory.sublist(0, (_priceHistory.length * _chartAnim.value).ceil()),
                  isCurved: true,
                  color: _portfolio >= 1000 ? Colors.green : Colors.red,
                  barWidth: 3,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: (_portfolio >= 1000 ? Colors.green : Colors.red).withOpacity(0.1),
                  ),
                ),
              ],
              minY: _lowestPrice * 0.95,
              maxY: _highestPrice * 1.05,
            ),
          );
        },
      ),
    );
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
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
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
                      child: Text(_coins[_selectedCoin]['emoji'], style: const TextStyle(fontSize: 24)),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _coins[_selectedCoin]['name'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
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
                            'Week $_round/10',
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
                      value: _xp.toString(),
                      label: 'XP',
                    ),
                    const SizedBox(width: 8),
                    _buildStatCard(
                      icon: Icons.account_balance_wallet,
                      color: _portfolio >= 1000 ? Colors.green : Colors.red,
                      value: '€${_portfolioAnim.value.toStringAsFixed(0)}',
                      label: 'Portfolio',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildPriceChart(),
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

  Widget _buildResult() {
    if (_feedback == null) return const SizedBox.shrink();

    final isPositive = _feedback!.contains('🚀') || _feedback!.contains('💰') || _feedback!.contains('🎯') || _feedback!.contains('💎');

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
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: (isPositive ? Colors.green : Colors.red).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    isPositive ? '🎉' : '😬',
                    style: const TextStyle(fontSize: 48),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: (isPositive ? Colors.green : Colors.red).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _feedback!,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isPositive ? Colors.green : Colors.red,
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
    return Stack(
      children: [
        Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _portfolio >= 1000 ? 'Congratulations! 🎉' : 'Game Over',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _portfolio >= 1000 ? Colors.green : Colors.red,
                      ),
                ),
                const SizedBox(height: 32),
                _buildFinalStatsCard(),
                const SizedBox(height: 24),
                _buildBadgesCard(),
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
              Colors.orange,
              Colors.purple,
              Colors.pink,
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFinalStatsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Final Portfolio',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '€${_portfolio.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: _portfolio >= 1000 ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStatPill(
                  label: 'Return',
                  value: '${((_portfolio - 1000) / 10).toStringAsFixed(1)}%',
                  color: _portfolio >= 1000 ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 16),
                _buildStatPill(
                  label: 'Crypto IQ',
                  value: _cryptoIQ.toString(),
                  color: Colors.blue,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatPill({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Achievements',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: _badges
                  .map((badge) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          badge,
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ))
                  .toList(),
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
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
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
              if (!_showIntro && !_gameOver)
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        if (_showEvent) _buildEventCard(),
                        if (_showResult) _buildResult(),
                      ],
                    ),
                  ),
                ),
              if (_gameOver) Expanded(child: _buildGameOver()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: SingleChildScrollView(
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
                      _coins[_selectedCoin]['emoji'],
                      style: const TextStyle(fontSize: 48),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.newspaper, color: Colors.orange),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            _news,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildIndicator('Risk', _risk),
                      const SizedBox(width: 24),
                      _buildIndicator('Trend', _trend),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          text: 'Buy',
                          color: Colors.green,
                          icon: Icons.trending_up,
                          onPressed: () => _chooseMove('Buy'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildActionButton(
                          text: 'Hold',
                          color: Colors.blue,
                          icon: Icons.lock,
                          onPressed: () => _chooseMove('Hold'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildActionButton(
                          text: 'Sell',
                          color: Colors.red,
                          icon: Icons.trending_down,
                          onPressed: () => _chooseMove('Sell'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIndicator(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String text,
    required Color color,
    required IconData icon,
    required VoidCallback onPressed,
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
      ),
      child: Column(
        children: [
          Icon(icon),
          const SizedBox(height: 4),
          Text(text),
        ],
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
                    '🚀 Welcome to Crypto Craze!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Start with €1000 and navigate the volatile world of cryptocurrency. Make smart decisions, avoid scams, and try to grow your portfolio!\n\nYou have 10 rounds to prove your crypto trading skills.',
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
