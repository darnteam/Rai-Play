import 'package:flutter/material.dart';

class InventoryDisplay extends StatelessWidget {
  final Map<String, int> stock;
  final Map<String, bool> upgrades;
  final Map<String, String> icons;

  const InventoryDisplay({
    Key? key,
    required this.stock,
    required this.upgrades,
    required this.icons,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        ...stock.entries.map((entry) => _buildStockItem(entry.key, entry.value)),
        ...upgrades.entries.where((entry) => entry.value).map((entry) => _buildUpgradeItem(entry.key)),
      ],
    );
  }

  Widget _buildStockItem(String name, int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(icons[name] ?? '❓'),
        const SizedBox(width: 4),
        Text(
          count.toString(),
          style: TextStyle(
            color: count > 0 ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildUpgradeItem(String name) {
    return Text(icons[name] ?? '❓');
  }
}
