import '../entities/user.dart';

abstract class UserRepository {
  // Get the current user profile
  Future<User> getCurrentUser();
  
  // Update user details (name, avatar)
  Future<User> updateUser({
    String? name,
    String? avatarUrl,
  });
  
  // Add XP to the user and level up if necessary
  Future<User> addXp(int amount);
  
  // Add or remove coins
  Future<User> updateCoins(int amount);
  
  // Increment the streak counter
  Future<User> incrementStreak();
  
  // Reset the streak if user missed a day
  Future<User> resetStreak();
}