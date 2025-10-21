# Admin Panel - Quick Reference

## 🚀 Quick Setup (3 Steps)

### 1. Run SQL Setup
Open Supabase SQL Editor and run: `supabase docs/admin_panel_setup.sql`

### 2. Create Your Admin User
```sql
-- Find your user ID
SELECT id, email FROM auth.users WHERE email = 'your-email@sou.ufmt.br';

-- Make yourself admin (replace with your actual user_id)
INSERT INTO public.roles (user_id, role)
VALUES ('your-user-id-here', 'admin');
```

### 3. Test Access
1. Log in to the app with your email
2. Go to Home page
3. Look for the admin settings icon (⚙️) in the AppBar
4. Click it to access the Admin Panel

## 📋 Available Roles

| Role | Access Level | Can Manage Users |
|------|-------------|------------------|
| `admin` | Full access to all CRUD operations | ✅ Yes |
| `moderator` | Content management only | ❌ No |
| `user` | No admin access | ❌ No |

## 🎯 CRUD Cards in Admin Panel

| Card | Entity | Icon | Color | Access |
|------|--------|------|-------|--------|
| Atléticas | Athletics | ♟️ | Blue | Admin/Mod |
| Modalidades | Modalities | 🏆 | Orange | Admin/Mod |
| Jogos | Games | ⚽ | Green | Admin/Mod |
| Notícias | News | 📰 | Red | Admin/Mod |
| Atletas | Athletes | 🏃 | Purple | Admin/Mod |
| Locais | Venues | 📍 | Teal | Admin/Mod |
| Chaveamento | Brackets | 📊 | Indigo | Admin/Mod |
| Usuários | Users | 👥 | Pink | **Admin only** |

## 🔐 Security Features

### Frontend Protection
- ✅ Admin icon only visible to admin/moderator
- ✅ Access check on Admin Panel page load
- ✅ "Access Denied" for unauthorized users
- ✅ Different UI for admin vs moderator

### Backend Protection (RLS)
- ✅ Row Level Security on `roles` table
- ✅ Users can only read their own role
- ✅ Only admins can modify roles
- ⚠️ Remember to apply RLS to protected tables (see SQL file)

## 🛠️ Common Tasks

### Add a Moderator
```sql
INSERT INTO public.roles (user_id, role)
VALUES ('user-uuid-here', 'moderator');
```

### Change User Role
```sql
UPDATE public.roles
SET role = 'admin'
WHERE user_id = 'user-uuid-here';
```

### Remove Admin Access
```sql
UPDATE public.roles
SET role = 'user'
WHERE user_id = 'user-uuid-here';
```

### View All Admins
```sql
SELECT u.email, r.role, r.created_at
FROM public.roles r
JOIN auth.users u ON r.user_id = u.id
WHERE r.role IN ('admin', 'moderator')
ORDER BY r.role, u.email;
```

## 📁 File Structure

```
lib/
├── core/
│   ├── data/services/
│   │   └── auth_service.dart         ← Role checking methods
│   └── routes/
│       └── app_routes.dart           ← Admin panel route
└── features/
    ├── admin/
    │   └── admin_panel_page.dart     ← NEW: Main admin panel
    └── users/home/
        └── home_page.dart            ← Admin icon in AppBar
```

## 🐛 Troubleshooting

### Admin icon not showing
```sql
-- Check if you have admin/moderator role
SELECT r.role 
FROM public.roles r 
WHERE r.user_id = auth.uid();
```

### Access denied in Admin Panel
1. Verify role in database (query above)
2. Log out and log back in
3. Check console for errors
4. Verify RLS policies on `roles` table

### Role not updating
- Roles are checked when page loads
- After changing role in database, close and reopen the app
- Or navigate away from home and back

## 📝 Next Steps

1. **Implement CRUD Pages**: Create individual pages for each entity
2. **Add RLS Policies**: Protect all tables in Supabase
3. **Create Services**: Build services for each entity (AthleticsService, GamesService, etc.)
4. **Add Forms**: Create forms for Create/Update operations
5. **Add Confirmation Dialogs**: Before deleting records
6. **Add Search & Filters**: In list views
7. **Add Pagination**: For large datasets
8. **Add Audit Logging**: Track who changed what and when

## 🔗 Related Documentation

- Full Documentation: `ADMIN_PANEL_DOCUMENTATION.md`
- SQL Setup: `supabase docs/admin_panel_setup.sql`
- Auth Service: `lib/core/data/services/auth_service.dart`
- Tables Schema: `supabase docs/tables.md`

## 📞 Support

If you encounter issues:
1. Check Supabase logs for errors
2. Verify RLS policies are not blocking queries
3. Test with a fresh user account
4. Check the console for frontend errors
5. Review the full documentation

## ⚡ Pro Tips

1. **Always test with different roles** before deploying
2. **Keep audit logs** of admin actions
3. **Use soft deletes** instead of hard deletes when possible
4. **Add confirmation dialogs** for destructive actions
5. **Implement undo functionality** for accidental changes
6. **Rate limit admin actions** to prevent abuse
7. **Log out admins after inactivity** for security
