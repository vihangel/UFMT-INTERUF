# Email Authentication Setup Guide

## Overview

This guide explains how to set up and use email-based authentication for the voting system. This approach is **simpler and more privacy-friendly** than Google OAuth, and allows you to **restrict voting to specific email domains** (e.g., university emails).

---

## Features

✅ **Passwordless Authentication** (Magic Link)  
✅ **Password-based Authentication** (Traditional)  
✅ **Domain Restrictions** (e.g., only @ufmt.br emails)  
✅ **One Vote Per Email**  
✅ **No External OAuth Setup Required**  
✅ **Privacy-Friendly** (no third-party tracking)  

---

## How It Works

### Magic Link Authentication (Recommended)
1. User enters their email
2. System sends an email with a magic link
3. User clicks the link in their email
4. User is automatically signed in
5. User can vote (one vote per email)

### Password Authentication (Alternative)
1. User creates an account with email + password
2. User signs in with email + password
3. User can vote (one vote per email)

---

## Step 1: Enable Email Authentication in Supabase

### 1.1 Access Supabase Dashboard
1. Go to [https://app.supabase.com](https://app.supabase.com)
2. Sign in and select your project: **cipsznaudjkrpzzruhvp**

### 1.2 Enable Email Provider
1. Navigate to **Authentication** → **Providers**
2. Find **Email** provider
3. Make sure **Enable Email provider** is **ON** (it should be enabled by default)

### 1.3 Configure Email Templates (Optional but Recommended)
1. Go to **Authentication** → **Email Templates**
2. Customize the **Magic Link** template:
   - Subject: `Seu link de autenticação - InterUFMT`
   - Body: Customize with your app's branding

---

## Step 2: Configure Domain Restrictions (Optional)

If you want to restrict voting to specific email domains (e.g., only university emails):

### 2.1 Edit `auth_service.dart`

Open `lib/core/data/services/auth_service.dart` and modify the `allowedDomains` list:

```dart
/// List of allowed email domains (add your restrictions here)
/// Example: ['ufmt.br', 'gmail.com']
/// Leave empty to allow all domains
static const List<String> allowedDomains = [
  'ufmt.br',  // Only UFMT emails
  // Add more domains as needed
];
```

**Examples:**

- **Allow only UFMT emails:**
  ```dart
  static const List<String> allowedDomains = ['ufmt.br'];
  ```

- **Allow multiple universities:**
  ```dart
  static const List<String> allowedDomains = ['ufmt.br', 'usp.br', 'unicamp.br'];
  ```

- **Allow all emails:**
  ```dart
  static const List<String> allowedDomains = [];
  ```

### 2.2 Domain Validation

The system will automatically:
- Check if the email ends with an allowed domain
- Show clear error messages if domain is not allowed
- Display allowed domains in the UI

---

## Step 3: Run the Database Migration

The migration is already created. Run it in your Supabase SQL Editor:

1. Go to **Supabase Dashboard** → **SQL Editor**
2. Create a new query
3. Copy and paste the content from `supabase_docs/athletic_vote_table_migration.sql`
4. Click **Run**

This migration:
- Adds `user_id` column (references `auth.users`)
- Adds `user_email` column
- Creates unique constraint on `user_id` (one vote per user)
- Sets up RLS policies for authenticated voting
- Creates views for vote counting

---

## Step 4: Configure Email Settings (Important for Production)

### 4.1 For Development (Using Supabase SMTP)
Supabase provides a built-in SMTP service for development. It works out of the box but has rate limits.

### 4.2 For Production (Custom SMTP - Recommended)

1. Go to **Project Settings** → **Authentication** → **SMTP Settings**
2. Enable **Custom SMTP**
3. Configure your SMTP provider (e.g., SendGrid, AWS SES, Gmail):

   ```
   SMTP Host: smtp.gmail.com (or your provider)
   SMTP Port: 587
   SMTP Username: your-email@gmail.com
   SMTP Password: your-app-password
   SMTP From Email: noreply@interufmt.com
   ```

**Popular SMTP Providers:**
- **SendGrid**: Free tier includes 100 emails/day
- **AWS SES**: $0.10 per 1,000 emails
- **Gmail**: Free but limited (for testing only)
- **Mailgun**: Free tier includes 5,000 emails/month

---

## Step 5: Test the Authentication Flow

### 5.1 Test Magic Link (Passwordless)

1. Run your app:
   ```bash
   flutter run -d chrome
   ```

2. Navigate to the athletic selection page
3. Select an athletic
4. Click "Escolher e Votar"
5. In the dialog, click "Fazer Login"
6. Enter your email (must match allowed domains if configured)
7. Click "Enviar"
8. Check your email for the magic link
9. Click the link
10. You should be authenticated and your vote registered

### 5.2 Test Domain Restrictions

1. If you configured `allowedDomains = ['ufmt.br']`
2. Try entering `test@gmail.com` → Should show error
3. Try entering `test@ufmt.br` → Should work

### 5.3 Test One Vote Per User

1. Vote for an athletic
2. Try to vote again → Should update your vote, not create a new one
3. Sign out and sign in with a different email → Should be able to vote

---

## User Flows

### Flow 1: New User Voting (Magic Link)

```
1. User selects athletic
2. User clicks "Escolher e Votar"
3. Dialog: "Login necessário"
   - Option A: "Continuar sem votar" → Saves preference only
   - Option B: "Fazer Login" → Opens email input
4. User enters email
5. System sends magic link
6. User clicks link in email
7. User is redirected back to app
8. Vote is automatically registered
9. User navigates to home
```

### Flow 2: Returning User (Already Authenticated)

```
1. User selects athletic
2. User clicks "Escolher e Votar"
3. Vote is immediately registered (no login required)
4. User navigates to home
```

### Flow 3: User Without Authentication (Optional)

```
1. User selects athletic
2. User clicks "Escolher e Votar"
3. Dialog: "Login necessário"
4. User clicks "Continuar sem votar"
5. Preference is saved locally (no vote in database)
6. User can explore app but cannot vote
7. User can login later to complete voting
```

---

## Code Structure

### `lib/core/data/services/auth_service.dart`
- `signInWithMagicLink()`: Send magic link to email
- `signInWithPassword()`: Traditional email/password login
- `signUp()`: Create new account
- `isEmailDomainAllowed()`: Validate email domain
- `allowedDomains`: List of restricted domains

### `lib/core/services/voting_service.dart`
- `vote()`: Register vote (requires authentication)
- `hasAuthenticatedUserVoted()`: Check if user voted
- `getAuthenticatedUserVote()`: Get user's current vote
- `clearVote()`: Remove user's vote

### `lib/features/escolha_atletica_page.dart`
- `_saveAndNavigate()`: Main flow - checks auth and votes
- `_showLoginDialog()`: Shows login/skip dialog
- `_handleEmailLogin()`: Handles email input and magic link
- `_showEmailInputDialog()`: Email input UI
- `_registerVoteAndNavigate()`: Registers vote after auth

---

## Troubleshooting

### Email Not Received

**Problem**: User doesn't receive the magic link email.

**Solutions**:
1. Check spam/junk folder
2. Verify SMTP settings in Supabase Dashboard
3. Check Supabase logs: **Logs** → **Auth**
4. Verify email rate limits (Supabase has rate limits on free tier)
5. Use custom SMTP provider for production

### Domain Restriction Not Working

**Problem**: Users can sign up with any email domain.

**Solutions**:
1. Verify `allowedDomains` is configured in `auth_service.dart`
2. Check that validation is running before `signInWithMagicLink()`
3. Domain check is case-insensitive (e.g., `@UFMT.BR` works if `ufmt.br` is allowed)

### Vote Not Registered

**Problem**: User clicks magic link but vote isn't registered.

**Solutions**:
1. Check that user is authenticated: `_authService.isAuthenticated`
2. Verify RLS policies are enabled in Supabase
3. Check browser console for errors
4. Ensure `user_id` column exists in `athletic_vote` table

### "Row Level Security" Error

**Problem**: Cannot insert vote due to RLS policy.

**Solutions**:
1. Run the migration in `supabase_docs/athletic_vote_table_migration.sql`
2. Verify RLS policies exist: **Authentication** → **Policies**
3. Check that policy allows `auth.uid() = user_id`

---

## Configuration Options

### Magic Link vs Password Authentication

**Magic Link (Recommended)**:
- ✅ No password to remember
- ✅ More secure (no password leaks)
- ✅ Better UX
- ❌ Requires email access

**Password Authentication**:
- ✅ Works offline (after first login)
- ✅ Faster (no email check)
- ❌ Users must remember password
- ❌ Less secure if weak passwords

### Domain Restrictions

**When to use**:
- University-only voting (e.g., `@ufmt.br`)
- Organization-specific voting
- Prevent spam/abuse

**When NOT to use**:
- Public voting (everyone can vote)
- Multiple institutions with different domains

---

## Security Considerations

### Email Verification

By default, Supabase requires email verification. This means:
- User must click the magic link to verify email
- Prevents fake email addresses
- Adds friction but increases security

To disable (NOT recommended):
1. Go to **Authentication** → **Settings**
2. Disable "Enable email confirmations"

### Rate Limiting

Supabase has built-in rate limiting:
- **Free tier**: 10,000 requests/day
- **Pro tier**: 100,000 requests/day

For custom limits:
1. Use custom SMTP provider
2. Implement additional rate limiting in your app

### CAPTCHA (Optional)

To prevent bots:
1. Go to **Authentication** → **Settings**
2. Enable "Enable CAPTCHA protection"
3. Add hCaptcha or reCAPTCHA keys

---

## Comparison: Email Auth vs Google OAuth

| Feature | Email Auth | Google OAuth |
|---------|-----------|--------------|
| **Setup Complexity** | ✅ Simple | ❌ Complex (OAuth setup) |
| **User Privacy** | ✅ High | ⚠️ Google tracks user |
| **Domain Restrictions** | ✅ Easy | ❌ Complex |
| **Authentication Speed** | ⚠️ Requires email check | ✅ Instant |
| **Offline Support** | ✅ Yes (with password) | ❌ No |
| **External Dependencies** | ✅ None | ❌ Google Cloud Console |
| **Cost** | ✅ Free (SMTP costs) | ✅ Free (OAuth is free) |

---

## Quick Reference

### Check if user is authenticated
```dart
final isAuth = _authService.isAuthenticated;
```

### Send magic link
```dart
await _authService.signInWithMagicLink('user@sou.ufmt.br');
```

### Register vote
```dart
await _votingService.vote(athleticId);
```

### Check if user voted
```dart
final hasVoted = await _votingService.hasAuthenticatedUserVoted();
```

### Get user's vote
```dart
final athleticId = await _votingService.getAuthenticatedUserVote();
```

### Sign out
```dart
await _authService.signOut();
```

---

## Next Steps

1. ✅ Run the database migration
2. ✅ Configure domain restrictions (if needed)
3. ✅ Set up custom SMTP for production
4. ✅ Test the authentication flow
5. ✅ Deploy and monitor
6. Create a privacy policy (required for email collection)
7. Add email verification reminder in UI
8. Monitor authentication logs in Supabase

---

## Support

If you encounter issues:
1. Check Supabase logs: **Logs** → **Auth**
2. Verify email was sent: **Authentication** → **Users**
3. Test with different email providers (Gmail, Outlook, etc.)
4. Check browser console for errors
5. Ensure deep linking is configured for mobile apps

For more details, see:
- [Supabase Auth Documentation](https://supabase.com/docs/guides/auth/auth-email)
- [Magic Link Documentation](https://supabase.com/docs/guides/auth/auth-magic-link)
