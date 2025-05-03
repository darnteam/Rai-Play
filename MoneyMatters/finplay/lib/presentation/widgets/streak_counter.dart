import 'package:flutter/material.dart';

class StreakCounter extends StatelessWidget {
  final int streakDays;

  const StreakCounter({
    super.key,
    required this.streakDays,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.tertiary,
            theme.colorScheme.tertiary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.tertiary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Flame icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                "🔥",
                style: TextStyle(
                  fontSize: 24,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Streak text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$streakDays-Day Streak!",
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onTertiary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Keep it going to earn bonus XP!",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onTertiary.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          
          // Streak days
          _buildStreakDay(context, 1, true),
          _buildStreakDay(context, 2, true),
          _buildStreakDay(context, 3, true),
          _buildStreakDay(context, 4, true),
          _buildStreakDay(context, 5, streakDays >= 5),
          _buildStreakDay(context, 6, streakDays >= 6),
          _buildStreakDay(context, 7, streakDays >= 7),
        ],
      ),
    );
  }

  Widget _buildStreakDay(BuildContext context, int day, bool completed) {
    final theme = Theme.of(context);
    
    return Container(
      width: 24,
      height: 24,
      margin: const EdgeInsets.only(left: 4),
      decoration: BoxDecoration(
        color: completed 
            ? Colors.white
            : Colors.white.withOpacity(0.3),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          day.toString(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: completed 
                ? theme.colorScheme.tertiary
                : Colors.white.withOpacity(0.7),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}