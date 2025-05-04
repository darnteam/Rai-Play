import 'package:equatable/equatable.dart';

enum GameType {
  quiz, // Multiple choice questions
  matching, // Match pairs of related items
  dragAndDrop, // Drag items to correct categories
  tapGame, // Tap the correct answers quickly
  simulation, // Financial simulation (e.g., budget management)
  puzzle, // Puzzle-solving with financial concepts
}

enum GameCategory {
  savings,
  budgeting,
  investing,
  creditCards,
  crypto,
  loans,
  stocks,
  bankAccounts,
  taxes,
  insurance,
}

class Game extends Equatable {
  final String id;
  final String title;
  final String description;
  final GameType type;
  final GameCategory category;
  final int difficultyLevel; // 1-5, with 5 being the hardest
  final String iconUrl;
  final int baseXpReward;
  final int baseCoinReward;
  final int estimatedDurationSecs;
  final bool isTimeLimited;
  final bool isUnlocked;
  final int timesPlayed;

  const Game({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.category,
    required this.difficultyLevel,
    required this.iconUrl,
    required this.baseXpReward,
    required this.baseCoinReward,
    required this.estimatedDurationSecs,
    required this.isTimeLimited,
    required this.isUnlocked,
    this.timesPlayed = 0,
  });

  // Calculate XP reward with potential bonuses
  int calculateXpReward({bool perfectScore = false, bool firstTime = false}) {
    int bonus = 0;
    if (perfectScore) bonus += (baseXpReward * 0.5).round();
    if (firstTime) bonus += (baseXpReward * 0.3).round();
    return baseXpReward + bonus;
  }

  // Calculate coin reward with potential bonuses
  int calculateCoinReward({bool perfectScore = false, bool quickCompletion = false}) {
    int bonus = 0;
    if (perfectScore) bonus += (baseCoinReward * 0.5).round();
    if (quickCompletion) bonus += (baseCoinReward * 0.2).round();
    return baseCoinReward + bonus;
  }

  Game copyWith({
    String? id,
    String? title,
    String? description,
    GameType? type,
    GameCategory? category,
    int? difficultyLevel,
    String? iconUrl,
    int? baseXpReward,
    int? baseCoinReward,
    int? estimatedDurationSecs,
    bool? isTimeLimited,
    bool? isUnlocked,
    int? timesPlayed,
  }) {
    return Game(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      category: category ?? this.category,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      iconUrl: iconUrl ?? this.iconUrl,
      baseXpReward: baseXpReward ?? this.baseXpReward,
      baseCoinReward: baseCoinReward ?? this.baseCoinReward,
      estimatedDurationSecs: estimatedDurationSecs ?? this.estimatedDurationSecs,
      isTimeLimited: isTimeLimited ?? this.isTimeLimited,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      timesPlayed: timesPlayed ?? this.timesPlayed,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        type,
        category,
        difficultyLevel,
        iconUrl,
        baseXpReward,
        baseCoinReward,
        estimatedDurationSecs,
        isTimeLimited,
        isUnlocked,
        timesPlayed,
      ];
}
