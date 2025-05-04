import 'package:flutter/material.dart';

enum QuestNodeStatus {
  locked,
  active,
  completed,
}

class QuestNode extends StatelessWidget {
  final String title;
  final QuestNodeStatus status;
  final bool isCurrentQuest;
  final VoidCallback onTap;

  const QuestNode({
    super.key,
    required this.title,
    required this.status,
    this.isCurrentQuest = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Determine the appropriate colors based on status
    Color backgroundColor;
    Color borderColor;
    Color textColor = Colors.white;
    
    switch (status) {
      case QuestNodeStatus.completed:
        backgroundColor = const Color(0xFF4CD964); // Green
        borderColor = Colors.white;
        break;
      case QuestNodeStatus.active:
        backgroundColor = const Color(0xFF7D52FF); // Purple
        borderColor = Colors.white;
        break;
      case QuestNodeStatus.locked:
        backgroundColor = Colors.grey.withOpacity(0.5);
        borderColor = Colors.white.withOpacity(0.3);
        textColor = Colors.white.withOpacity(0.7);
        break;
    }
    
    return GestureDetector(
      onTap: status != QuestNodeStatus.locked ? onTap : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Node circle
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: borderColor,
                width: 3,
              ),
              boxShadow: isCurrentQuest && status == QuestNodeStatus.active
                  ? [
                      BoxShadow(
                        color: const Color(0xFF7D52FF).withOpacity(0.5),
                        blurRadius: 12,
                        spreadRadius: 4,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: _buildNodeIcon(),
            ),
          ),
          
          // Quest title
          if (status != QuestNodeStatus.locked) ...[
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(maxWidth: 100),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          
          // Current indicator
          if (isCurrentQuest) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFF9500),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "CURRENT",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNodeIcon() {
    switch (status) {
      case QuestNodeStatus.completed:
        return const Icon(
          Icons.check,
          color: Colors.white,
          size: 28,
        );
      case QuestNodeStatus.active:
        return const Icon(
          Icons.play_arrow,
          color: Colors.white,
          size: 28,
        );
      case QuestNodeStatus.locked:
        return const Icon(
          Icons.lock,
          color: Colors.white,
          size: 24,
        );
    }
  }
}