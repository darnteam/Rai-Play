import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/streak_counter.dart';
import '../widgets/daily_quest_card.dart';
import '../widgets/animated_button.dart';
import '../theme/app_theme.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final int streak = 5; // Mock data

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Custom App Bar with gradient and profile
          SliverAppBar(
            expandedHeight: 190,
            floating: false,
            pinned: true,
            backgroundColor: AppTheme.raiffeisen['primary'],
            flexibleSpace: FlexibleSpaceBar(
              expandedTitleScale: 1.0,
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      AppTheme.raiffeisen['primary']!,
                      AppTheme.raiffeisen['primary']!.withOpacity(0.9),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: AppTheme.raiffeisen['secondary'],
                              child: Text(
                                'A',
                                style: TextStyle(
                                  color: AppTheme.raiffeisen['primary'],
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome back,',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: AppTheme.raiffeisen['secondary'],
                                    ),
                                  ),
                                  Text(
                                    'Artin',
                                    style: theme.textTheme.headlineMedium?.copyWith(
                                      color: AppTheme.raiffeisen['secondary'],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppTheme.raiffeisen['secondary'],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: AppTheme.raiffeisen['primary'],
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Level 5',
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: AppTheme.raiffeisen['primary'],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // XP Progress Bar
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '920 XP',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: AppTheme.raiffeisen['secondary'],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Next Level: 1,300 XP',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: AppTheme.raiffeisen['secondary'],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppTheme.raiffeisen['secondary']!.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: FractionallySizedBox(
                                widthFactor: 0.70, // 1220/1300
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppTheme.raiffeisen['secondary'],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Coins Display
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Main Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Overview
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            _buildStatItem(
                              context,
                              Icons.trending_up,
                              'Total XP',
                              '920',
                            ),
                            _buildStatItem(
                              context,
                              Icons.monetization_on,
                              'Coins',
                              '540',
                            ),
                            _buildStatItem(
                              context,
                              Icons.emoji_events,
                              'Badges',
                              '8',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Streak Counter with improved design
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.raiffeisen['primary']!.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.local_fire_department,
                                color: AppTheme.raiffeisen['secondary'],
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Current Streak',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: AppTheme.raiffeisen['textSecondary'],
                                  ),
                                ),
                                Text(
                                  '$streak Days',
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    color: AppTheme.raiffeisen['secondary'],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.raiffeisen['primary']!.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: AppTheme.raiffeisen['secondary'],
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '+50 XP',
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: AppTheme.raiffeisen['secondary'],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(
                            7,
                            (index) => _buildStreakDay(
                              context,
                              index < streak,
                              ['M', 'T', 'W', 'T', 'F', 'S', 'S'][index],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Today's Quests Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Today's Quests",
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: AppTheme.raiffeisen['textPrimary'],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.raiffeisen['primary']!.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.task_alt,
                              color: AppTheme.raiffeisen['secondary'],
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '2/3 Complete',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: AppTheme.raiffeisen['secondary'],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Next Quest from Quest Map
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildQuestItem(
                          context,
                          "Complete 'The Lemonade Budget'",
                          "Help Alice start her first business venture!",
                          Icons.business_center,
                          50,
                          100,
                          0,
                          1,
                          true,
                          () {
                            // Navigate to the quest
                          },
                        ),
                        const Divider(height: 1),
                        _buildQuestItem(
                          context,
                          "Play 'Budget Rush'",
                          "Make quick spending decisions under pressure",
                          Icons.timer,
                          30,
                          50,
                          0,
                          1,
                          false,
                          () {
                            // Navigate to the game
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Leaderboard Section with new design
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Leaderboard",
                              style: theme.textTheme.titleLarge,
                            ),
                            TextButton(
                              onPressed: () {},
                              child: const Text("View All"),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildLeaderboardEntry(context, 1, "Sarah M.", 2500, true),
                        _buildLeaderboardEntry(context, 2, "John D.", 2350, false),
                        _buildLeaderboardEntry(context, 3, "Alice", 2200, false),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Badges Section with new design
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Recent Badges",
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: AppTheme.raiffeisen['textPrimary'],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {},
                        icon: Icon(
                          Icons.emoji_events,
                          color: AppTheme.raiffeisen['secondary'],
                          size: 16,
                        ),
                        label: Text(
                          "View All",
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: AppTheme.raiffeisen['secondary'],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildBadge(context, "Savings Master", Icons.savings, true),
                        _buildBadge(context, "Budget Pro", Icons.account_balance_wallet, true),
                        _buildBadge(context, "Investment Guru", Icons.trending_up, false),
                        _buildBadge(context, "Smart Spender", Icons.shopping_cart, false),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Call to action button with new design
                  Center(
                    child: AnimatedButton(
                      onPressed: () {
                        // Navigate to the quest map
                      },
                      text: "Continue Your Journey",
                      icon: Icons.play_arrow,
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardEntry(BuildContext context, int position, String name, int xp, bool isTop) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isTop ? AppTheme.raiffeisen['primary']!.withOpacity(0.2) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isTop ? Border.all(color: AppTheme.raiffeisen['secondary']!, width: 2) : Border.all(color: AppTheme.raiffeisen['divider']!),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isTop ? AppTheme.raiffeisen['secondary'] : AppTheme.raiffeisen['primary']!.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                position.toString(),
                style: TextStyle(
                  color: isTop ? AppTheme.raiffeisen['primary'] : AppTheme.raiffeisen['secondary'],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            name,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.raiffeisen['secondary'],
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Icon(
                Icons.star,
                color: AppTheme.raiffeisen['secondary'],
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                xp.toString(),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.raiffeisen['secondary'],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(BuildContext context, String title, IconData icon, bool isEarned) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isEarned ? AppTheme.raiffeisen['primary']!.withOpacity(0.1) : AppTheme.raiffeisen['secondary']!.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isEarned ? AppTheme.raiffeisen['secondary']!.withOpacity(0.1) : AppTheme.raiffeisen['divider']!,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isEarned ? AppTheme.raiffeisen['secondary'] : AppTheme.raiffeisen['secondary']!.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isEarned ? AppTheme.raiffeisen['primary'] : AppTheme.raiffeisen['secondary']!.withOpacity(0.3),
                  size: 24,
                ),
              ),
              if (isEarned)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: AppTheme.raiffeisen['primary'],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.check,
                      color: AppTheme.raiffeisen['secondary'],
                      size: 10,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppTheme.raiffeisen['secondary'],
                  fontWeight: isEarned ? FontWeight.bold : FontWeight.normal,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.raiffeisen['primary']!.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppTheme.raiffeisen['secondary'],
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.titleSmall?.copyWith(
              color: AppTheme.raiffeisen['textSecondary'],
            ),
          ),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              color: AppTheme.raiffeisen['secondary'],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakDay(BuildContext context, bool isCompleted, String day) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isCompleted ? AppTheme.raiffeisen['secondary'] : AppTheme.raiffeisen['primary']!.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              isCompleted ? Icons.check : Icons.circle_outlined,
              color: isCompleted ? AppTheme.raiffeisen['primary'] : AppTheme.raiffeisen['secondary']!.withOpacity(0.3),
              size: 20,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          day,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.raiffeisen['textSecondary'],
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }

  Widget _buildQuestItem(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    int xpReward,
    int coinReward,
    int progress,
    int total,
    bool isHighlighted,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isHighlighted ? AppTheme.raiffeisen['primary']!.withOpacity(0.1) : AppTheme.raiffeisen['secondary']!.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppTheme.raiffeisen['secondary'],
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.raiffeisen['secondary'],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.raiffeisen['textSecondary'],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.raiffeisen['primary']!.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              color: AppTheme.raiffeisen['secondary'],
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '+$xpReward XP',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppTheme.raiffeisen['secondary'],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.raiffeisen['primary']!.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.monetization_on,
                              color: AppTheme.raiffeisen['secondary'],
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '+$coinReward',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppTheme.raiffeisen['secondary'],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppTheme.raiffeisen['secondary'],
            ),
          ],
        ),
      ),
    );
  }
}
