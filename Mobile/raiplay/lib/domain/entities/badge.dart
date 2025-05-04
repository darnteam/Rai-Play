import 'package:equatable/equatable.dart';

class Badge extends Equatable {
  final String id;
  final String name;
  final String description;
  final String iconUrl;
  final DateTime dateEarned;
  final BadgeType type;
  final int rarity; // 1-5, with 5 being the rarest

  const Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.dateEarned,
    required this.type,
    required this.rarity,
  });

  @override
  List<Object?> get props => [id, name, description, iconUrl, dateEarned, type, rarity];
}

enum BadgeType {
  savings,
  budgeting,
  investing,
  creditCards,
  crypto,
  loans,
  stocks,
  achievement, // general achievements like streaks
}