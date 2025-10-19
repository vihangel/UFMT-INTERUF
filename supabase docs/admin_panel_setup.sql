-- Admin Panel Setup Script
-- Run this in your Supabase SQL Editor to set up the admin panel functionality

-- ============================================================
-- STEP 1: Verify the roles table exists
-- ============================================================
-- This should already exist based on your schema
-- If not, create it:

-- CREATE TABLE IF NOT EXISTS public.roles (
--   id uuid NOT NULL DEFAULT gen_random_uuid(),
--   user_id uuid NOT NULL,
--   role text NOT NULL CHECK (role = ANY (ARRAY['admin'::text, 'moderator'::text, 'user'::text])),
--   created_at timestamp with time zone DEFAULT now(),
--   CONSTRAINT roles_pkey PRIMARY KEY (id),
--   CONSTRAINT roles_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
-- );

-- ============================================================
-- STEP 2: Add your admin user
-- ============================================================
-- Replace 'your-email@sou.ufmt.br' with your actual email

-- First, find your user_id
-- SELECT id, email FROM auth.users WHERE email = 'your-email@sou.ufmt.br';

-- Then insert your admin role (replace 'your-user-id' with the ID from above)
-- INSERT INTO public.roles (user_id, role)
-- VALUES ('your-user-id', 'admin');

-- ============================================================
-- STEP 3: Set up RLS Policies for roles table
-- ============================================================

-- Enable RLS on roles table
ALTER TABLE public.roles ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any
DROP POLICY IF EXISTS "Users can read their own role" ON public.roles;
DROP POLICY IF EXISTS "Only admins can manage roles" ON public.roles;
DROP POLICY IF EXISTS "Service role can insert roles" ON public.roles;

-- Policy 1: Users can read their own role
CREATE POLICY "Users can read their own role"
  ON public.roles FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

-- Policy 2: Only admins can insert/update/delete roles
CREATE POLICY "Only admins can manage roles"
  ON public.roles FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.roles
      WHERE user_id = auth.uid()
      AND role = 'admin'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.roles
      WHERE user_id = auth.uid()
      AND role = 'admin'
    )
  );

-- Policy 3: Allow service role to insert roles (for automated user creation)
CREATE POLICY "Service role can insert roles"
  ON public.roles FOR INSERT
  TO service_role
  WITH CHECK (true);

-- ============================================================
-- STEP 4: Set up RLS Policies for protected tables
-- ============================================================

-- Example for athletics table
-- Modify as needed for your specific requirements

ALTER TABLE public.athletics ENABLE ROW LEVEL SECURITY;

-- Anyone can view athletics
CREATE POLICY "Anyone can view athletics"
  ON public.athletics FOR SELECT
  USING (true);

-- Only admins/moderators can insert athletics
CREATE POLICY "Only admins/moderators can insert athletics"
  ON public.athletics FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.roles
      WHERE user_id = auth.uid()
      AND role IN ('admin', 'moderator')
    )
  );

-- Only admins/moderators can update athletics
CREATE POLICY "Only admins/moderators can update athletics"
  ON public.athletics FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.roles
      WHERE user_id = auth.uid()
      AND role IN ('admin', 'moderator')
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.roles
      WHERE user_id = auth.uid()
      AND role IN ('admin', 'moderator')
    )
  );

-- Only admins/moderators can delete athletics
CREATE POLICY "Only admins/moderators can delete athletics"
  ON public.athletics FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.roles
      WHERE user_id = auth.uid()
      AND role IN ('admin', 'moderator')
    )
  );

-- ============================================================
-- STEP 5: Apply similar policies to other tables
-- ============================================================
-- Copy and modify the above policies for these tables:
-- - modalities
-- - games
-- - news
-- - athletes
-- - venues
-- - brackets
-- - game_stats
-- - athlete_game_stats
-- - stat_definitions

-- Example template (modify table name and policy names):
/*
ALTER TABLE public.TABLE_NAME ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view TABLE_NAME"
  ON public.TABLE_NAME FOR SELECT
  USING (true);

CREATE POLICY "Only admins/moderators can insert TABLE_NAME"
  ON public.TABLE_NAME FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.roles
      WHERE user_id = auth.uid()
      AND role IN ('admin', 'moderator')
    )
  );

CREATE POLICY "Only admins/moderators can update TABLE_NAME"
  ON public.TABLE_NAME FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.roles
      WHERE user_id = auth.uid()
      AND role IN ('admin', 'moderator')
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.roles
      WHERE user_id = auth.uid()
      AND role IN ('admin', 'moderator')
    )
  );

CREATE POLICY "Only admins/moderators can delete TABLE_NAME"
  ON public.TABLE_NAME FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.roles
      WHERE user_id = auth.uid()
      AND role IN ('admin', 'moderator')
    )
  );
*/

-- ============================================================
-- STEP 6: Helper functions (optional)
-- ============================================================

-- Function to check if a user is admin
CREATE OR REPLACE FUNCTION is_admin(user_uuid uuid)
RETURNS boolean AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.roles
    WHERE user_id = user_uuid
    AND role = 'admin'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to check if a user is moderator or admin
CREATE OR REPLACE FUNCTION is_admin_or_moderator(user_uuid uuid)
RETURNS boolean AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.roles
    WHERE user_id = user_uuid
    AND role IN ('admin', 'moderator')
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- STEP 7: Test queries
-- ============================================================

-- View all roles
SELECT 
  r.id,
  r.role,
  u.email,
  r.created_at
FROM public.roles r
JOIN auth.users u ON r.user_id = u.id
ORDER BY r.created_at DESC;

-- Check a specific user's role
-- SELECT role FROM public.roles WHERE user_id = 'your-user-id';

-- Count users by role
SELECT role, COUNT(*) as count
FROM public.roles
GROUP BY role;

-- ============================================================
-- QUICK START: Make yourself an admin
-- ============================================================
-- Run these queries in order:

-- 1. Find your user ID by email
-- SELECT id, email FROM auth.users WHERE email = 'your-email@sou.ufmt.br';

-- 2. Insert admin role (replace 'your-user-id-here' with actual ID)
-- INSERT INTO public.roles (user_id, role)
-- VALUES ('your-user-id-here', 'admin')
-- ON CONFLICT DO NOTHING;

-- 3. Verify
-- SELECT r.role, u.email 
-- FROM public.roles r 
-- JOIN auth.users u ON r.user_id = u.id 
-- WHERE u.email = 'your-email@sou.ufmt.br';

-- ============================================================
-- NOTES
-- ============================================================
-- 1. Always use parameterized queries in your application
-- 2. The RLS policies protect against unauthorized access at the database level
-- 3. The frontend checks (in Flutter) provide user experience, not security
-- 4. Test thoroughly with different user roles
-- 5. Keep audit logs of admin actions (implement separately)
