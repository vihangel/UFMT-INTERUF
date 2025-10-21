# Venues CRUD - Quick Reference

## 🚀 Quick Access
1. Login as admin/moderator
2. Home → Admin icon (⚙️)
3. Click "Locais" card
4. Manage venues!

## ✨ Features at a Glance

### 📋 List View
- Search by name or address
- Filter: All | With Coordinates | Without Coordinates
- Visual indicators (🟢 with coords, 🟠 without)
- Refresh button

### ➕ Create Venue
- Click floating "Novo Local" button
- Fill form (name required)
- Coordinates optional (lat/lng)
- Instant validation

### ✏️ Edit Venue
- Tap card OR
- Menu (⋮) → Edit
- Update fields
- Save changes

### 🗑️ Delete Venue
- Menu (⋮) → Delete
- Confirm deletion
- Cannot be undone!

### 🗺️ Google Maps
- Menu (⋮) → Open Map
- Only for venues with coordinates
- Opens Google Maps

## 📝 Form Fields

| Field | Required | Validation |
|-------|----------|------------|
| Name | ✅ Yes | Cannot be empty |
| Address | ❌ No | None |
| Latitude | ❌ No | -90 to 90 if provided |
| Longitude | ❌ No | -180 to 180 if provided |

## 💡 Tips

### Getting Coordinates
1. Open Google Maps
2. Right-click on location
3. Click coordinates to copy
4. Paste in form (separate lat and lng)

### Best Practices
- Always add address for better identification
- Add coordinates for map functionality
- Use descriptive names
- Check for duplicates before creating

### Common Actions
```
Create:  Float button → Fill form → Create
Edit:    Tap card → Modify → Save
Delete:  Menu → Delete → Confirm
Search:  Type in search bar
Filter:  Click filter chips
Map:     Menu → Open Map (if has coords)
```

## 🎯 Keyboard Shortcuts
- **Search**: Just start typing
- **Clear search**: Click × button
- **Refresh**: Click 🔄 icon

## 📊 Status Indicators

| Icon | Meaning |
|------|---------|
| 🟢 | Venue has coordinates |
| 🟠 | Venue missing coordinates |
| 📌 | Coordinates displayed |
| 🔄 | Refresh/reload |
| ⋮ | More options menu |

## ⚠️ Important Notes

1. **Deletion is permanent** - No undo!
2. **Coordinates are optional** - But needed for maps
3. **Both lat/lng required** - For map functionality
4. **Search is instant** - Filters as you type
5. **Changes save immediately** - No draft mode

## 🐛 Troubleshooting

### Can't see venues
→ Check internet connection  
→ Verify you're logged in  
→ Try refreshing (🔄)

### Can't create venue
→ Fill required fields (name)  
→ Check coordinate format  
→ Verify you have permissions

### Map not opening
→ Venue needs coordinates  
→ Check lat/lng are valid numbers  
→ Allow browser to open URLs

### Search not working
→ Clear filter chips  
→ Try different search terms  
→ Refresh and try again

## 📱 Mobile Tips
- Swipe to see full address
- Long press for menu
- Pinch to zoom (future map feature)

## 🔐 Permissions Required
- Admin or Moderator role
- Access to admin panel
- Authenticated session

## 🎨 UI Overview

```
┌─────────────────────────────┐
│ ← Gerenciar Locais      🔄 │
├─────────────────────────────┤
│ 🔍 Search...            ×  │
│ [All] [With] [Without]      │
├─────────────────────────────┤
│ 🟢 Venue Name           ⋮  │
│    Address here             │
│    📌 Lat: X, Lng: Y        │
├─────────────────────────────┤
│ 🟠 Another Venue        ⋮  │
│    No coordinates           │
└─────────────────────────────┘
                    [+ New Venue]
```

## 🚦 Quick Start Checklist

- [ ] Access admin panel
- [ ] Click "Locais" card
- [ ] Click "+ Novo Local"
- [ ] Enter venue name
- [ ] Add address (recommended)
- [ ] Add coordinates (optional)
- [ ] Click "Criar"
- [ ] Done! ✅

## 📞 Need Help?
See full documentation: `VENUES_CRUD_DOCUMENTATION.md`

---

**Quick tip**: Start with name and address, add coordinates later!
