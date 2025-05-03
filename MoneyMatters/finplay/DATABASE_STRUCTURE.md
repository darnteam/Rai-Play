# FinPlay Database Structure

This document outlines the database structure for the FinPlay financial education application. The design follows a relational model that supports both the current feature set and future scalability needs.

## Database Technology Recommendations

For optimal scalability and performance, we recommend:

1. **PostgreSQL** - A powerful open-source RDBMS with excellent support for complex queries, JSON data types, and high transaction volumes
2. **Redis** - For caching frequently accessed data (leaderboards, user sessions)
3. **Firebase Authentication** (optional) - If you prefer offloading user authentication

## Core Tables

### Users

Stores the main user information.

```sql
CREATE TABLE users (
    id UUID PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    avatar_url VARCHAR(255),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP,
    status VARCHAR(20) DEFAULT 'active',
    account_type VARCHAR(20) DEFAULT 'standard',
    is_email_verified BOOLEAN DEFAULT FALSE
);

CREATE TABLE user_profiles (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    full_name VARCHAR(100),
    age_group VARCHAR(20),
    level INTEGER NOT NULL DEFAULT 1,
    xp INTEGER NOT NULL DEFAULT 0,
    coins INTEGER NOT NULL DEFAULT 0,
    streak_days INTEGER NOT NULL DEFAULT 0,
    last_streak_date DATE,
    total_games_played INTEGER DEFAULT 0,
    total_quests_completed INTEGER DEFAULT 0,
    preferred_learning_style VARCHAR(50),
    interests JSONB,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_user_profiles_level ON user_profiles(level);
CREATE INDEX idx_user_profiles_xp ON user_profiles(xp);
```

### Badges

Tracks achievements and badges earned by users.

```sql
CREATE TABLE badges (
    id UUID PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    icon_url VARCHAR(255) NOT NULL,
    category VARCHAR(50) NOT NULL,
    required_achievement VARCHAR(100) NOT NULL,
    threshold INTEGER NOT NULL,
    xp_reward INTEGER NOT NULL DEFAULT 0,
    coin_reward INTEGER NOT NULL DEFAULT 0,
    rarity VARCHAR(20) NOT NULL DEFAULT 'common',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE user_badges (
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    badge_id UUID REFERENCES badges(id) ON DELETE CASCADE,
    acquired_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_showcased BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (user_id, badge_id)
);

CREATE INDEX idx_user_badges_user_id ON user_badges(user_id);
```

### Games

Stores the financial education games available in the app.

```sql
CREATE TABLE game_categories (
    id UUID PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    icon TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE games (
    id UUID PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    category_id UUID REFERENCES game_categories(id),
    image_url VARCHAR(255),
    difficulty INTEGER NOT NULL DEFAULT 1,
    estimated_duration_minutes INTEGER,
    xp_reward INTEGER NOT NULL DEFAULT 10,
    coin_reward INTEGER NOT NULL DEFAULT 5,
    is_popular BOOLEAN DEFAULT FALSE,
    status VARCHAR(20) DEFAULT 'active',
    min_level INTEGER DEFAULT 1,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE game_sessions (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    game_id UUID REFERENCES games(id) ON DELETE CASCADE,
    start_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    end_time TIMESTAMP,
    score INTEGER,
    xp_earned INTEGER,
    coins_earned INTEGER,
    completed BOOLEAN DEFAULT FALSE,
    answers_data JSONB,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_game_sessions_user_id ON game_sessions(user_id);
CREATE INDEX idx_game_sessions_game_id ON game_sessions(game_id);
CREATE INDEX idx_game_sessions_completed ON game_sessions(completed);
```

### Quests

Manages the quest map feature with sequential learning challenges.

```sql
CREATE TABLE quests (
    id UUID PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    category VARCHAR(50) NOT NULL,
    difficulty INTEGER NOT NULL DEFAULT 1,
    position_x FLOAT NOT NULL,
    position_y FLOAT NOT NULL,
    sequence_order INTEGER NOT NULL,
    prerequisite_quest_id UUID REFERENCES quests(id),
    xp_reward INTEGER NOT NULL DEFAULT 20,
    coin_reward INTEGER NOT NULL DEFAULT 15,
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE quest_activities (
    id UUID PRIMARY KEY,
    quest_id UUID REFERENCES quests(id) ON DELETE CASCADE,
    title VARCHAR(100) NOT NULL,
    description TEXT,
    activity_type VARCHAR(50) NOT NULL,
    sequence_order INTEGER NOT NULL,
    content_reference VARCHAR(255),
    xp_reward INTEGER NOT NULL DEFAULT 5,
    coin_reward INTEGER NOT NULL DEFAULT 3,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE user_quests (
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    quest_id UUID REFERENCES quests(id) ON DELETE CASCADE,
    status VARCHAR(20) NOT NULL DEFAULT 'locked',
    progress INTEGER DEFAULT 0,
    started_at TIMESTAMP,
    completed_at TIMESTAMP,
    is_current BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (user_id, quest_id)
);

CREATE TABLE user_quest_activities (
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    activity_id UUID REFERENCES quest_activities(id) ON DELETE CASCADE,
    completed BOOLEAN DEFAULT FALSE,
    completed_at TIMESTAMP,
    PRIMARY KEY (user_id, activity_id)
);

CREATE INDEX idx_user_quests_user_id ON user_quests(user_id);
CREATE INDEX idx_user_quests_status ON user_quests(status);
```

### Educational Content

Stores videos and other learning content.

```sql
CREATE TABLE content_categories (
    id UUID PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE educational_videos (
    id UUID PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    thumbnail_url VARCHAR(255) NOT NULL,
    video_url VARCHAR(255) NOT NULL,
    duration_seconds INTEGER,
    category_id UUID REFERENCES content_categories(id),
    creator_name VARCHAR(100) NOT NULL,
    creator_avatar VARCHAR(255),
    xp_reward INTEGER NOT NULL DEFAULT 10,
    likes INTEGER DEFAULT 0,
    comments INTEGER DEFAULT 0,
    shares INTEGER DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE user_video_interactions (
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    video_id UUID REFERENCES educational_videos(id) ON DELETE CASCADE,
    watched BOOLEAN DEFAULT FALSE,
    watched_duration_seconds INTEGER DEFAULT 0,
    liked BOOLEAN DEFAULT FALSE,
    saved BOOLEAN DEFAULT FALSE,
    watched_at TIMESTAMP,
    PRIMARY KEY (user_id, video_id)
);

CREATE TABLE video_comments (
    id UUID PRIMARY KEY,
    video_id UUID REFERENCES educational_videos(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    parent_comment_id UUID REFERENCES video_comments(id),
    comment_text TEXT NOT NULL,
    likes INTEGER DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_video_comments_video_id ON video_comments(video_id);
```

### Financial AI Assistant (ChatBot)

Stores chat interactions with the financial AI assistant.

```sql
CREATE TABLE chat_sessions (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    started_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ended_at TIMESTAMP,
    session_summary TEXT,
    topics JSONB
);

CREATE TABLE chat_messages (
    id UUID PRIMARY KEY,
    session_id UUID REFERENCES chat_sessions(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    is_user BOOLEAN NOT NULL,
    message_text TEXT NOT NULL,
    timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE predefined_responses (
    id UUID PRIMARY KEY,
    keyword VARCHAR(100) NOT NULL,
    response_text TEXT NOT NULL,
    category VARCHAR(50),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_chat_messages_session_id ON chat_messages(session_id);
CREATE INDEX idx_predefined_responses_keyword ON predefined_responses(keyword);
```

### Leaderboards

Supports the competitive and social aspects of the app.

```sql
CREATE TABLE leaderboards (
    id UUID PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    type VARCHAR(50) NOT NULL,
    time_period VARCHAR(20) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    reset_at TIMESTAMP
);

CREATE TABLE leaderboard_entries (
    id UUID PRIMARY KEY,
    leaderboard_id UUID REFERENCES leaderboards(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    score INTEGER NOT NULL,
    rank INTEGER,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (leaderboard_id, user_id)
);

CREATE INDEX idx_leaderboard_entries_leaderboard_id ON leaderboard_entries(leaderboard_id);
CREATE INDEX idx_leaderboard_entries_score ON leaderboard_entries(score DESC);
```

### Notifications and System Events

Manages user notifications and system events.

```sql
CREATE TABLE notifications (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(100) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50) NOT NULL,
    reference_id UUID,
    reference_type VARCHAR(50),
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE system_events (
    id UUID PRIMARY KEY,
    event_type VARCHAR(50) NOT NULL,
    description TEXT NOT NULL,
    severity VARCHAR(20) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    metadata JSONB
);

CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);
```

## Relations Overview

![Database Relations Diagram](https://i.imgur.com/placeholder-for-diagram.png)

## Scalability Considerations

1. **Partitioning Strategy**:
   - Consider partitioning large tables like `game_sessions` and `chat_messages` by date ranges
   - Implement table partitioning for historical data

2. **Indexing Strategy**:
   - Indexes are created on frequently queried columns
   - Consider adding additional indexes based on query patterns

3. **Caching Layer**:
   - Implement Redis caching for:
     - Leaderboard data
     - User profile information
     - Game and quest metadata

4. **Horizontal Scaling**:
   - Design supports read replicas for high-traffic scenarios
   - Stateless application layer to work with clustered database setups

5. **Data Archiving**:
   - Implement policy for archiving old chat messages, game sessions, etc.
   - Create archive tables with less frequent access patterns

## Authentication and Security

1. **User Authentication**:
   - Password hashing using bcrypt or Argon2
   - Support for OAuth providers (Google, Apple)
   - JWT token-based authentication for API access

2. **Data Protection**:
   - Implement row-level security in PostgreSQL
   - Enable encryption for sensitive data fields
   - Regular security audits and penetration testing

## Backup and Disaster Recovery

1. **Backup Strategy**:
   - Full database backups daily
   - Transaction log backups every hour
   - Point-in-time recovery capability

2. **Disaster Recovery**:
   - Maintain standby database servers
   - Automated failover mechanisms
   - Regular recovery testing procedures

## Future Expansion Considerations

The database design accommodates future features such as:

1. **Social Features**:
   - Friends/connections between users
   - Group challenges and competitions
   - Social feed of achievements

2. **Monetization**:
   - Premium content subscriptions
   - Virtual item purchases
   - Premium badges and achievements

3. **Advanced Analytics**:
   - Learning pattern analysis
   - Personalized content recommendations
   - A/B testing framework

4. **Parental Controls**:
   - Parent/guardian accounts linked to teen accounts
   - Spending controls and monitoring
   - Progress reporting

## Implementation Phases

### Phase 1: Core Infrastructure
- Implement users, profiles, and authentication
- Basic game and quest infrastructure
- Simple leaderboard functionality

### Phase 2: Content Expansion
- Educational video infrastructure
- Chat assistant functionality
- Expanded quest system

### Phase 3: Advanced Features
- Social features
- Advanced analytics
- Monetization options
- Parental controls

## Maintenance Recommendations

1. **Regular Health Checks**:
   - Query performance monitoring
   - Index maintenance and optimization
   - Database size and growth monitoring

2. **Schema Evolution**:
   - Use migration scripts for all schema changes
   - Maintain backward compatibility when possible
   - Document all schema changes

3. **Performance Tuning**:
   - Regular EXPLAIN analysis of common queries
   - Optimize slow queries
   - Adjust indexing strategy based on usage patterns