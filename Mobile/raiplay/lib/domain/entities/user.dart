import 'package:RaiPlay/domain/entities/badge.dart';
import 'package:equatable/equatable.dart';


class User extends Equatable {
  final String id;
  final String name;
  final String avatarUrl;
  final int level;
  final int xp;
  final int coins;
  final int streakDays;
  final List<Badge> badges;

  const User({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.level,
    required this.xp,
    required this.coins,
    required this.streakDays,
    required this.badges,
  });

  // Get XP required for next level
  int get nextLevelXp => 100 * (level + 1);

  // Calculate XP progress percentage
  double get xpProgress {
    final int baseXp = 100 * level;
    final int currentLevelXp = xp - baseXp;
    final int requiredXp = 100;
    return currentLevelXp / requiredXp;
  }

  User copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    int? level,
    int? xp,
    int? coins,
    int? streakDays,
    List<Badge>? badges,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      coins: coins ?? this.coins,
      streakDays: streakDays ?? this.streakDays,
      badges: badges ?? this.badges,
    );
  }

  @override
  List<Object?> get props => [id, name, avatarUrl, level, xp, coins, streakDays, badges];
}