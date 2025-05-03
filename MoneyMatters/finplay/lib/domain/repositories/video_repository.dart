import '../entities/video.dart';
import '../entities/game.dart';

abstract class VideoRepository {
  // Get all videos
  Future<List<Video>> getAllVideos();
  
  // Get videos by category
  Future<List<Video>> getVideosByCategory(GameCategory category);
  
  // Get a specific video by ID
  Future<Video> getVideoById(String id);
  
  // Mark a video as watched and earn XP
  Future<Video> markVideoAsWatched(String id);
  
  // Save a video to favorites
  Future<Video> saveVideo(String id);
  
  // Remove a video from favorites
  Future<Video> unsaveVideo(String id);
  
  // Get saved videos
  Future<List<Video>> getSavedVideos();
  
  // Like a video
  Future<Video> likeVideo(String id);
}