import 'package:flutter/material.dart';
import 'draggable_item.dart';
import '../screens/lemonade_budget_game.dart';

class BudgetingScreen extends StatefulWidget {
  final double budget;
  final double spent;
  final double saved;
  final Function(GameItem item) onItemSelected;
  final Function(GameItem item) onItemDeselected;
  final VoidCallback onFinish;

  const BudgetingScreen({
    Key? key,
    required this.budget,
    required this.spent,
    required this.saved,
    required this.onItemSelected,
    required this.onItemDeselected,
    required this.onFinish,
  }) : super(key: key);

  @override
  State<BudgetingScreen> createState() => _BudgetingScreenState();
}

class _BudgetingScreenState extends State<BudgetingScreen> {
  final List<GameItem> _needs = [
    GameItem(
      name: 'Lemons',
      cost: 5.0,
      category: ItemCategory.needs,
      icon: '🍋',
      stock: 10,
      description: 'Essential for making lemonade',
    ),
    GameItem(
      name: 'Sugar',
      cost: 3.0,
      category: ItemCategory.needs,
      icon: '🍬',
      stock: 20,
      description: 'Makes the lemonade sweet',
    ),
    GameItem(
      name: 'Cups',
      cost: 4.0,
      category: ItemCategory.needs,
      icon: '🥤',
      stock: 30,
      description: 'For serving lemonade',
    ),
    GameItem(
      name: 'Ice',
      cost: 2.0,
      category: ItemCategory.needs,
      icon: '🧊',
      stock: 50,
      description: 'Keeps lemonade cold',
    ),
    GameItem(
      name: 'Water',
      cost: 1.0,
      category: ItemCategory.needs,
      icon: '💧',
      stock: 100,
      description: 'Base for lemonade',
    ),
  ];

  final List<GameItem> _wants = [
    GameItem(
      name: 'Umbrella',
      cost: 15.0,
      category: ItemCategory.wants,
      icon: '☂️',
      stock: 1,
      description: 'Protects from sun and rain',
    ),
    GameItem(
      name: 'Sign',
      cost: 8.0,
      category: ItemCategory.wants,
      icon: '📝',
      stock: 1,
      description: 'Attracts more customers',
    ),
    GameItem(
      name: 'Music Player',
      cost: 12.0,
      category: ItemCategory.wants,
      icon: '🎵',
      stock: 1,
      description: 'Creates a fun atmosphere',
    ),
    GameItem(
      name: 'Fancy Cups',
      cost: 10.0,
      category: ItemCategory.wants,
      icon: '🥤',
      stock: 20,
      description: 'Premium cups for higher prices',
    ),
    GameItem(
      name: 'Table',
      cost: 20.0,
      category: ItemCategory.wants,
      icon: '🪑',
      stock: 1,
      description: 'Display area for your stand',
    ),
    GameItem(
      name: 'Balloons',
      cost: 5.0,
      category: ItemCategory.wants,
      icon: '🎈',
      stock: 10,
      description: 'Makes the stand more attractive',
    ),
  ];

  final Map<GameItem, int> _selectedItems = {};
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollLeft() {
    _scrollController.animateTo(
      _scrollController.offset - 140,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollRight() {
    _scrollController.animateTo(
      _scrollController.offset + 140,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _handleFinish() {
    if (_selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one item before finishing.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Count needs and wants
    final needsCount = _selectedItems.entries.where((entry) => entry.key.category == ItemCategory.needs).fold(0, (sum, entry) => sum + entry.value);
    final wantsCount = _selectedItems.entries.where((entry) => entry.key.category == ItemCategory.wants).fold(0, (sum, entry) => sum + entry.value);

    // Calculate total spent on needs and wants
    final needsSpent =
        _selectedItems.entries.where((entry) => entry.key.category == ItemCategory.needs).fold(0.0, (sum, entry) => sum + (entry.key.cost * entry.value));
    final wantsSpent =
        _selectedItems.entries.where((entry) => entry.key.category == ItemCategory.wants).fold(0.0, (sum, entry) => sum + (entry.key.cost * entry.value));

    // Calculate percentages
    final totalSpent = needsSpent + wantsSpent;
    final needsPercentage = (needsSpent / totalSpent) * 100;
    final wantsPercentage = (wantsSpent / totalSpent) * 100;

    // Generate feedback
    String feedback = '';
    if (needsCount < wantsCount) {
      feedback = 'You have more wants than needs. Remember to prioritize essential items first!';
    } else if (needsSpent < wantsSpent) {
      feedback = 'You\'re spending more on wants than needs. Make sure you have enough for essentials!';
    } else if (needsPercentage >= 70) {
      feedback = 'Great job! You\'ve prioritized your needs, which is the right approach for a successful business.';
    } else if (needsPercentage >= 50) {
      feedback = 'Good balance between needs and wants. Consider if you really need all those extra items.';
    }

    // Show feedback dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Budget Review'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You selected:'),
            const SizedBox(height: 8),
            Text('• ${needsCount} needs items (${needsSpent.toStringAsFixed(2)}\$ - ${needsPercentage.toStringAsFixed(1)}%)'),
            Text('• ${wantsCount} wants items (${wantsSpent.toStringAsFixed(2)}\$ - ${wantsPercentage.toStringAsFixed(1)}%)'),
            const SizedBox(height: 16),
            if (feedback.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: needsPercentage >= 70 ? Colors.green[50] : Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: needsPercentage >= 70 ? Colors.green : Colors.orange,
                  ),
                ),
                child: Text(
                  feedback,
                  style: TextStyle(
                    color: needsPercentage >= 70 ? Colors.green[700] : Colors.orange[700],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            const Text(
              'Tips:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('• Prioritize needs (lemons, sugar, cups) over wants'),
            const Text('• Aim to spend at least 70% of your budget on needs'),
            const Text('• Save some money for unexpected expenses'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Go Back'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onFinish();
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Budget summary
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildBudgetInfo('Budget', '\$${widget.budget.toStringAsFixed(2)}'),
              ),
              Expanded(
                child: _buildBudgetInfo('Spent', '\$${widget.spent.toStringAsFixed(2)}'),
              ),
              Expanded(
                child: _buildBudgetInfo('Saved', '\$${widget.saved.toStringAsFixed(2)}'),
              ),
            ],
          ),
        ),

        // Available items (horizontal scrollable)
        Container(
          height: 200,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Available Items',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: [
                          ..._needs.map((item) => Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: SizedBox(
                                  width: 120,
                                  child: DraggableItem(
                                    item: item,
                                    isDragging: _selectedItems.containsKey(item),
                                  ),
                                ),
                              )),
                          ..._wants.map((item) => Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: SizedBox(
                                  width: 120,
                                  child: DraggableItem(
                                    item: item,
                                    isDragging: _selectedItems.containsKey(item),
                                  ),
                                ),
                              )),
                        ],
                      ),
                    ),
                    // Navigation buttons
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: _scrollLeft,
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white,
                            elevation: 4,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: _scrollRight,
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white,
                            elevation: 4,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Selected items table
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                // Table header
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Item',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Quantity',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Total',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
                // Table content
                Expanded(
                  child: DragTarget<GameItem>(
                    onWillAccept: (item) {
                      if (item == null) return false;
                      if (_selectedItems.containsKey(item)) {
                        setState(() {
                          _selectedItems[item] = (_selectedItems[item] ?? 0) + 1;
                          widget.onItemSelected(item);
                        });
                        return false;
                      }
                      return true;
                    },
                    onAccept: (item) {
                      if (widget.spent + item.cost <= widget.budget) {
                        setState(() {
                          _selectedItems[item] = 1;
                          widget.onItemSelected(item);
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Not enough budget for this item!'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    builder: (context, candidateItems, rejectedItems) {
                      return ListView.builder(
                        itemCount: _selectedItems.length,
                        itemBuilder: (context, index) {
                          final item = _selectedItems.keys.elementAt(index);
                          final quantity = _selectedItems[item]!;
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.grey[300]!),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Row(
                                    children: [
                                      Text(item.icon),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          item.name,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove, size: 20),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: quantity > 1
                                            ? () {
                                                setState(() {
                                                  _selectedItems[item] = quantity - 1;
                                                  widget.onItemDeselected(item);
                                                });
                                              }
                                            : null,
                                      ),
                                      const SizedBox(width: 8),
                                      Text('$quantity'),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(Icons.add, size: 20),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: widget.spent + item.cost <= widget.budget
                                            ? () {
                                                setState(() {
                                                  _selectedItems[item] = quantity + 1;
                                                  widget.onItemSelected(item);
                                                });
                                              }
                                            : null,
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    '\$${(item.cost * quantity).toStringAsFixed(2)}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        // Finish button
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _handleFinish,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text(
              'Finish Budgeting',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetInfo(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
