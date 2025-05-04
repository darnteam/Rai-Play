import 'package:equatable/equatable.dart';
import 'game.dart';

class Video extends Equatable {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String videoUrl;
  final Duration duration;
  final int likes;
  final int views;
  final DateTime publishDate;
  final GameCategory category;
  final int xpReward;
  final bool isWatched;
  final bool isSaved;

  const Video({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.videoUrl,
    required this.duration,
    required this.likes,
    required this.views,
    required this.publishDate,
    required this.category,
    required this.xpReward,
    this.isWatched = false,
    this.isSaved = false,
  });

  Video copyWith({
    String? id,
    String? title,
    String? description,
    String? thumbnailUrl,
    String? videoUrl,
    Duration? duration,
    int? likes,
    int? views,
    DateTime? publishDate,
    GameCategory? category,
    int? xpReward,
    bool? isWatched,
    bool? isSaved,
  }) {
    return Video(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      duration: duration ?? this.duration,
      likes: likes ?? this.likes,
      views: views ?? this.views,
      publishDate: publishDate ?? this.publishDate,
      category: category ?? this.category,
      xpReward: xpReward ?? this.xpReward,
      isWatched: isWatched ?? this.isWatched,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    thumbnailUrl,
    videoUrl,
    duration,
    likes,
    views,
    publishDate,
    category,
    xpReward,
    isWatched,
    isSaved,
  ];
}