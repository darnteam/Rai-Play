import 'package:finplay/presentation/widgets/draggable_item.dart';
import 'package:flutter/material.dart';
import '../screens/lemonade_budget_game.dart';

class BudgetCategory extends StatelessWidget {
  final String title;
  final String description;
  final ItemCategory category;
  final List<GameItem> items;
  final Color color;
  final Function(GameItem) onItemDropped;

  const BudgetCategory({
    Key? key,
    required this.title,
    required this.description,
    required this.category,
    required this.items,
    required this.color,
    required this.onItemDropped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          // Category header
          Container(
            padding: const EdgeInsets.all(8),
            color: color,
            child: Column(
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Category content
          Expanded(
            child: DragTarget<GameItem>(
              onAccept: onItemDropped,
              builder: (context, candidateItems, rejectedItems) {
                return Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border.all(color: color),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: items.isEmpty
                      ? Center(
                          child: Text(
                            'Drop items here',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: DraggableItem(item: item),
                            );
                          },
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
