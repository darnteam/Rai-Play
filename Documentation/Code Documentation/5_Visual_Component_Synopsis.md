# RaiPlay Application Architecture: Visual Synopsis

This document provides visual representations of how the different components of the RaiPlay financial literacy application connect and work together.

## 1. High-Level System Architecture

```mermaid
graph TB
    subgraph "Frontend (Flutter Mobile App)"
        UI[UI Layer]
        BL[Business Logic]
        API[API Service]
        Store[Local Storage]
    end
    
    subgraph "Backend (FastAPI)"
        Views[API Controllers]
        Services[Business Services]
        Repos[Repositories]
        DB[(PostgreSQL Database)]
        LLM[AI Chat Service]
    end
    
    UI --> BL
    BL --> API
    BL --> Store
    API --> Views
    Views --> Services
    Services --> Repos
    Repos --> DB
    Services --> LLM
    
    classDef frontend fill:#f9d5e5,stroke:#333,stroke-width:1px;
    classDef backend fill:#eeeeee,stroke:#333,stroke-width:1px;
    
    class UI,BL,API,Store frontend;
    class Views,Services,Repos,DB,LLM backend;
```

## 2. Component Interaction Flow

```mermaid
sequenceDiagram
    participant User
    participant MobileApp as Flutter Mobile App
    participant Backend as FastAPI Backend
    participant Database as PostgreSQL
    participant AI as Chat AI Service

    User->>MobileApp: Open App
    MobileApp->>Backend: Authenticate (JWT)
    Backend->>Database: Verify User
    Database-->>Backend: User Data
    Backend-->>MobileApp: Auth Token + User Profile
    
    User->>MobileApp: Select Game
    MobileApp->>Backend: Request Game Data
    Backend->>Database: Fetch Game Content
    Database-->>Backend: Game Content
    Backend-->>MobileApp: Game Content
    
    User->>MobileApp: Complete Game
    MobileApp->>Backend: POST Game Completion
    Backend->>Database: Update User Progress
    Backend->>Database: Award XP and Coins
    Database-->>Backend: Updated Progress
    Backend-->>MobileApp: Success + New Rewards
    
    User->>MobileApp: Ask Financial Question
    MobileApp->>Backend: Send Message
    Backend->>AI: Process Query
    AI-->>Backend: Generate Response
    Backend-->>MobileApp: AI Response
```

## 3. Data Flow Architecture

```mermaid
flowchart TD
    subgraph FE[Frontend Layer]
        UI[UI Components]
        State[State Management]
        APIClient[API Client]
    end
    
    subgraph BE[Backend Layer]
        Router[API Routers]
        Service[Service Layer]
        Repo[Repository Layer]
    end
    
    subgraph DB[Data Layer]
        SQL[(PostgreSQL)]
        Cache[(Redis Cache)]
    end
    
    subgraph EXT[External Services]
        OAuth[Google OAuth]
        LLMAPI[AI Language Model]
    end
    
    UI <--> State
    State <--> APIClient
    APIClient <--> Router
    Router <--> Service
    Service <--> Repo
    Repo <--> SQL
    Service <--> Cache
    Service <--> OAuth
    Service <--> LLMAPI
    
    classDef frontend fill:#ffcccb,stroke:#333,stroke-width:1px;
    classDef backend fill:#90ee90,stroke:#333,stroke-width:1px;
    classDef data fill:#add8e6,stroke:#333,stroke-width:1px;
    classDef external fill:#d3d3d3,stroke:#333,stroke-width:1px;
    
    class UI,State,APIClient frontend;
    class Router,Service,Repo backend;
    class SQL,Cache data;
    class OAuth,LLMAPI external;
```

## 4. Backend Module Dependencies

```mermaid
graph LR
    App[app.py] --> AuthViews[auth_views.py]
    App --> UserViews[user_views.py]
    App --> GameViews[games_views.py]
    App --> VideoViews[video_views.py]
    App --> ChatViews[chat_views.py]
    
    AuthViews --> AuthService[auth.py]
    AuthViews --> UserService[user_service.py]
    UserViews --> UserService
    GameViews --> GameService[games_service.py]
    VideoViews --> VideoService[video_service.py]
    ChatViews --> ChatService[chat_service.py]
    
    AuthService --> UserRepo[user_repository.py]
    UserService --> UserRepo
    GameService --> GameRepo[games_repository.py]
    VideoService --> VideoRepo[video_repository.py]
    
    UserRepo --> DB[(Database)]
    GameRepo --> DB
    VideoRepo --> DB
    
    classDef views fill:#ffcccb,stroke:#333,stroke-width:1px;
    classDef services fill:#90ee90,stroke:#333,stroke-width:1px;
    classDef repos fill:#add8e6,stroke:#333,stroke-width:1px;
    classDef db fill:#d3d3d3,stroke:#333,stroke-width:1px;
    
    class App,AuthViews,UserViews,GameViews,VideoViews,ChatViews views;
    class AuthService,UserService,GameService,VideoService,ChatService services;
    class UserRepo,GameRepo,VideoRepo repos;
    class DB db;
```

## 5. Frontend Module Organization

```mermaid
graph TB
    Main[main.dart] --> App[App]
    
    App --> Routes[Navigation Routes]
    Routes --> HomeScreen[Home Screen]
    Routes --> GamesScreen[Games Screen]
    Routes --> VideoScreen[Video Screen]
    Routes --> ChatScreen[Chat Screen]
    Routes --> ProfileScreen[Profile Screen]
    
    HomeScreen --> HomeWidgets[Home Widgets]
    GamesScreen --> GameWidgets[Game Widgets]
    VideoScreen --> VideoWidgets[Video Widgets]
    
    HomeScreen --> ApiService[API Service]
    GamesScreen --> ApiService
    VideoScreen --> ApiService
    ChatScreen --> ApiService
    ProfileScreen --> ApiService
    
    ApiService --> AuthProvider[Auth Provider]
    ApiService --> UserProvider[User Provider]
    ApiService --> GameProvider[Game Provider]
    ApiService --> VideoProvider[Video Provider]
    ApiService --> ChatProvider[Chat Provider]
    
    classDef core fill:#ffcccb,stroke:#333,stroke-width:1px;
    classDef screens fill:#90ee90,stroke:#333,stroke-width:1px;
    classDef widgets fill:#add8e6,stroke:#333,stroke-width:1px;
    classDef services fill:#d3d3d3,stroke:#333,stroke-width:1px;
    classDef providers fill:#fafad2,stroke:#333,stroke-width:1px;
    
    class Main,App,Routes core;
    class HomeScreen,GamesScreen,VideoScreen,ChatScreen,ProfileScreen screens;
    class HomeWidgets,GameWidgets,VideoWidgets widgets;
    class ApiService services;
    class AuthProvider,UserProvider,GameProvider,VideoProvider,ChatProvider providers;
```

## 6. Authentication and Data Security Flow

```mermaid
flowchart TD
    User[User] --> Login[Login/Signup Screen]
    Login --> AuthRequest[Authentication Request]
    AuthRequest --> JWT[JWT Generation]
    JWT --> LocalStorage[Secure Storage]
    JWT --> AuthHeader[Authorization Header]
    AuthHeader --> SecuredAPI[Secured API Endpoints]
    SecuredAPI --> AuthMiddleware[Auth Middleware]
    AuthMiddleware --> TokenDecoding[Token Decoding]
    TokenDecoding --> UserIdentity[User Identity]
    UserIdentity --> AuthorizedServices[Authorized Services]
    AuthorizedServices --> SecuredData[Secured User Data]
    
    classDef client fill:#ffcccb,stroke:#333,stroke-width:1px;
    classDef transport fill:#90ee90,stroke:#333,stroke-width:1px;
    classDef server fill:#add8e6,stroke:#333,stroke-width:1px;
    
    class User,Login,LocalStorage client;
    class AuthRequest,AuthHeader transport;
    class JWT,SecuredAPI,AuthMiddleware,TokenDecoding,UserIdentity,AuthorizedServices,SecuredData server;
```

## 7. Gamification System Architecture

```mermaid
graph TD
    GamePlay[Game Play] --> Completion[Game Completion]
    Completion --> UpdateProgress[Update User Progress]
    UpdateProgress --> XPAward[Award XP]
    UpdateProgress --> CoinAward[Award Coins]
    XPAward --> LevelCheck[Check for Level Up]
    LevelCheck --> LevelUp[Level Up]
    LevelUp --> UnlockContent[Unlock New Content]
    UpdateProgress --> AchievementCheck[Check for Achievements]
    AchievementCheck --> AwardBadge[Award Badge]
    UpdateProgress --> StreakCheck[Check for Streak]
    StreakCheck --> UpdateStreak[Update Streak Counter]
    UpdateStreak --> StreakReward[Award Streak Bonus]
    
    classDef action fill:#ffcccb,stroke:#333,stroke-width:1px;
    classDef process fill:#90ee90,stroke:#333,stroke-width:1px;
    classDef reward fill:#add8e6,stroke:#333,stroke-width:1px;
    
    class GamePlay,Completion action;
    class UpdateProgress,XPAward,CoinAward,LevelCheck,AchievementCheck,StreakCheck process;
    class LevelUp,UnlockContent,AwardBadge,UpdateStreak,StreakReward reward;
```

## 8. Database Entity Relationship

```mermaid
erDiagram
    USERS ||--o{ USER_GAMES : completes
    USERS ||--o{ USER_VIDEOS : saves
    USERS ||--o{ USER_ACHIEVEMENTS : earns
    GAMES ||--o{ USER_GAMES : tracked_in
    VIDEOS ||--o{ USER_VIDEOS : saved_in
    ACHIEVEMENTS ||--o{ USER_ACHIEVEMENTS : awarded_in
    
    USERS {
        int id PK
        string username
        string email
        string password_hash
        int xp
        int level
        int coins
        date last_login
        bool is_active
    }
    
    GAMES {
        int id PK
        string title
        string description
        string type
        int xp_reward
        int coin_reward
        int order_index
        string difficulty
    }
    
    VIDEOS {
        int id PK
        string title
        string description
        string url
        int duration
        string thumbnail_url
        string category
    }
    
    ACHIEVEMENTS {
        int id PK
        string title
        string description
        string reward_type
        string icon
        int threshold
    }
    
    USER_GAMES {
        int id PK
        int user_id FK
        int game_id FK
        bool completed
        timestamp completion_date
        int score
    }
    
    USER_VIDEOS {
        int id PK
        int user_id FK
        int video_id FK
        bool saved
        timestamp last_watched
        float watch_percentage
    }
    
    USER_ACHIEVEMENTS {
        int id PK
        int user_id FK
        int achievement_id FK
        timestamp earned_date
    }
```

## 9. Application Communication Protocols

```mermaid
graph TB
    subgraph "Mobile Application"
        API_Client[API Client]
        JWT_Storage[JWT Storage]
    end
    
    subgraph "Network Layer"
        HTTPS[HTTPS Protocol]
        JSON_Payloads[JSON Payloads]
        Auth_Headers[Authorization Headers]
    end
    
    subgraph "Backend API"
        Endpoints[API Endpoints]
        Middleware[Authentication Middleware]
        Validators[Request Validators]
        Responses[Response Formatters]
    end
    
    API_Client --> JWT_Storage
    API_Client --> HTTPS
    JWT_Storage --> Auth_Headers
    HTTPS --> JSON_Payloads
    HTTPS --> Auth_Headers
    JSON_Payloads --> Endpoints
    Auth_Headers --> Middleware
    Middleware --> Endpoints
    Endpoints --> Validators
    Validators --> Responses
    Responses --> HTTPS
    
    classDef mobile fill:#ffcccb,stroke:#333,stroke-width:1px;
    classDef network fill:#90ee90,stroke:#333,stroke-width:1px;
    classDef api fill:#add8e6,stroke:#333,stroke-width:1px;
    
    class API_Client,JWT_Storage mobile;
    class HTTPS,JSON_Payloads,Auth_Headers network;
    class Endpoints,Middleware,Validators,Responses api;
```

## 10. Learning Journey Flow

```mermaid
graph TD
    Start[User Registration] --> Onboarding[Financial Literacy Assessment]
    Onboarding --> Homepage[Personalized Homepage]
    Homepage --> QuestMap[Quest Map]
    Homepage --> MiniGames[Mini Games]
    Homepage --> Videos[Educational Videos]
    Homepage --> Chat[AI Financial Assistant]
    
    QuestMap --> BasicConcepts[Basic Financial Concepts]
    BasicConcepts --> Budgeting[Budgeting Skills]
    Budgeting --> Saving[Saving Strategies]
    Saving --> Investing[Investment Basics]
    
    BasicConcepts --> Theory[Learning Theory]
    BasicConcepts --> Game1[Interactive Game]
    BasicConcepts --> Assessment[Knowledge Assessment]
    
    Budgeting --> BudgetingTheory[Budgeting Theory]
    Budgeting --> BudgetGame[Budget Simulator Game]
    Budgeting --> BudgetAssessment[Budgeting Assessment]
    
    MiniGames --> BankRush[Bank Rush Game]
    MiniGames --> FinancialQuiz[Financial Quiz]
    MiniGames --> InvestorIsland[Investor Island Game]
    
    Videos --> BasicVideos[Basic Concept Videos]
    Videos --> IntermedVideos[Intermediate Concept Videos]
    Videos --> AdvancedVideos[Advanced Concept Videos]
    
    classDef entry fill:#ffcccb,stroke:#333,stroke-width:1px;
    classDef journey fill:#90ee90,stroke:#333,stroke-width:1px;
    classDef content fill:#add8e6,stroke:#333,stroke-width:1px;
    classDef activity fill:#fafad2,stroke:#333,stroke-width:1px;
    
    class Start,Onboarding,Homepage entry;
    class QuestMap,BasicConcepts,Budgeting,Saving,Investing journey;
    class Theory,BudgetingTheory,BasicVideos,IntermedVideos,AdvancedVideos content;
    class Game1,Assessment,BudgetGame,BudgetAssessment,BankRush,FinancialQuiz,InvestorIsland,Chat activity;
```

These diagrams provide a comprehensive visual representation of how the different components of the RaiPlay financial literacy application are interconnected and work together to deliver a cohesive learning experience.