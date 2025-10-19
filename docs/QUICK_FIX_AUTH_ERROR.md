# Quick Fix: "Database error saving new user"

## 🚨 Problem
Getting error `{"code":"unexpected_failure","message":"Database error saving new user"}` when trying to sign up.

## ✅ Solution (5 Minutes)

### Step 1: Run the Fix Script

1. Go to **Supabase Dashboard**: https://app.supabase.com
2. Select your project: **cipsznaudjkrpzzruhvp**
3. Navigate to **SQL Editor**
4. Click **+ New query**
5. Copy the entire content from `supabase_docs/fix_auth_database_error.sql`
6. Paste it and click **Run**

### Step 2: Verify the Fix

After running the script, you should see output showing:
- ✅ Trigger `on_auth_user_created` created
- ✅ Function `handle_new_user()` created
- ✅ RLS policies updated

### Step 3: Test Signup

1. Open your app: `flutter run -d chrome`
2. Try to sign up with: `test@sou.ufmt.br`
3. You should receive a magic link email
4. Check Supabase Dashboard → **Authentication** → **Users** to see if user was created

---

## 🔍 What This Fix Does

The error happens because Supabase tries to automatically create a role for new users, but the `roles` table doesn't have the right permissions.

The fix script:
1. Creates a `handle_new_user()` function that safely creates roles
2. Adds error handling so user creation doesn't fail
3. Updates RLS policies to allow the trigger to insert roles
4. Adds necessary indexes for performance

---

## 🎯 Alternative: Disable Auto-Role Creation

If you don't need automatic role creation, you can disable it:

```sql
-- Run this in Supabase SQL Editor
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
```

Then create roles manually in your app when needed.

---

## 📝 Check Logs for Details

If still not working:

1. Go to **Supabase Dashboard**
2. **Logs** → **Database** (check around signup time)
3. **Logs** → **Auth** (check for specific error details)
4. Look for the exact error message

---

## 💡 Common Issues After Fix

### Issue: "Email already exists"
**Fix**: Delete the test user first:
```sql
DELETE FROM auth.users WHERE email = 'test@sou.ufmt.br';
```

### Issue: "Email not received"
**Fix**: Check spam folder or configure custom SMTP in **Project Settings** → **Authentication** → **SMTP Settings**

### Issue: Domain restriction error
**Fix**: Make sure your email matches the allowed domain in `auth_service.dart`:
```dart
static const List<String> allowedDomains = [
  'sou.ufmt.br',  // Your email must end with @sou.ufmt.br
];
```

---

## ✨ Success!

After the fix, you should be able to:
- ✅ Sign up with email
- ✅ Receive magic link
- ✅ Authenticate successfully
- ✅ Vote for your athletic

---

**Next**: Read `docs/EMAIL_AUTH_SETUP.md` for complete configuration options.
