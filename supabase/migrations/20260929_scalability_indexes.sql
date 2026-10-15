-- =====================================================================================
-- Migration: Scalability Indexes
-- Description: Adds B-Tree indexes to foreign keys and commonly filtered columns 
-- to optimize database performance for 3000+ users.
-- =====================================================================================

-- 1. Issues Table Indexes
-- Improves performance when querying issues by village or leader.
CREATE INDEX IF NOT EXISTS idx_issues_village_id ON public.issues(village_id);
CREATE INDEX IF NOT EXISTS idx_issues_leader_id ON public.issues(leader_id);

-- Improves performance for filtering by status (e.g., in the admin dashboard)
CREATE INDEX IF NOT EXISTS idx_issues_status ON public.issues(status);

-- Improves sorting by newest issues first
CREATE INDEX IF NOT EXISTS idx_issues_created_at ON public.issues(created_at DESC);

-- 2. Progress Updates Table Indexes
-- Crucial for fast lookups of progress updates belonging to a specific issue
CREATE INDEX IF NOT EXISTS idx_progress_updates_issue_id ON public.progress_updates(issue_id);

-- 3. Notification Table Indexes (if applicable)
-- Improves querying notifications for a specific issue
CREATE INDEX IF NOT EXISTS idx_closure_notifications_issue_id ON public.closure_notifications(issue_id);

-- Note: When running this in Supabase, you can execute it via the SQL Editor.
