import '../entities/quest.dart';

abstract class QuestRepository {
  // Get all quests
  Future<List<Quest>> getAllQuests();
  
  // Get quests by type (daily, story, challenge)
  Future<List<Quest>> getQuestsByType(QuestType type);
  
  // Get a specific quest by ID
  Future<Quest> getQuestById(String id);
  
  // Get available quests
  Future<List<Quest>> getAvailableQuests();
  
  // Get daily quests
  Future<List<Quest>> getDailyQuests();
  
  // Get story quests
  Future<List<Quest>> getStoryQuests();
  
  // Start a quest (change status to in progress)
  Future<Quest> startQuest(String id);
  
  // Complete a quest
  Future<Quest> completeQuest(String id);
  
  // Unlock a quest
  Future<Quest> unlockQuest(String id);
}