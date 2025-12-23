-- Phase 1: The "Vault" Database Design (MySQL Compatible)

-- 1. Identity Table: Stores voter details and status.
CREATE TABLE IF NOT EXISTS voters (
    voter_id VARCHAR(255) PRIMARY KEY, -- e.g., Aadhaar Hash
    name VARCHAR(255) NOT NULL,
    face_hash VARCHAR(255) NOT NULL,
    has_voted BOOLEAN DEFAULT FALSE
);

-- 2. Token Bridge Table: The ONLY link between Auth and Vote.
CREATE TABLE IF NOT EXISTS active_tokens (
    token_uuid VARCHAR(36) PRIMARY KEY, -- MySQL uses VARCHAR for UUIDs usually
    expiry_time TIMESTAMP NOT NULL
);

-- 3. Ballot Table: Stores the actual vote.
CREATE TABLE IF NOT EXISTS votes (
    vote_id VARCHAR(36) PRIMARY KEY,
    candidate_id VARCHAR(255) NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Initial Mock Data for Testing
INSERT IGNORE INTO voters (voter_id, name, face_hash, has_voted) VALUES 
('aadhaar_123', 'John Doe', 'face_hash_abc', FALSE);
