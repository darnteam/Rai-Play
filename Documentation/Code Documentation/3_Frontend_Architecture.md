# Frontend Architecture

This document details the architecture of the RaiPlay mobile application built with Flutter.

## Application Structure

The mobile application follows a structured architecture with clear separation of concerns:

```
lib/
├── main.dart              # Entry point for the application
├── presentation/          # UI layer
│   ├── screens/           # Full screens of the application
│   ├── widgets/           # Reusable UI components
│   └── theme/             # Application theming
├── services/              # Communication with backend
├── models/                # Data models
├── providers/             # State management with Riverpod
└── utils/                 # Helper functions and utilities
```

## Key Components

### Presentation Layer

The presentation layer is responsible for all UI interactions and is organized into:

#### Screens

Full-page UI components representing different sections of the app:

- **Home Screen**: Central dashboard showing user progress, streaks, and activities
- **Games Screen**: List of available financial literacy games
- **Quest Map**: Visual progression map of the learning journey
- **Video Library**: Educational financial content
- **Chat Screen**: AI-powered financial assistant
- **Profile**: User information and achievements
- **Leaderboard**: User rankings based on XP

#### Widgets

Reusable UI components that appear across multiple screens:

- **StreakCounter**: Visual representation of user's daily activity streak
- **XPProgressBar**: Progress indicator for user's level advancement
- **GameCard**: Game selection component with description and rewards
- **VideoPlayerCard**: Video player with controls and description
- **BudgetCategory**: Category selection for budgeting activities
- **QuestNode**: Individual node in the quest progression map
- **AnimatedButton**: Engaging interactive buttons with animations

### Services Layer

The services layer handles all communication with the backend:

#### ApiService

Centralized service that handles all HTTP requests to the backend endpoints:

```dart
class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  // Authentication methods
  static Future<Map<String, dynamic>> login(String username, String password);
  static Future<Map<String, dynamic>> signup(String username, String email, String password);

  // User methods
  static Future<UserData> getUserProfile();
  static Future<List<UserData>> getLeaderboard();
  static Future<List<Achievement>> getUserBadges();

  // Games methods
  static Future<List<Game>> getGames(bool completed);
  static Future<List<Game>> getMiniGames();
  static Future<List<Game>> getQuestStoryline();
  static Future<void> completeGame(int gameId);

  // Videos methods
  static Future<List<Video>> getAllVideos();
  static Future<List<Video>> getSavedVideos();

  // Chat methods
  static Future<String> chat(String message);
}
```

### State Management

The application uses Riverpod for state management, with providers for:

- **Authentication State**: Manages user login status and credentials
- **User State**: Handles user profile data and achievements
- **Games State**: Tracks available games and completion status
- **Video State**: Manages video library and saved content
- **Chat State**: Handles conversation history with AI assistant

## UI/UX Design

The application follows a cohesive design language for financial education:

- **Color Scheme**: Raiffeisen branded colors (primary red and secondary colors)
- **Typography**: Clear readable fonts optimized for learning content
- **Gamification Elements**: XP progress, rewards, badges, and animations
- **Accessibility**: High contrast options and scalable text

## Navigation

The app uses Flutter's Navigator 2.0 for declarative routing with the following main routes:

- `/`: Home screen
- `/login`: Authentication screen
- `/signup`: Registration screen
- `/games`: Games library
- `/games/{game_id}`: Individual game screen
- `/quest-map`: Quest progression map
- `/videos`: Video library
- `/videos/{video_id}`: Individual video player
- `/chat`: AI assistant chat interface
- `/profile`: User profile
- `/leaderboard`: User rankings

## Data Handling

The mobile app handles data in the following ways:

1. **API Requests**: Communicates with backend using HTTP requests
2. **Local Storage**: Stores authentication tokens and cached data
3. **State Persistence**: Maintains app state across sessions
4. **Offline Support**: Basic functionality when network is unavailable

## Connection with Backend

The mobile application connects to the backend API as defined in the API Endpoints documentation:

1. **Authentication**: Secures an access token during login/signup
2. **Data Fetching**: Retrieves user data, games, videos from endpoints
3. **Progress Tracking**: Posts completion data to track user progress
4. **Chat Integration**: Communicates with the AI chatbot for financial advice

## Gamification Features

The application incorporates several gamification elements to enhance engagement:

1. **XP System**: Users earn experience points for completed activities
2. **Level Progression**: XP accumulation leads to level advancement
3. **Achievement Badges**: Special accomplishments earn visual badges
4. **Daily Streaks**: Consecutive days of activity are tracked and rewarded
5. **Leaderboard**: Competitive ranking based on user progression
6. **In-app Currency**: Virtual coins earned through activities can be used for rewards