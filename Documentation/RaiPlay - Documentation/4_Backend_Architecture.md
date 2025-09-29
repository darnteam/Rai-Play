# Backend Architecture

This document details the architecture of the RaiPlay backend application built with FastAPI.

## Application Structure

The backend follows a layered architecture with clear separation of concerns:

```
app/
├── app.py                # Main application entry point
├── configuration.py      # Environment and app configuration
├── auth/                 # Authentication components
│   ├── auth.py           # Authentication services
│   └── dependencies.py   # Auth dependency injection
├── database/             # Database connection and setup
│   └── connection.py     # Database connection handling
├── middleware/           # HTTP middleware components
├── models/               # Data models
│   ├── models.py         # Database ORM models
│   └── dtos/             # Data transfer objects for API
├── repositories/         # Data access layer
├── services/             # Business logic layer
├── utils/                # Utility functions
└── views/                # API endpoints (controllers)
```

## Key Components

### Application Entry Point (`app.py`)

The main FastAPI application is defined in `app.py`, which:
- Configures the FastAPI application
- Registers all route handlers from the views module
- Adds middleware for sessions and authentication
- Initializes the application with proper metadata

### Authentication System

The authentication system provides several mechanisms for user identification:

1. **JWT Authentication**: Token-based authentication for API access
2. **OAuth Integration**: Authentication with Google accounts
3. **Password Authentication**: Username/password authentication with bcrypt hashing

Key components:
- `auth.py`: JWT token generation and validation
- `dependencies.py`: FastAPI dependencies for current user extraction

### Models

The backend uses two types of data models:

1. **ORM Models**: SQLAlchemy models that map to database tables
2. **DTOs (Data Transfer Objects)**: Pydantic models for API request/response validation

Key entities include:
- `User`: User profile with authentication details
- `Game`: Financial literacy games and activities
- `Video`: Educational video content
- `Achievement`: User accomplishments and badges

### Repositories

The data access layer contains repository classes that encapsulate database operations:

- `UserRepository`: User management and queries
- `GamesRepository`: Game data access and progression tracking
- `VideoRepository`: Video content management
- `HealthRepository`: System health checks

Each repository handles CRUD operations for its domain entities.

### Services

The business logic layer contains service classes that implement application functionality:

- `UserService`: User management and profile operations
- `GamesService`: Game progression, completion, and rewards
- `VideoService`: Video content delivery and bookmarking
- `ChatService`: AI-powered financial advice bot
- `HealthService`: System status monitoring

### Views (Controllers)

The API endpoints are organized in view modules by domain area:

- `auth_views.py`: Authentication endpoints
- `user_views.py`: User profile and leaderboard endpoints
- `games_views.py`: Game listings and progression endpoints
- `video_views.py`: Video content endpoints
- `chat_views.py`: Financial assistant chat endpoints
- `health_views.py`: System health check endpoints

## Database Schema

The backend uses a PostgreSQL database with the following key tables:

- **users**: User accounts and profile data
- **games**: Game definitions and metadata
- **user_games**: User progression in games
- **videos**: Video content metadata
- **user_videos**: User video interactions (saved videos)
- **achievements**: Achievement definitions
- **user_achievements**: User earned achievements

## Authentication Flow

1. **Registration**:
   - User submits username, email, password
   - Password is hashed with bcrypt
   - User record is created in database
   - JWT token is generated and returned

2. **Login**:
   - User submits username/email and password
   - Password is verified against stored hash
   - JWT token is generated and returned

3. **OAuth (Google)**:
   - User is redirected to Google OAuth consent screen
   - After consent, Google returns user info
   - System checks if user exists or creates a new user
   - JWT token is generated and returned

4. **API Authentication**:
   - Client includes JWT token in Authorization header
   - `get_current_user` dependency extracts and validates token
   - Current user is injected into the request handlers

## Chat Integration

The backend integrates with AI services for the financial assistant:

1. The `ChatService` receives user messages from the frontend
2. The service formats the message and sends it to an LLM (Language Learning Model)
3. The response is processed and returned to the frontend

## Gamification Implementation

The backend implements gamification mechanics through:

1. **XP Tracking**: The `UserService` manages XP accumulation and level progression
2. **Achievements**: The system awards achievements based on user activities
3. **Rewards**: Completing activities grants in-app currency and rewards
4. **Progression**: The backend tracks user progress through the learning journey

## Error Handling

The backend implements structured error handling:

1. **Input Validation**: Pydantic models validate request data
2. **HTTP Exceptions**: FastAPI HTTP exceptions with appropriate status codes
3. **Exception Handlers**: Custom exception handlers for graceful error responses

## Security Measures

The backend implements several security measures:

1. **Password Hashing**: Passwords are never stored in plaintext
2. **JWT Expiration**: Tokens have a limited lifespan
3. **CORS Protection**: Controls which origins can access the API
4. **Input Sanitization**: Prevents injection attacks
5. **Rate Limiting**: Prevents abuse of the API endpoints

## Deployment Architecture

The backend is designed to be deployed in a containerized environment:

1. **Application**: FastAPI application server
2. **Database**: PostgreSQL database
3. **Redis**: Optional caching and rate limiting
4. **NGINX**: Reverse proxy and TLS termination

This architecture allows for horizontal scaling of the application servers as user load increases.