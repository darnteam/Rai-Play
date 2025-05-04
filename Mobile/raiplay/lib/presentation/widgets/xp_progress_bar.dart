import 'package:flutter/material.dart';

class XpProgressBar extends StatelessWidget {
  final int currentXp;
  final int nextLevelXp;

  const XpProgressBar({
    super.key,
    required this.currentXp,
    required this.nextLevelXp,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = _calculateProgress();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "XP: $currentXp",
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onPrimary,
              ),
            ),
            Text(
              "Next: $nextLevelXp",
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Stack(
          children: [
            // Background
            Container(
              height: 12,
              decoration: BoxDecoration(
                color: theme.colorScheme.onPrimary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            
            // Progress
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              height: 12,
              width: MediaQuery.of(context).size.width * progress * 0.92, // Adjust for padding
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.tertiary,
                    theme.colorScheme.secondary,
                  ],
                ),
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.tertiary.withOpacity(0.5),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  double _calculateProgress() {
    if (nextLevelXp <= currentXp) return 1.0;
    if (currentXp <= 0) return 0.0;
    
    return currentXp / nextLevelXp;
  }
}