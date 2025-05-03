import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import 'dart:math';
import '../widgets/quest_node.dart';
import 'lemonade_budget_game.dart';

class QuestMapScreen extends ConsumerStatefulWidget {
  const QuestMapScreen({super.key});

  @override
  ConsumerState<QuestMapScreen> createState() => _QuestMapScreenState();
}

class _QuestMapScreenState extends ConsumerState<QuestMapScreen> with TickerProviderStateMixin {
  // Mock data for quest nodes
  List<_QuestNodeData> _questNodes = [
    _QuestNodeData(
      id: 'node1',
      title: 'The Lemonade Budget',
      description: 'Build Alice\'s lemonade stand budget: Drag ingredients and promo items into Needs, Wants, and Save jars. Finish under €20!',
      xpReward: 20,
      coinReward: 15,
      status: QuestNodeStatus.active,
      position: const Offset(0.2, 0.1),
      isCurrentQuest: true,
    ),
    _QuestNodeData(
      id: 'node2',
      title: 'Climbing the Savings Tower',
      description: 'Each week, help Alice choose to spend or save. Skip temptations to unlock a Savings Booster!',
      xpReward: 30,
      coinReward: 25,
      status: QuestNodeStatus.locked,
      position: const Offset(0.5, 0.2),
    ),
    _QuestNodeData(
      id: 'node3',
      title: 'The Credit Maze',
      description: 'Navigate the mall maze: Pay in full, pay minimum, or skip. Alice\'s credit score changes with each choice.',
      xpReward: 40,
      coinReward: 35,
      status: QuestNodeStatus.locked,
      position: const Offset(0.8, 0.3),
    ),
    _QuestNodeData(
      id: 'node4',
      title: 'Crypto Craze Carnival',
      description: 'Spin the wheel at crypto booths. Invest, skip, or research. Watch out for scams and FOMO! Reflex minigames included.',
      xpReward: 50,
      coinReward: 40,
      status: QuestNodeStatus.locked,
      position: const Offset(0.7, 0.5),
    ),
    _QuestNodeData(
      id: 'node5',
      title: 'Bank City Begins',
      description: 'Simulate banking: Transfer, avoid overdrafts, set auto-save, and spot suspicious activity in Alice\'s new city life.',
      xpReward: 60,
      coinReward: 45,
      status: QuestNodeStatus.locked,
      position: const Offset(0.4, 0.6),
    ),
    _QuestNodeData(
      id: 'node6',
      title: 'Investor Island',
      description: 'Pick 2 assets per round for 5 years. Diversify and grow Alice\'s savings. Get a performance grade at the end!',
      xpReward: 70,
      coinReward: 50,
      status: QuestNodeStatus.locked,
      position: const Offset(0.2, 0.8),
    ),
    _QuestNodeData(
      id: 'node7',
      title: 'The Financial Festival',
      description: 'Flashback quiz: What would Alice do? Make the right choices and earn the Financial Hero badge!',
      xpReward: 80,
      coinReward: 60,
      status: QuestNodeStatus.locked,
      position: const Offset(0.5, 0.9),
    ),
  ];

  bool _completionDialogShown = false;
  bool _initialized = false;

  // Initialize animations with late final instead of late
  late final AnimationController _fadeController;
  late final AnimationController _scaleController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    print('QuestMapScreen initState');

    // Initialize animation controllers first
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Initialize animations
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutBack,
    );

    // Start animations
    _fadeController.forward();
    _scaleController.forward();

    // Initialize game state
    _updateCompletedQuestsCount();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('QuestMapScreen didChangeDependencies');

    if (!_initialized) {
      _initialized = true;
      _checkForCompletion();
    }
  }

  void _checkForCompletion() {
    print('Checking for completion');
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    print('Received arguments: $args');

    if (args != null && args['gameCompleted'] == true && !_completionDialogShown) {
      _completionDialogShown = true;
      print('Game completed, updating quest status');

      // Ensure we're mounted and the state is ready
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          // Update quest status
          updateQuestStatus('node1', QuestNodeStatus.completed);

          // Show completion animation after a short delay
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              _showCompletionAnimation();
            }
          });
        }
      });
    }
  }

  void updateQuestStatus(String questId, QuestNodeStatus newStatus) {
    print('Updating quest status: $questId to $newStatus');
    setState(() {
      final currentIndex = _questNodes.indexWhere((node) => node.id == questId);
      if (currentIndex != -1) {
        print('Found quest at index: $currentIndex');

        // Create a new list to ensure state update
        List<_QuestNodeData> updatedNodes = List.from(_questNodes);

        // Update current quest status
        updatedNodes[currentIndex] = updatedNodes[currentIndex].copyWith(
          status: newStatus,
          isCurrentQuest: false,
        );

        // If there's a next quest, unlock it
        if (currentIndex + 1 < updatedNodes.length) {
          print('Unlocking next quest at index: ${currentIndex + 1}');
          updatedNodes[currentIndex + 1] = updatedNodes[currentIndex + 1].copyWith(
            status: QuestNodeStatus.active,
            isCurrentQuest: true,
          );
        }

        // Update the nodes list
        _questNodes = updatedNodes;

        // Update the completed quests count
        _updateCompletedQuestsCount();
      } else {
        print('Quest not found: $questId');
      }
    });
  }

  void _updateCompletedQuestsCount() {
    final completedCount = _questNodes.where((node) => node.status == QuestNodeStatus.completed).length;
    final totalCount = _questNodes.length;
    setState(() {
      _completedQuestsCount = '$completedCount/$totalCount';
    });
  }

  String _completedQuestsCount = '0/7';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Stack(
        children: [
          // Animated background gradient
          AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) => Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.lerp(
                      const Color(0xFF1A237E), // Deep Indigo
                      const Color(0xFF283593),
                      _fadeAnimation.value,
                    )!,
                    Color.lerp(
                      const Color(0xFF0277BD), // Light Blue
                      const Color(0xFF0288D1),
                      _fadeAnimation.value,
                    )!,
                    Color.lerp(
                      const Color(0xFF00BCD4), // Cyan
                      const Color(0xFF26C6DA),
                      _fadeAnimation.value,
                    )!,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // Animated wave pattern with updated color
          Positioned.fill(
            child: CustomPaint(
              painter: WavePatternPainter(
                animation: _fadeAnimation,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),

          // Quest map with custom painter for paths
          CustomPaint(
            size: Size(size.width, size.height),
            painter: QuestPathPainter(_questNodes),
          ),

          // Quest nodes with scale animation
          ..._questNodes.map((quest) {
            return Positioned(
              left: quest.position.dx * size.width,
              top: quest.position.dy * size.height,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: QuestNode(
                  title: quest.title,
                  status: quest.status,
                  isCurrentQuest: quest.isCurrentQuest,
                  onTap: () {
                    if (quest.status != QuestNodeStatus.locked) {
                      _showQuestDetails(context, quest);
                    }
                  },
                ),
              ),
            );
          }).toList(),

          // App bar with modern design
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Row(
                  children: [
                    // Back button with glass effect
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back),
                            color: Colors.white,
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Title with modern typography
                    Text(
                      'Quest Map',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            offset: const Offset(1, 1),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Quest counter with glass effect
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.flag,
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _completedQuestsCount,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
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
          ),
        ],
      ),
    );
  }

  void _showQuestDetails(BuildContext context, _QuestNodeData quest) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Sheet handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Quest header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.star,
                              color: theme.colorScheme.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  quest.title,
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  quest.status == QuestNodeStatus.completed
                                      ? 'Completed'
                                      : quest.status == QuestNodeStatus.active
                                          ? 'In Progress'
                                          : 'Locked',
                                  style: TextStyle(
                                    color: quest.status == QuestNodeStatus.completed
                                        ? Colors.green
                                        : quest.status == QuestNodeStatus.active
                                            ? theme.colorScheme.primary
                                            : Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Quest description
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                          ),
                        ),
                        child: Text(
                          quest.description,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            height: 1.5,
                            color: theme.colorScheme.onSurface.withOpacity(0.8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Quest rewards
                      Text(
                        "Rewards",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildRewardCard(
                              theme,
                              Icons.star,
                              "${quest.xpReward} XP",
                              Colors.amber,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildRewardCard(
                              theme,
                              Icons.monetization_on,
                              "${quest.coinReward} Coins",
                              Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Quest objectives
                      Text(
                        "Objectives",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildObjectiveItem(
                        theme,
                        "Complete the main challenge",
                        quest.status == QuestNodeStatus.completed,
                      ),
                      _buildObjectiveItem(
                        theme,
                        "Score at least 80%",
                        quest.status == QuestNodeStatus.completed,
                      ),
                      _buildObjectiveItem(
                        theme,
                        "Learn key financial concepts",
                        quest.status == QuestNodeStatus.completed,
                      ),
                      const SizedBox(height: 32),

                      // Action button
                      SizedBox(
                        width: double.infinity,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: quest.status != QuestNodeStatus.completed
                                  ? [theme.colorScheme.primary, theme.colorScheme.secondary]
                                  : [Colors.grey, Colors.grey.shade600],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: (quest.status != QuestNodeStatus.completed ? theme.colorScheme.primary : Colors.grey).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: quest.status != QuestNodeStatus.completed
                                ? () {
                                    Navigator.pop(context);
                                    if (quest.id == 'node1') {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const LemonadeBudgetGame(),
                                        ),
                                      ).then((result) {
                                        if (result is Map<String, dynamic> && result['gameCompleted'] == true) {
                                          updateQuestStatus('node1', QuestNodeStatus.completed);
                                          _showCompletionAnimation();
                                        }
                                      });
                                    }
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              quest.status == QuestNodeStatus.active
                                  ? "Continue Quest"
                                  : quest.status == QuestNodeStatus.completed
                                      ? "Completed"
                                      : "Start Quest",
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRewardCard(ThemeData theme, IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            text,
            style: theme.textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildObjectiveItem(ThemeData theme, String objective, bool isCompleted) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isCompleted ? theme.colorScheme.secondary : theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
              boxShadow: isCompleted
                  ? [
                      BoxShadow(
                        color: theme.colorScheme.secondary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Icon(
                isCompleted ? Icons.check : Icons.radio_button_unchecked,
                color: isCompleted ? theme.colorScheme.onSecondary : theme.colorScheme.primary,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              objective,
              style: theme.textTheme.bodyLarge?.copyWith(
                decoration: isCompleted ? TextDecoration.lineThrough : null,
                color: isCompleted ? theme.colorScheme.onSurface.withOpacity(0.5) : theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCompletionAnimation() {
    print('Showing completion animation');
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                'Quest Map Updated!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your progress has been saved and the next quest is now available!',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  setState(() {
                    _completionDialogShown = false;
                  });
                },
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuestNodeData {
  final String id;
  final String title;
  final String description;
  final int xpReward;
  final int coinReward;
  final QuestNodeStatus status;
  final Offset position;
  final bool isCurrentQuest;

  _QuestNodeData({
    required this.id,
    required this.title,
    required this.description,
    required this.xpReward,
    required this.coinReward,
    required this.status,
    required this.position,
    this.isCurrentQuest = false,
  });

  _QuestNodeData copyWith({
    String? id,
    String? title,
    String? description,
    int? xpReward,
    int? coinReward,
    QuestNodeStatus? status,
    Offset? position,
    bool? isCurrentQuest,
  }) {
    return _QuestNodeData(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      xpReward: xpReward ?? this.xpReward,
      coinReward: coinReward ?? this.coinReward,
      status: status ?? this.status,
      position: position ?? this.position,
      isCurrentQuest: isCurrentQuest ?? this.isCurrentQuest,
    );
  }
}

class QuestPathPainter extends CustomPainter {
  final List<_QuestNodeData> nodes;

  QuestPathPainter(this.nodes);

  @override
  void paint(Canvas canvas, Size size) {
    // Sort nodes by status to draw paths correctly
    final completedNodes = nodes.where((node) => node.status == QuestNodeStatus.completed).toList();
    final activeNodes = nodes.where((node) => node.status == QuestNodeStatus.active).toList();
    final lockedNodes = nodes.where((node) => node.status == QuestNodeStatus.locked).toList();

    final activePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final completedPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final lockedPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Draw paths between nodes
    for (int i = 0; i < nodes.length - 1; i++) {
      final startNode = nodes[i];
      final endNode = nodes[i + 1];

      final startPoint = Offset(
        startNode.position.dx * size.width,
        startNode.position.dy * size.height,
      );

      final endPoint = Offset(
        endNode.position.dx * size.width,
        endNode.position.dy * size.height,
      );

      // Control points for curved paths
      final controlPoint1 = Offset(
        startPoint.dx + (endPoint.dx - startPoint.dx) * 0.5,
        startPoint.dy,
      );

      final controlPoint2 = Offset(
        startPoint.dx + (endPoint.dx - startPoint.dx) * 0.5,
        endPoint.dy,
      );

      final path = Path()
        ..moveTo(startPoint.dx, startPoint.dy)
        ..cubicTo(
          controlPoint1.dx,
          controlPoint1.dy,
          controlPoint2.dx,
          controlPoint2.dy,
          endPoint.dx,
          endPoint.dy,
        );

      // Choose paint based on node status
      Paint paint;
      if (startNode.status == QuestNodeStatus.completed && endNode.status == QuestNodeStatus.completed) {
        paint = completedPaint;
      } else if (startNode.status == QuestNodeStatus.completed && endNode.status == QuestNodeStatus.active) {
        paint = activePaint;
      } else {
        paint = lockedPaint;
        // For locked paths, draw dashed lines
        final dashPath = Path();
        final pathMetrics = path.computeMetrics().first;
        final dashWidth = 8.0;
        final dashSpace = 4.0;
        var distance = 0.0;

        while (distance < pathMetrics.length) {
          final next = distance + dashWidth;
          if (next > pathMetrics.length) {
            dashPath.addPath(
              pathMetrics.extractPath(distance, pathMetrics.length),
              Offset.zero,
            );
          } else {
            dashPath.addPath(
              pathMetrics.extractPath(distance, next),
              Offset.zero,
            );
          }
          distance = next + dashSpace;
        }

        canvas.drawPath(dashPath, lockedPaint);
        continue; // Skip the normal path drawing for locked paths
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

// Add this new painter class for the wave pattern
class WavePatternPainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;

  WavePatternPainter({required this.animation, required this.color}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path();
    final waveHeight = 20.0;
    final frequency = 0.02;
    final horizontalOffset = animation.value * 50;

    for (var i = 0; i < size.height; i += 40) {
      path.moveTo(0, i.toDouble());
      for (var x = 0.0; x <= size.width; x++) {
        final y = i + sin((x + horizontalOffset) * frequency) * waveHeight;
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WavePatternPainter oldDelegate) => true;
}
