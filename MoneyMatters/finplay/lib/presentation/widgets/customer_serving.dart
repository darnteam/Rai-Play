import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CustomerServing extends StatefulWidget {
  final int customersServed;
  final double profit;
  final Map<String, int> stock;
  final Map<String, bool> upgrades;
  final Function() onCustomerServed;
  final VoidCallback onFinish;

  const CustomerServing({
    Key? key,
    required this.customersServed,
    required this.profit,
    required this.stock,
    required this.upgrades,
    required this.onCustomerServed,
    required this.onFinish,
  }) : super(key: key);

  @override
  State<CustomerServing> createState() => _CustomerServingState();
}

class _CustomerServingState extends State<CustomerServing> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isAnimating = false;
  int _goalCustomers = 20;
  double _satisfaction = 1.0;
  int _combo = 0;
  int _maxCombo = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (_isAnimating) return;

    setState(() => _isAnimating = true);
    _animationController.forward().then((_) {
      _animationController.reverse().then((_) {
        setState(() {
          _isAnimating = false;
          widget.onCustomerServed();
          _combo++;
          if (_combo > _maxCombo) {
            _maxCombo = _combo;
          }
          _satisfaction = 1.0 + (_combo * 0.1); // Increase satisfaction with combo

          // Check if goal is reached
          if (widget.customersServed >= _goalCustomers) {
            widget.onFinish();
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Progress and stats
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Customers: ${widget.customersServed}/$_goalCustomers',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Combo: $_combo (Max: $_maxCombo)',
                    style: TextStyle(
                      fontSize: 16,
                      color: _combo > 0 ? Colors.green : Colors.grey,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Profit: \$${widget.profit.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Satisfaction: ${_satisfaction.toStringAsFixed(1)}x',
                    style: TextStyle(
                      fontSize: 16,
                      color: _satisfaction > 1.0 ? Colors.green : Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Customer animation
        Expanded(
          child: Stack(
            children: [
              // Lottie animation
              Center(
                child: Lottie.asset(
                  'assets/lottie/customers.json',
                  width: 300,
                  height: 300,
                ),
              ),

              // Interactive area
              GestureDetector(
                onTap: _handleTap,
                child: Container(
                  color: Colors.transparent,
                ),
              ),

              // Tap animation
              if (_isAnimating)
                Center(
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Text(
                      '🍋',
                      style: TextStyle(
                        fontSize: 64 * _satisfaction,
                        color: Colors.yellow[700],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Progress indicator
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              LinearProgressIndicator(
                value: widget.customersServed / _goalCustomers,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap to serve customers! Keep the combo going!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
