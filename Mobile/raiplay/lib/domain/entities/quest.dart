import 'package:equatable/equatable.dart';

enum QuestType {
  daily,
  story,
  challenge,
}

enum QuestStatus {
  locked,
  available,
  inProgress,
  completed,
}

class Quest extends Equatable {
  final String id;
  final String title;
  final String description;
  final int xpReward;
  final int coinReward;
  final String? badgeId;
  final QuestType type;
  final QuestStatus status;
  final String iconUrl;
  final List<String> gameIds; // IDs of games that are part of this quest
  final DateTime? completedDate;
  final DateTime createdDate;
  final DateTime expiryDate; // Only applicable for daily quests

  const Quest({
    required this.id,
    required this.title,
    required this.description,
    required this.xpReward,
    required this.coinReward,
    this.badgeId,
    required this.type,
    required this.status,
    required this.iconUrl,
    required this.gameIds,
    this.completedDate,
    required this.createdDate,
    required this.expiryDate,
  });

  bool get isExpired => DateTime.now().isAfter(expiryDate);
  
  bool get canStart => status == QuestStatus.available;
  
  bool get isCompleted => status == QuestStatus.completed;

  Quest copyWith({
    String? id,
    String? title,
    String? description,
    int? xpReward,
    int? coinReward,
    String? badgeId,
    QuestType? type,
    QuestStatus? status,
    String? iconUrl,
    List<String>? gameIds,
    DateTime? completedDate,
    DateTime? createdDate,
    DateTime? expiryDate,
  }) {
    return Quest(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      xpReward: xpReward ?? this.xpReward,
      coinReward: coinReward ?? this.coinReward,
      badgeId: badgeId ?? this.badgeId,
      type: type ?? this.type,
      status: status ?? this.status,
      iconUrl: iconUrl ?? this.iconUrl,
      gameIds: gameIds ?? this.gameIds,
      completedDate: completedDate ?? this.completedDate,
      createdDate: createdDate ?? this.createdDate,
      expiryDate: expiryDate ?? this.expiryDate,
    );
  }

  @override
  List<Object?> get props => [
    id, 
    title, 
    description, 
    xpReward, 
    coinReward, 
    badgeId, 
    type, 
    status, 
    iconUrl, 
    gameIds, 
    completedDate, 
    createdDate, 
    expiryDate
  ];
}