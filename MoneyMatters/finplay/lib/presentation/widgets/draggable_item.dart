import 'package:flutter/material.dart';
import '../screens/lemonade_budget_game.dart';

class DraggableItem extends StatelessWidget {
  final GameItem item;
  final bool isDragging;

  const DraggableItem({
    Key? key,
    required this.item,
    this.isDragging = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Draggable<GameItem>(
      data: item,
      feedback: _buildItemCard(
        context,
        opacity: 0.8,
        elevation: 8,
      ),
      childWhenDragging: _buildItemCard(
        context,
        opacity: 0.3,
      ),
      child: _buildItemCard(
        context,
        opacity: isDragging ? 0.3 : 1.0,
      ),
    );
  }

  Widget _buildItemCard(
    BuildContext context, {
    required double opacity,
    double elevation = 2,
  }) {
    return Card(
      elevation: elevation,
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              item.icon,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 4),
            Text(
              item.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              '\$${item.cost.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (item.stock > 0) ...[
              const SizedBox(height: 4),
              Text(
                'Stock: ${item.stock}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
