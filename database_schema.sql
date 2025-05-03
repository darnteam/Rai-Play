-- Users table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    cognito_sub UUID UNIQUE NOT NULL, -- AWS Cognito ID
    email TEXT UNIQUE NOT NULL,
    full_name TEXT,
    birth_date DATE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Roles table
CREATE TABLE roles (
    id SERIAL PRIMARY KEY,
    name TEXT UNIQUE NOT NULL, -- e.g. 'child', 'parent', 'admin'
);

CREATE TABLE user_roles (
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    role_id INTEGER REFERENCES roles(id) ON DELETE CASCADE,
    PRIMARY KEY (user_id, role_id)
);

CREATE TABLE parent_child_links(
    parent_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    child_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    verified_by_admin BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (parent_id, child_id),
    CHECK (parent_id <> child_id)
);