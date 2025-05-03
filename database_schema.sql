-- Enable UUID generation (required for gen_random_uuid())
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =============================
-- USERS TABLE (managed by Cognito)
-- =============================
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cognito_sub UUID UNIQUE NOT NULL, -- Cognito user’s unique identifier (from JWT `sub`)
    email VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(50) UNIQUE NOT NULL,
    avatar_url VARCHAR(255),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP,
    status VARCHAR(20) DEFAULT 'active', -- e.g., active, inactive, banned
    account_type VARCHAR(20) DEFAULT 'standard', -- e.g., standard, premium
    role VARCHAR(20) DEFAULT 'child' -- values: child, parent, admin
);

-- =============================
-- PARENT-CHILD RELATIONSHIP TABLE
-- =============================
CREATE TABLE parent_child_links (
    parent_id UUID REFERENCES users(id) ON DELETE CASCADE,
    child_id UUID REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (parent_id, child_id)
);

-- =============================
-- EXAMPLE: BONUSES (if needed)
-- =============================
CREATE TABLE bonuses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    child_id UUID REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(100) NOT NULL,
    description TEXT,
    points INT DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- =============================
-- OPTIONAL: TRACK LOGIN EVENTS
-- =============================
CREATE TABLE login_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    event_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ip_address INET,
    user_agent TEXT
);
