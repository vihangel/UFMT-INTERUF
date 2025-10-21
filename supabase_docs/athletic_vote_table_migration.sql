-- Athletic Vote Table Migration with Google Authentication Support
-- This migration adds Google OAuth authentication columns to the existing athletic_vote table
-- 
-- IMPORTANT: Run this migration in your Supabase SQL Editor
-- The table athletic_vote already exists with: id, athletic_id, votante_id, created_at, updated_at

-- Step 1: Add new columns for Google Authentication
ALTER TABLE public.athletic_vote 
ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
ADD COLUMN IF NOT EXISTS user_email TEXT;

-- Step 2: Update table and column comments
COMMENT ON TABLE public.athletic_vote IS 'Stores authenticated user votes for athletics in the torcidômetro system';

COMMENT ON COLUMN public.athletic_vote.id IS 'Unique identifier for the vote';
COMMENT ON COLUMN public.athletic_vote.athletic_id IS 'Reference to the athletic being voted for';
COMMENT ON COLUMN public.athletic_vote.votante_id IS 'Unique identifier (legacy UUID or auth-{user_id})';
COMMENT ON COLUMN public.athletic_vote.user_id IS 'Reference to the authenticated user (from Supabase Auth) - REQUIRED for new votes';
COMMENT ON COLUMN public.athletic_vote.user_email IS 'Email of the user who voted (for display purposes)';
COMMENT ON COLUMN public.athletic_vote.created_at IS 'Timestamp when the vote was created';
COMMENT ON COLUMN public.athletic_vote.updated_at IS 'Timestamp when the vote was last updated';

-- Step 3: Create indexes for better query performance (only new columns)
CREATE INDEX IF NOT EXISTS idx_athletic_vote_user_id 
ON public.athletic_vote(user_id);

CREATE INDEX IF NOT EXISTS idx_athletic_vote_user_email
ON public.athletic_vote(user_email);

-- Note: Indexes for athletic_id, votante_id, and created_at may already exist
-- If you need to add them, uncomment the following:
-- CREATE INDEX IF NOT EXISTS idx_athletic_vote_athletic_id ON public.athletic_vote(athletic_id);
-- CREATE INDEX IF NOT EXISTS idx_athletic_vote_votante_id ON public.athletic_vote(votante_id);
-- CREATE INDEX IF NOT EXISTS idx_athletic_vote_created_at ON public.athletic_vote(created_at DESC);

-- Step 4: Remove unique constraint from votante_id if it exists
-- (votante_id is now for backward compatibility only)
ALTER TABLE public.athletic_vote 
DROP CONSTRAINT IF EXISTS athletic_vote_votante_id_key;

-- Step 5: Add unique constraint on user_id
-- This ensures one vote per authenticated user
ALTER TABLE public.athletic_vote 
DROP CONSTRAINT IF EXISTS athletic_vote_user_id_key;

ALTER TABLE public.athletic_vote 
ADD CONSTRAINT athletic_vote_user_id_key UNIQUE (user_id);

-- Step 6: Update the function to automatically update updated_at timestamp (if not exists)
CREATE OR REPLACE FUNCTION update_athletic_vote_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Step 7: Create trigger to call the function (if not exists)
DROP TRIGGER IF EXISTS trigger_update_athletic_vote_updated_at ON public.athletic_vote;
CREATE TRIGGER trigger_update_athletic_vote_updated_at
BEFORE UPDATE ON public.athletic_vote
FOR EACH ROW
EXECUTE FUNCTION update_athletic_vote_updated_at();

-- Step 8: Enable Row Level Security (RLS)
ALTER TABLE public.athletic_vote ENABLE ROW LEVEL SECURITY;

-- Step 9: Drop existing policies if they exist
DROP POLICY IF EXISTS "Allow public read access" ON public.athletic_vote;
DROP POLICY IF EXISTS "Allow authenticated users to insert" ON public.athletic_vote;
DROP POLICY IF EXISTS "Allow users to delete their own votes" ON public.athletic_vote;

-- Step 10: Create policy to allow anyone to read votes (for torcidômetro display)
CREATE POLICY "Allow public read access"
ON public.athletic_vote
FOR SELECT
TO public
USING (true);

-- Step 11: Create policy to allow only authenticated users to insert votes
CREATE POLICY "Allow authenticated users to insert"
ON public.athletic_vote
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- Step 12: Create policy to allow users to delete only their own votes
CREATE POLICY "Allow users to delete their own votes"
ON public.athletic_vote
FOR DELETE
TO authenticated
USING (auth.uid() = user_id);

-- Step 13: Grant necessary permissions
GRANT SELECT ON public.athletic_vote TO anon;
GRANT SELECT ON public.athletic_vote TO authenticated;
GRANT INSERT, DELETE ON public.athletic_vote TO authenticated;

-- Step 14: Create a view for easy querying of vote counts
CREATE OR REPLACE VIEW public.athletic_vote_counts AS
SELECT 
  a.id as athletic_id,
  a.nickname,
  a.name,
  a.logo_url,
  a.series,
  COUNT(av.id) as vote_count
FROM public.athletics a
LEFT JOIN public.athletic_vote av ON a.id = av.athletic_id
GROUP BY a.id, a.nickname, a.name, a.logo_url, a.series
ORDER BY a.series, vote_count DESC;

-- Step 15: Grant access to the view
GRANT SELECT ON public.athletic_vote_counts TO anon;
GRANT SELECT ON public.athletic_vote_counts TO authenticated;

COMMENT ON VIEW public.athletic_vote_counts IS 'Aggregated view of vote counts per athletic';

-- Step 16: Create a view for user vote statistics
CREATE OR REPLACE VIEW public.athletic_vote_user_stats AS
SELECT 
  DATE_TRUNC('day', created_at) as vote_date,
  COUNT(DISTINCT user_id) as unique_voters,
  COUNT(*) as total_votes
FROM public.athletic_vote
WHERE user_id IS NOT NULL
GROUP BY DATE_TRUNC('day', created_at)
ORDER BY vote_date DESC;

-- Step 17: Grant access to the user stats view
GRANT SELECT ON public.athletic_vote_user_stats TO authenticated;

COMMENT ON VIEW public.athletic_vote_user_stats IS 'Statistics of authenticated user votes over time';

-- Step 18: Add check constraint to ensure user_id is provided for new authenticated votes
-- Note: This allows existing votes without user_id to remain, but new votes must have user_id
-- If you want to require user_id for ALL votes, uncomment the following constraint:
-- ALTER TABLE public.athletic_vote
-- ADD CONSTRAINT check_user_id_required 
-- CHECK (user_id IS NOT NULL);

-- Migration complete!
-- Summary of changes:
-- ✅ Added user_id column (references auth.users)
-- ✅ Added user_email column
-- ✅ Removed unique constraint from votante_id (now legacy)
-- ✅ Added unique constraint on user_id (one vote per user)
-- ✅ Created indexes for user_id and user_email
-- ✅ Enabled RLS with policies for authenticated voting
-- ✅ Created views for vote counts and user statistics
-- ✅ Granted appropriate permissions
