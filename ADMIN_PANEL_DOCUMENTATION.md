# Admin Panel - Documentation

## Overview
The Admin Panel is a restricted area accessible only to users with `admin` or `moderator` roles. This panel provides CRUD (Create, Read, Update, Delete) operations for managing the application's content.

## Access Control

### Role-Based Access
The system uses the `roles` table in the database to determine user permissions:

```sql
CREATE TABLE public.roles (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  role text NOT NULL CHECK (role = ANY (ARRAY['admin'::text, 'moderator'::text, 'user'::text])),
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT roles_pkey PRIMARY KEY (id),
  CONSTRAINT roles_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
```

### Role Hierarchy
- **Admin**: Full access to all CRUD operations, including user management
- **Moderator**: Access to content management (athletics, games, news, etc.), but no user management
- **User**: Regular user with no admin access

## Features

### 1. Authentication Check
The `AuthService` has been extended with role-checking methods:

```dart
// Get user's role from database
Future<String?> getUserRole()

// Check if user is admin
Future<bool> isAdmin()

// Check if user is moderator
Future<bool> isModerator()

// Check if user is admin or moderator
Future<bool> isAdminOrModerator()
```

### 2. Admin Icon on Home Page
- The admin panel icon appears in the AppBar of the Home page
- Only visible to authenticated users with `admin` or `moderator` roles
- Icon: `Icons.admin_panel_settings`
- Navigates to `/admin-panel` route

### 3. Admin Panel Page
Location: `lib/features/admin/admin_panel_page.dart`

#### Access Control
The page checks authorization on load:
- If not authenticated → Shows "Access Denied" message
- If authenticated but not admin/moderator → Shows "Access Denied" message
- If authorized → Shows the admin panel with CRUD cards

#### CRUD Cards
The panel displays cards for managing different entities:

1. **Atléticas** (Athletics)
   - Icon: Chess Pawn
   - Color: Blue
   - Manage athletic teams

2. **Modalidades** (Modalities)
   - Icon: Trophy
   - Color: Orange
   - Manage sports modalities

3. **Jogos** (Games)
   - Icon: Soccer Ball
   - Color: Green
   - Manage game schedules and results

4. **Notícias** (News)
   - Icon: Newspaper
   - Color: Red
   - Manage news articles

5. **Atletas** (Athletes)
   - Icon: Running Person
   - Color: Purple
   - Manage athlete profiles

6. **Locais** (Venues)
   - Icon: Location Pin
   - Color: Teal
   - Manage venue information

7. **Chaveamento** (Brackets)
   - Icon: Diagram/Project
   - Color: Indigo
   - Manage tournament brackets

8. **Usuários** (Users) - Admin Only
   - Icon: Users
   - Color: Pink
   - Manage user accounts and roles
   - **Only visible to admins**

## Implementation Guide

### Step 1: Assign Roles in Database

To give a user admin or moderator access, insert a record in the `roles` table:

```sql
-- Make a user an admin
INSERT INTO public.roles (user_id, role)
VALUES ('user-uuid-here', 'admin');

-- Make a user a moderator
INSERT INTO public.roles (user_id, role)
VALUES ('user-uuid-here', 'moderator');
```

### Step 2: Access the Admin Panel

1. Log in with an admin or moderator account
2. Go to the Home page
3. Click the admin settings icon in the AppBar
4. You'll be redirected to the Admin Panel

### Step 3: Create Individual CRUD Pages

Each card in the Admin Panel currently shows a "Coming Soon" dialog. To implement the actual CRUD pages:

1. Create a new page in `lib/features/admin/` for each entity
   - Example: `lib/features/admin/athletics_crud_page.dart`

2. Update the `onTap` callback in `admin_panel_page.dart`:
   ```dart
   _buildCrudCard(
     context: context,
     title: 'Atléticas',
     icon: FontAwesomeIcons.chessPawn,
     color: Colors.blue,
     onTap: () {
       context.pushNamed(AthleticsCrudPage.routename);
     },
   ),
   ```

3. Add the route in `app_routes.dart`:
   ```dart
   GoRoute(
     name: AthleticsCrudPage.routename,
     path: '/admin-panel/athletics',
     builder: (context, state) => const AthleticsCrudPage(),
   ),
   ```

## Security Considerations

### Frontend Protection
- Admin icon only shows if user has admin/moderator role
- Admin Panel page checks authorization on load
- Access denied message shown to unauthorized users

### Backend Protection (Recommended)
You should also implement Row Level Security (RLS) policies in Supabase to protect your tables:

```sql
-- Example RLS policy for athletics table
-- Only admins and moderators can INSERT/UPDATE/DELETE

-- Allow all to read
CREATE POLICY "Anyone can view athletics"
  ON public.athletics FOR SELECT
  USING (true);

-- Only admins/moderators can insert
CREATE POLICY "Only admins/moderators can insert athletics"
  ON public.athletics FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.roles
      WHERE user_id = auth.uid()
      AND role IN ('admin', 'moderator')
    )
  );

-- Only admins/moderators can update
CREATE POLICY "Only admins/moderators can update athletics"
  ON public.athletics FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.roles
      WHERE user_id = auth.uid()
      AND role IN ('admin', 'moderator')
    )
  );

-- Only admins/moderators can delete
CREATE POLICY "Only admins/moderators can delete athletics"
  ON public.athletics FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM public.roles
      WHERE user_id = auth.uid()
      AND role IN ('admin', 'moderator')
    )
  );
```

Apply similar policies to all tables that should be protected:
- `athletics`
- `modalities`
- `games`
- `news`
- `athletes`
- `venues`
- `brackets`

For the `roles` table, only admins should be able to modify:

```sql
-- Only admins can insert/update/delete roles
CREATE POLICY "Only admins can manage roles"
  ON public.roles FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.roles
      WHERE user_id = auth.uid()
      AND role = 'admin'
    )
  );

-- Anyone authenticated can read their own role
CREATE POLICY "Users can read their own role"
  ON public.roles FOR SELECT
  USING (user_id = auth.uid());
```

## File Structure

```
lib/
├── core/
│   ├── data/
│   │   └── services/
│   │       └── auth_service.dart (updated with role methods)
│   └── routes/
│       └── app_routes.dart (added admin-panel route)
└── features/
    ├── admin/
    │   ├── admin_panel_page.dart (NEW - main admin panel)
    │   └── [future CRUD pages will go here]
    └── users/
        └── home/
            └── home_page.dart (updated with admin icon)
```

## Next Steps

1. **Create Individual CRUD Pages**: Implement the actual management pages for each entity
2. **Implement RLS Policies**: Add database-level security in Supabase
3. **Add Statistics Dashboard**: Create a dashboard showing key metrics
4. **Add Audit Logging**: Track admin/moderator actions
5. **Add Bulk Operations**: Allow bulk create/update/delete operations
6. **Add Search & Filters**: Implement search and filtering for each entity

## Testing

### Test as Admin
1. Insert an admin role for your user in the database
2. Log in to the app
3. Verify the admin icon appears on home page
4. Click it and verify access to admin panel
5. Verify "ADMIN" badge shows in AppBar
6. Verify all 8 cards are visible (including Users card)

### Test as Moderator
1. Insert a moderator role for a different user
2. Log in with that user
3. Verify the admin icon appears
4. Click it and verify access to admin panel
5. Verify "MODERADOR" badge shows in AppBar
6. Verify only 7 cards are visible (Users card should be hidden)

### Test as Regular User
1. Log in with a user that has no role or 'user' role
2. Verify the admin icon does NOT appear on home page
3. Manually navigate to `/admin-panel` (if possible)
4. Verify "Access Denied" message shows

### Test as Not Authenticated
1. Log out
2. Verify the admin icon does NOT appear
3. Manually navigate to `/admin-panel`
4. Verify "Access Denied" message shows

## Troubleshooting

### Admin icon not showing
- Check if user is authenticated: `AuthService.isAuthenticated`
- Check if role exists in database: `SELECT * FROM roles WHERE user_id = 'your-user-id'`
- Check if role is 'admin' or 'moderator'
- Check console for any errors in `_checkUserRole()`

### "Access Denied" message in Admin Panel
- Verify the user has the correct role in the database
- Check if `getUserRole()` is returning the correct value
- Verify RLS policies on `roles` table allow reading own role

### Role not updating after database change
- The role is checked when the page loads
- If you change the role in database, restart the app or re-navigate to home page
- Consider adding a refresh mechanism or listening to role changes

## Support

For issues or questions:
1. Check the Supabase dashboard for role records
2. Check the app logs for authentication errors
3. Verify RLS policies are not blocking role queries
4. Test with a new user to isolate the issue
