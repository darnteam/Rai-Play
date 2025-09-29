# API Endpoints Documentation

This document details the backend API endpoints that the mobile application uses to communicate with the server.

## Authentication Endpoints

### `POST /auth/signup`
- **Description**: Register a new user
- **Request Body**: 
  ```json
  {
    "username": "string",
    "email": "string",
    "password": "string"
  }
  ```
- **Response**:
  ```json
  {
    "access_token": "string",
    "token_type": "bearer"
  }
  ```
- **Usage in Frontend**: Used in the signup screen when a new user registers for the application

### `POST /auth/login`
- **Description**: Authenticate existing user
- **Request Body**: Form data with username and password
- **Response**:
  ```json
  {
    "access_token": "string",
    "token_type": "bearer"
  }
  ```
- **Usage in Frontend**: Used in the login screen when a user logs into the application

### `GET /auth/login/google`
- **Description**: Redirects to Google OAuth consent screen
- **Usage in Frontend**: Called when the user clicks "Sign in with Google" button

### `GET /auth/callback/google`
- **Description**: Callback for Google OAuth process
- **Response**:
  ```json
  {
    "access_token": "string",
    "token_type": "bearer"
  }
  ```
- **Usage in Frontend**: Automatically handled during OAuth flow

## User Endpoints

### `GET /users/{user_id}`
- **Description**: Retrieve user profile information
- **Parameters**: `user_id` (path)
- **Response**: User profile data including XP, level, coins, and other stats
- **Usage in Frontend**: Used in the profile screen and home screen to display user information

### `GET /users/leaderboard`
- **Description**: Get top users sorted by XP
- **Response**: List of users with their XP and ranking
- **Usage in Frontend**: Used in the leaderboard screen to show top performers

### `GET /users/badges`
- **Description**: Get user's earned badges
- **Authentication**: Requires JWT token
- **Response**: List of badges earned by the user
- **Usage in Frontend**: Used in the badges screen and profile screen

## Games Endpoints

### `GET /games/`
- **Description**: Get list of games filtered by completion status
- **Parameters**: `completed` (query, boolean)
- **Authentication**: Requires JWT token
- **Response**: List of games matching the completion status
- **Usage in Frontend**: Used in games screen to show available and completed games

### `GET /games/minigames`
- **Description**: Get all minigames
- **Response**: List of games with type "minigame"
- **Usage in Frontend**: Used in the minigames section of the games screen

### `GET /games/quests/storyline`
- **Description**: Get the quest storyline in order
- **Response**: Ordered list of quest games
- **Usage in Frontend**: Used in the quest map screen to show game progression

### `POST /games/{game_id}/complete`
- **Description**: Mark a game as completed and award XP/coins
- **Parameters**: `game_id` (path)
- **Authentication**: Requires JWT token
- **Response**: Confirmation message
- **Usage in Frontend**: Called when a user completes a game

## Video Endpoints

### `GET /videos/`
- **Description**: Get all educational videos
- **Response**: List of all available videos
- **Usage in Frontend**: Used in the video library screen

### `GET /videos/saved`
- **Description**: Get videos saved by the current user
- **Authentication**: Requires JWT token
- **Response**: List of saved videos
- **Usage in Frontend**: Used in the saved videos section

## Chat Endpoints

### `POST /chat/`
- **Description**: Send message to financial literacy AI assistant
- **Request Body**:
  ```json
  {
    "message": "string"
  }
  ```
- **Response**:
  ```json
  {
    "reply": "string"
  }
  ```
- **Usage in Frontend**: Used in the chat screen for the AI assistant

## Error Handling

All endpoints return standardized error responses:

- **400 Bad Request**: Invalid input data
- **401 Unauthorized**: Missing or invalid authentication
- **404 Not Found**: Resource not found
- **500 Internal Server Error**: Server-side error

## Authentication Flow

The mobile app stores the JWT token in secure storage after login/signup, and includes it in the Authorization header for authenticated requests:

```
Authorization: Bearer {token}
```