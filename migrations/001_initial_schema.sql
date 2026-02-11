-- Migration 001: Initial schema for async longform video rendering
-- Creates the jobs table to track async video processing requests

CREATE TABLE IF NOT EXISTS jobs (
    id TEXT PRIMARY KEY,
    status TEXT NOT NULL CHECK(status IN ('pending', 'processing', 'completed', 'failed')),
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    
    -- Request parameters
    audio_urls TEXT NOT NULL,  -- JSON array
    background_source TEXT NOT NULL CHECK(background_source IN ('images', 'videos')),
    background_urls TEXT NOT NULL,  -- JSON array
    quality TEXT NOT NULL CHECK(quality IN ('720', '1080')),
    
    -- Processing results
    result_url TEXT,
    error_message TEXT,
    duration_seconds REAL,
    processing_time REAL
);

CREATE INDEX IF NOT EXISTS idx_jobs_status ON jobs(status);
CREATE INDEX IF NOT EXISTS idx_jobs_created_at ON jobs(created_at);
