-- ==========================
-- ENUM TYPES
-- ==========================
CREATE TYPE reward_type AS ENUM ('xp', 'coins', 'badge');
CREATE TYPE game_type AS ENUM ('quest', 'minigame');

-- ==========================
-- USERS
-- ==========================
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    avatar_url TEXT,
    xp INTEGER DEFAULT 0,
    coins INTEGER DEFAULT 0,
    level INTEGER DEFAULT 1,
    streak_count INTEGER DEFAULT 0,
    longest_streak INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==========================
-- GAMES
-- ==========================
CREATE TABLE games (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    icon_url TEXT,
    game_type game_type NOT NULL,
    category VARCHAR(50), -- e.g. crypto, debit, credit
    xp_reward INTEGER DEFAULT 0,
    coin_reward INTEGER DEFAULT 0,
    achievement_id INTEGER REFERENCES achievements(id) ON DELETE SET NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==========================
-- QUEST STORYLINE (ORDERED GAMES)
-- ==========================
CREATE TABLE quest_storyline (
    id SERIAL PRIMARY KEY,
    game_id INTEGER NOT NULL REFERENCES games(id) ON DELETE CASCADE,
    order_index INTEGER NOT NULL,
    UNIQUE(game_id),
    UNIQUE(order_index)
);

-- ==========================
-- BADGES
-- ==========================
CREATE TABLE badges (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    icon_url TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- ==========================
-- ACHIEVEMENTS
-- ==========================
CREATE TABLE achievements (
    id SERIAL PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    description TEXT,
    icon_url TEXT,
    reward_type reward_type NOT NULL,
    reward_amount INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==========================
-- USER ACHIEVEMENTS
-- ==========================
CREATE TABLE user_achievements (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    achievement_id INTEGER REFERENCES achievements(id) ON DELETE CASCADE,
    achieved_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, achievement_id)
);


-- ==========================
-- VIDEOS (TikTok Style)
-- ==========================
CREATE TABLE videos (
    id SERIAL PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    url TEXT NOT NULL,
    duration_seconds INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==========================
-- USER SAVED VIDEOS
-- ==========================
CREATE TABLE user_saved_videos (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    video_id INTEGER REFERENCES videos(id) ON DELETE CASCADE,
    saved_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, video_id)
);

-- ==========================
-- USER PLAYED GAMES
-- ==========================
CREATE TABLE user_games (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    game_id INTEGER REFERENCES games(id) ON DELETE CASCADE,
    completed BOOLEAN DEFAULT FALSE,
    played_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, game_id)
);

-- ==========================
-- INDEXING FOR PERFORMANCE
-- ==========================
CREATE INDEX idx_user_email ON users(email);
CREATE INDEX idx_user_quest_progress_user ON user_quest_progress(user_id);
CREATE INDEX idx_leaderboard_score ON leaderboard_entries(score DESC);
