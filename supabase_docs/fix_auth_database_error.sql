-- Quick Diagnostic and Fix for "Database error saving new user"
-- Run this in Supabase SQL Editor to diagnose and fix the issue

-- ============================================
-- STEP 1: CHECK FOR TRIGGERS
-- ============================================
SELECT 
    'Checking triggers on auth.users' as step,
    trigger_name,
    action_timing,
    event_manipulation,
    action_statement
FROM information_schema.triggers
WHERE event_object_schema = 'auth'
  AND event_object_table = 'users';

-- ============================================
-- STEP 2: CHECK FOR FUNCTIONS
-- ============================================
SELECT 
    'Checking functions' as step,
    routine_name,
    routine_type
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND (routine_name LIKE '%user%' OR routine_name LIKE '%auth%');

-- ============================================
-- STEP 3: CHECK RLS ON ROLES TABLE
-- ============================================
SELECT 
    'Checking RLS on roles table' as step,
    tablename,
    rowsecurity as rls_enabled
FROM pg_tables 
WHERE schemaname = 'public'
  AND tablename = 'roles';

-- ============================================
-- STEP 4: CHECK POLICIES ON ROLES TABLE
-- ============================================
SELECT 
    'Checking policies on roles table' as step,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies 
WHERE tablename = 'roles';

-- ============================================
-- FIX 1: CREATE OR REPLACE HANDLE_NEW_USER FUNCTION
-- (This is the most likely fix)
-- ============================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- Try to insert default role, but don't fail if it doesn't work
  BEGIN
    INSERT INTO public.roles (user_id, role)
    VALUES (NEW.id, 'user')
    ON CONFLICT (user_id) DO NOTHING;
  EXCEPTION WHEN OTHERS THEN
    -- Log warning but don't block user creation
    RAISE WARNING 'Could not create role for user %: %', NEW.id, SQLERRM;
  END;
  
  RETURN NEW;
END;
$$;