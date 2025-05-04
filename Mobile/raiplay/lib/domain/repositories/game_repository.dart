import '../entities/game.dart';

abstract class GameRepository {
  // Get all games
  Future<List<Game>> getAllGames();
  
  // Get games by category
  Future<List<Game>> getGamesByCategory(GameCategory category);
  
  // Get a specific game by ID
  Future<Game> getGameById(String id);
  
  // Get unlocked games
  Future<List<Game>> getUnlockedGames();
  
  // Unlock a game
  Future<Game> unlockGame(String id);
  
  // Update game play count
  Future<Game> updateGamePlayCount(String id);
}