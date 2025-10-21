# Fixing "Database error saving new user" Error

## Error Details

**Error Code**: `unexpected_failure`  
**Error Message**: "Database error saving new user"  
**Endpoint**: `https://cipsznaudjkrpzzruhvp.supabase.co/auth/v1/otp`

This error occurs when Supabase Auth tries to create a new user in the `auth.users` table but encounters a database constraint violation or trigger error.

---

## Common Causes & Solutions

### 1. Database Trigger Conflict (Most Common)

**Problem**: You might have a database trigger that fires when a new user is created, and it's failing.

**Solution**: Check for triggers on the `auth.users` table.

#### Step 1: Check for Triggers

Go to **Supabase Dashboard** → **SQL Editor** and run:

```sql
-- Check for triggers on auth.users table
SELECT 
    trigger_name,
    event_manipulation,
    event_object_table,
    action_statement
FROM information_schema.triggers
WHERE event_object_schema = 'auth'
  AND event_object_table = 'users';
```

#### Step 2: Check Your Custom Triggers

If you have any custom triggers, they might be failing. Common issues:
- Trigger tries to insert into a table that doesn't exist
- Trigger has a foreign key constraint violation
- Trigger has invalid SQL

**Fix**: Temporarily disable the trigger to test:

```sql
-- Disable trigger (replace 'trigger_name' with actual name)
ALTER TABLE auth.users DISABLE TRIGGER trigger_name;
```

---

### 2. RLS Policy Conflict

**Problem**: Row Level Security (RLS) policies on related tables are blocking the user creation.

**Solution**: Check and fix RLS policies.

#### Check RLS on Related Tables

```sql
-- Check if your tables have RLS that might block user creation
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public';
```

#### Common Culprit: `roles` or `profiles` Table

If you have a `roles` table (as shown in your schema), it might have an INSERT trigger or RLS policy that's blocking.

**Fix for roles table**:

```sql
-- Check current RLS policies on roles table
SELECT * FROM pg_policies WHERE tablename = 'roles';

-- Temporarily disable RLS on roles table to test
ALTER TABLE public.roles DISABLE ROW LEVEL SECURITY;

-- Try signup again, then re-enable:
ALTER TABLE public.roles ENABLE ROW LEVEL SECURITY;
```

---

### 3. Foreign Key Constraint on `athletic_vote` Table

**Problem**: The `athletic_vote` table has a foreign key to `auth.users(id)` with `ON DELETE CASCADE`, but something is preventing the user creation.

**Solution**: Check if the migration created any conflicting constraints.

#### Check Constraints

```sql
-- Check constraints on athletic_vote table
SELECT 
    conname AS constraint_name,
    contype AS constraint_type,
    pg_get_constraintdef(oid) AS constraint_definition
FROM pg_constraint
WHERE conrelid = 'public.athletic_vote'::regclass;
```

#### Fix: Drop and Recreate the Foreign Key (if needed)

```sql
-- If there's an issue with the user_id foreign key
ALTER TABLE public.athletic_vote 
DROP CONSTRAINT IF EXISTS athletic_vote_user_id_fkey;

-- Recreate it properly
ALTER TABLE public.athletic_vote 
ADD CONSTRAINT athletic_vote_user_id_fkey 
FOREIGN KEY (user_id) 
REFERENCES auth.users(id) 
ON DELETE CASCADE;
```

---

### 4. Unique Constraint Conflict

**Problem**: There might be a unique constraint violation (though this usually gives a different error).

**Solution**: Check for duplicate emails or unique constraints.

```sql
-- Check if email already exists in auth.users
SELECT id, email, created_at 
FROM auth.users 
WHERE email = 'test@sou.ufmt.br';  -- Replace with the email you're testing

-- If exists, delete it (for testing only)
DELETE FROM auth.users WHERE email = 'test@sou.ufmt.br';
```

---

### 5. Database Function Error

**Problem**: Supabase has a function `handle_new_user()` that runs after user creation. This function might be failing.

**Solution**: Check and fix the function.

#### Find the Function

```sql
-- Check for functions that trigger on new user
SELECT 
    trigger_name,
    action_statement
FROM information_schema.triggers
WHERE event_object_table = 'users'
  AND event_object_schema = 'auth';
```

#### Common Function Issues

If you have a function like `handle_new_user()`, it might be trying to:
- Insert into `public.profiles` table
- Insert into `public.roles` table
- Create related records

**Example of a problematic function**:

```sql
-- This function might be causing issues
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  -- This might fail if roles table doesn't exist or has RLS issues
  INSERT INTO public.roles (user_id, role)
  VALUES (NEW.id, 'user');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

**Fix**: Update the function to handle errors gracefully:

```sql
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  -- Try to insert, but don't fail if it doesn't work
  BEGIN
    INSERT INTO public.roles (user_id, role)
    VALUES (NEW.id, 'user')
    ON CONFLICT (user_id) DO NOTHING;
  EXCEPTION WHEN OTHERS THEN
    -- Log error but don't fail user creation
    RAISE WARNING 'Failed to create role for user %: %', NEW.id, SQLERRM;
  END;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

---

## Quick Fix Steps (Try These First)

### Option 1: Disable All Custom Triggers/Functions Temporarily

```sql
-- List all triggers on auth.users
SELECT trigger_name 
FROM information_schema.triggers
WHERE event_object_schema = 'auth'
  AND event_object_table = 'users';

-- Disable each trigger (replace 'trigger_name')
ALTER TABLE auth.users DISABLE TRIGGER ALL;

-- Try signup again

-- Re-enable triggers
ALTER TABLE auth.users ENABLE TRIGGER ALL;
```

### Option 2: Check Supabase Logs

1. Go to **Supabase Dashboard**
2. Navigate to **Logs** → **Database**
3. Look for error messages around the time of the signup attempt
4. The error message will tell you exactly what's failing

### Option 3: Check Auth Logs

1. Go to **Supabase Dashboard**
2. Navigate to **Logs** → **Auth**
3. Look for the failed signup attempt
4. Check the error details

---

## Recommended Solution for Your Project

Based on your schema, the most likely issue is the `roles` table. Here's how to fix it:

### Step 1: Check if `roles` table is causing the issue

```sql
-- Check if there's a trigger creating roles for new users
SELECT routine_name, routine_definition
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name LIKE '%user%';
```

### Step 2: Fix the `roles` table RLS

```sql
-- Make sure RLS allows inserting roles for new users
DROP POLICY IF EXISTS "Allow service role to insert" ON public.roles;

CREATE POLICY "Allow service role to insert"
ON public.roles
FOR INSERT
TO service_role
USING (true);

-- Also allow authenticated users to read their own role
DROP POLICY IF EXISTS "Users can view own role" ON public.roles;

CREATE POLICY "Users can view own role"
ON public.roles
FOR SELECT
TO authenticated
USING (auth.uid() = user_id);
```

### Step 3: Ensure the `handle_new_user` function exists and works

```sql
-- Create or replace the function to handle new users
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- Insert default role for new user
  INSERT INTO public.roles (user_id, role)
  VALUES (NEW.id, 'user')
  ON CONFLICT (user_id) DO NOTHING;
  
  RETURN NEW;
EXCEPTION WHEN OTHERS THEN
  -- Don't fail user creation if role insertion fails
  RAISE WARNING 'Could not create role for user %: %', NEW.id, SQLERRM;
  RETURN NEW;
END;
$$;

-- Create trigger if it doesn't exist
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();
```

---

## Testing the Fix

After applying the fix, test with a new email:

1. Open your app
2. Try to sign up with a new email (e.g., `test123@sou.ufmt.br`)
3. Check if you receive the magic link
4. Check Supabase logs for any errors

---

## Alternative: Simplify the Setup

If you keep having issues, you can simplify by removing the automatic role creation:

```sql
-- Remove the trigger completely
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();

-- You can create roles manually later if needed
-- Or create them when the user first logs in (in your app code)
```

Then handle role creation in your Flutter app after successful login.

---

## Prevention: Best Practices

1. **Keep triggers simple**: Don't do complex operations in auth triggers
2. **Handle errors gracefully**: Use `EXCEPTION WHEN OTHERS` in triggers
3. **Test with Supabase logs open**: Always monitor logs when testing auth
4. **Use `ON CONFLICT DO NOTHING`**: Prevents duplicate key errors
5. **Set `SECURITY DEFINER`**: Allows triggers to bypass RLS

---

## Still Not Working?

If none of the above works:

1. **Check Supabase Status**: [status.supabase.com](https://status.supabase.com)
2. **Try with a different email provider**: Sometimes Gmail blocks certain emails
3. **Contact Supabase Support**: They can check server-side logs
4. **Create a minimal test case**: Try signup with just email, no triggers

---

## Summary

The "Database error saving new user" error is almost always caused by:
1. ❌ A failing database trigger on `auth.users`
2. ❌ RLS policy blocking related table inserts
3. ❌ Foreign key constraint issues
4. ❌ A function that runs on user creation failing

**Quick fix**: Disable all triggers on `auth.users`, test signup, then re-enable and fix the problematic trigger.

**Best fix**: Update triggers/functions to handle errors gracefully and use `SECURITY DEFINER`.
