# News CRUD Implementation - Complete Documentation

## 📋 Overview

This document provides comprehensive documentation for the **News CRUD** (Create, Read, Update, Delete) feature implemented in the InterUF application. This feature allows administrators and moderators to manage news articles through a user-friendly interface.

## ✨ Features

### Core Functionality
- ✅ **Create News**: Add new news articles with title, summary, body, images, and publication dates
- ✅ **Read/List News**: View all news articles with filtering and search capabilities
- ✅ **Update News**: Edit existing news articles
- ✅ **Delete News**: Remove news articles with confirmation
- ✅ **Search**: Real-time search by title or summary
- ✅ **Filter**: Filter by publication status (All, Published, Drafts)
- ✅ **Image Support**: Display news images with error handling
- ✅ **Source Links**: Add and access external source URLs
- ✅ **Date/Time Picker**: Schedule publication dates
- ✅ **Draft System**: Save news as drafts (unpublished)

### User Interface
- 📱 Responsive design
- 🔍 Search bar with real-time filtering
- 🏷️ Filter chips for quick categorization
- 📅 Visual publication status indicators
- 🖼️ Image preview in news cards
- ⏱️ Formatted date/time display
- 🔗 Clickable source links
- ↻ Pull-to-refresh support

## 🗂️ Files Structure

### New Files Created
```
lib/features/admin/
  ├── news_crud_page.dart          # Main CRUD page (800+ lines)
```

### Modified Files
```
lib/core/data/services/
  └── news_service.dart             # Added CRUD methods
  
lib/core/data/repositories/
  └── news_repository.dart          # Added CRUD methods

lib/core/routes/
  └── app_routes.dart               # Added news CRUD route

lib/features/admin/
  └── admin_panel_page.dart         # Updated Notícias card navigation
```

## 🎯 Usage Guide

### Accessing News CRUD
1. Log in as **admin** or **moderator**
2. Navigate to **Home Page**
3. Click the **admin icon** (gear icon) in the app bar
4. Click on the **Notícias** card (red, newspaper icon)

### Creating a News Article

1. Click the **"Nova Notícia"** floating action button
2. Fill in the form:
   - **Título** (required): News headline
   - **Resumo** (optional): Brief description
   - **Conteúdo** (optional): Full article content
   - **URL da Imagem** (optional): Link to news image
   - **Link da Fonte** (optional): External source URL
   - **Data de Publicação** (optional): When to publish
3. Click **"Criar"** to save

**Tips:**
- Leave publication date empty to save as draft
- Set future date to schedule publication
- Validate URLs before submitting

### Editing a News Article

1. Find the news in the list
2. Click the **three-dot menu** on the news card
3. Select **"Editar"**
4. Modify the fields
5. Click **"Salvar"**

### Deleting a News Article

1. Find the news in the list
2. Click the **three-dot menu** on the news card
3. Select **"Excluir"**
4. Confirm the deletion in the dialog

**⚠️ Warning:** Deletion is permanent and cannot be undone!

### Searching News

- Type in the search bar at the top
- Search works on **title** and **summary** fields
- Results update in real-time

### Filtering News

Use the filter chips below the search bar:
- **Todas**: Show all news articles
- **Publicadas**: Show only published news (published_at ≤ now)
- **Rascunhos**: Show only drafts (published_at is null or future)

### Opening Source Links

- Click the **"Fonte"** link on news cards
- Opens the external source in a browser

## 🔧 Technical Details

### Data Model

```dart
class News {
  final String id;              // Auto-generated UUID
  final String title;           // Required
  final String? summary;        // Optional
  final String? body;           // Optional
  final String? imageUrl;       // Optional
  final DateTime? publishedAt;  // Optional (null = draft)
  final String? sourceUrl;      // Optional
  final DateTime createdAt;     // Auto-generated
  final DateTime updatedAt;     // Auto-updated
}
```

### Database Schema

**Table:** `news`

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | uuid | No | Primary key (auto-generated) |
| title | text | No | News headline |
| summary | text | Yes | Brief description |
| body | text | Yes | Full article content |
| image_url | text | Yes | URL to news image |
| published_at | timestamp | Yes | Publication date/time |
| source_url | text | Yes | External source link |
| created_at | timestamp | No | Creation timestamp |
| updated_at | timestamp | No | Last update timestamp |

### Service Layer

**NewsService** (`lib/core/data/services/news_service.dart`)

```dart
// Get all news (admin view)
Future<List<News>> getAllNews()

// Create new news
Future<News> createNews({
  required String title,
  String? summary,
  String? body,
  String? imageUrl,
  DateTime? publishedAt,
  String? sourceUrl,
})

// Update existing news
Future<News> updateNews({
  required String id,
  required String title,
  String? summary,
  String? body,
  String? imageUrl,
  DateTime? publishedAt,
  String? sourceUrl,
})

// Delete news
Future<void> deleteNews(String id)
```

### Repository Layer

**NewsRepository** (`lib/core/data/repositories/news_repository.dart`)

Acts as an abstraction layer between service and UI, exposing the same methods as NewsService.

### State Management

**NewsCrudPage** uses local state management:

```dart
List<News> _news = [];              // All news from database
List<News> _filteredNews = [];      // Filtered/searched news
bool _isLoading = true;             // Loading state
String _searchQuery = '';           // Current search query
String _filterType = 'all';         // Current filter (all/published/draft)
```

### Key Methods

#### `_loadNews()`
Fetches all news from repository and applies filters.

```dart
Future<void> _loadNews() async {
  setState(() => _isLoading = true);
  final news = await repository.getAllNews();
  setState(() {
    _news = news;
    _applyFilters();
    _isLoading = false;
  });
}
```

#### `_applyFilters()`
Filters news based on search query and filter type.

```dart
void _applyFilters() {
  _filteredNews = _news.where((news) {
    // Search filter
    final matchesSearch = _searchQuery.isEmpty ||
        news.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        (news.summary?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);

    // Type filter
    final now = DateTime.now();
    final matchesType = _filterType == 'all' ||
        (_filterType == 'published' && news.publishedAt != null && news.publishedAt!.isBefore(now)) ||
        (_filterType == 'draft' && (news.publishedAt == null || news.publishedAt!.isAfter(now)));

    return matchesSearch && matchesType;
  }).toList();
}
```

## 🎨 UI Components

### Main Page (`NewsCrudPage`)

**AppBar:**
- Title: "Gerenciar Notícias"
- Refresh button

**Search Bar:**
- Placeholder: "Buscar por título ou resumo..."
- Real-time filtering
- Search icon prefix

**Filter Chips:**
- Todas (All)
- Publicadas (Published)
- Rascunhos (Drafts)

**News List:**
- Card layout with image preview
- Publication status badge
- Date/time display
- Source link
- Popup menu (Edit/Delete)

**Floating Action Button:**
- Icon: Add
- Label: "Nova Notícia"
- Opens create dialog

### Form Dialog (`_NewsFormDialog`)

**Header:**
- Icon and title (Nova Notícia / Editar Notícia)
- Close button

**Form Fields:**
1. **Título** (TextFormField)
   - Required
   - Max 2 lines
   - Title icon

2. **Resumo** (TextFormField)
   - Optional
   - Max 3 lines
   - Short text icon
   - Helper text

3. **Conteúdo** (TextFormField)
   - Optional
   - Max 8 lines
   - Article icon
   - Helper text

4. **URL da Imagem** (TextFormField)
   - Optional
   - URL validation
   - Image icon

5. **Link da Fonte** (TextFormField)
   - Optional
   - URL validation
   - Link icon
   - Helper text

6. **Data de Publicação** (DateTimePicker)
   - Optional
   - Date + Time selection
   - Clear button
   - Calendar icon

**Info Box:**
- Blue background
- Explains draft behavior
- Info icon

**Actions:**
- Cancel button
- Save/Create button (with loading state)

## 📊 Data Flow

### Create Flow
```
User clicks FAB
    ↓
Opens _NewsFormDialog (empty)
    ↓
User fills form
    ↓
User clicks "Criar"
    ↓
Validation runs
    ↓
repository.createNews()
    ↓
newsService.createNews()
    ↓
Supabase insert
    ↓
_loadNews() refreshes list
    ↓
Success message shown
```

### Update Flow
```
User clicks Edit in menu
    ↓
Opens _NewsFormDialog (pre-filled)
    ↓
User modifies form
    ↓
User clicks "Salvar"
    ↓
Validation runs
    ↓
repository.updateNews()
    ↓
newsService.updateNews()
    ↓
Supabase update
    ↓
_loadNews() refreshes list
    ↓
Success message shown
```

### Delete Flow
```
User clicks Delete in menu
    ↓
Confirmation dialog shown
    ↓
User confirms
    ↓
repository.deleteNews()
    ↓
newsService.deleteNews()
    ↓
Supabase delete
    ↓
_loadNews() refreshes list
    ↓
Success message shown
```

## ✅ Form Validation

### Title Field
- **Required**: Cannot be empty
- **Error**: "Título é obrigatório"

### Image URL Field
- **Format**: Must be valid URL if provided
- **Error**: "URL inválida"

### Source URL Field
- **Format**: Must be valid URL if provided
- **Error**: "URL inválida"

### Other Fields
- No validation (optional)

## 🎯 Publication Logic

### Draft Status
News is considered a **draft** if:
- `published_at` is `null`, OR
- `published_at` is in the future

### Published Status
News is considered **published** if:
- `published_at` is NOT `null`, AND
- `published_at` is in the past or present

### User-Facing Display
The main news page (`NewsPage`) only shows published news:
```dart
.lt('published_at', DateTime.now())
```

## 🔐 Security Considerations

### Current Implementation
- ✅ Role-based access to admin panel
- ✅ Access restricted to admin/moderator roles
- ⚠️ Direct Supabase client access (no RLS yet)

### Recommended Security Enhancements

1. **Row Level Security (RLS)**
```sql
-- Enable RLS on news table
ALTER TABLE news ENABLE ROW LEVEL SECURITY;

-- Allow admins and moderators to manage news
CREATE POLICY "Admins and moderators can manage news"
ON news
FOR ALL
USING (
  auth.uid() IN (
    SELECT user_id FROM roles 
    WHERE role IN ('admin', 'moderator')
  )
);

-- Allow everyone to read published news
CREATE POLICY "Everyone can read published news"
ON news
FOR SELECT
USING (published_at <= NOW());
```

2. **Route Guards**
```dart
redirect: (BuildContext context, GoRouterState state) {
  if (state.location.startsWith('/admin-panel')) {
    final authService = context.read<AuthService>();
    if (!authService.isAuthenticated) {
      return '/login';
    }
    // Check role in async manner
  }
  return null;
}
```

## 🧪 Testing Guide

### Manual Testing Checklist

**Create Operations:**
- [ ] Create news with all fields filled
- [ ] Create news with only required field (title)
- [ ] Create news with invalid image URL (should show error)
- [ ] Create news with invalid source URL (should show error)
- [ ] Create news with future publication date (should be draft)
- [ ] Create news without publication date (should be draft)
- [ ] Create news with past publication date (should be published)

**Read Operations:**
- [ ] View all news in list
- [ ] Verify published news show green badge
- [ ] Verify draft news show orange badge
- [ ] Verify images load correctly
- [ ] Verify placeholder shows for broken images
- [ ] Verify date formatting is correct
- [ ] Click source link (should open in browser)

**Update Operations:**
- [ ] Edit published news title
- [ ] Edit draft news and publish it
- [ ] Edit published news and unpublish it (clear date)
- [ ] Change image URL
- [ ] Clear publication date

**Delete Operations:**
- [ ] Delete draft news
- [ ] Delete published news
- [ ] Cancel deletion
- [ ] Verify news is removed from list

**Search Operations:**
- [ ] Search by title
- [ ] Search by summary
- [ ] Search with no results
- [ ] Clear search

**Filter Operations:**
- [ ] Filter "Todas" (should show all)
- [ ] Filter "Publicadas" (should show only published)
- [ ] Filter "Rascunhos" (should show only drafts)
- [ ] Combine search and filter

**UI/UX:**
- [ ] Pull to refresh works
- [ ] Loading states show correctly
- [ ] Error messages display properly
- [ ] Success messages appear
- [ ] Empty state shows when no news
- [ ] Scroll works smoothly

### Error Scenarios

Test these error conditions:
- [ ] Network failure during load
- [ ] Network failure during create
- [ ] Network failure during update
- [ ] Network failure during delete
- [ ] Invalid data from server
- [ ] Unauthorized access

## 🐛 Troubleshooting

### Common Issues

**Problem:** "Erro ao carregar notícias"
- **Cause**: Database connection issue
- **Solution**: Check Supabase configuration, verify internet connection

**Problem:** Images not loading
- **Cause**: Invalid URLs or CORS issues
- **Solution**: Verify image URLs are accessible, check CORS settings

**Problem:** Can't access news CRUD
- **Cause**: Insufficient permissions
- **Solution**: Verify user has admin or moderator role in database

**Problem:** Publication date not working
- **Cause**: Timezone issues
- **Solution**: Ensure server and client timezones are handled correctly

**Problem:** Search not working
- **Cause**: Case sensitivity or null values
- **Solution**: Already handled with `.toLowerCase()` and null-safe operators

## 🚀 Future Enhancements

### Planned Features
1. **Rich Text Editor**: WYSIWYG editor for news body
2. **Image Upload**: Direct image upload instead of URLs
3. **Categories/Tags**: Organize news by categories
4. **Author Information**: Track who created/edited news
5. **Comments**: Allow users to comment on news
6. **Analytics**: Track views, clicks, engagement
7. **Push Notifications**: Notify users of new news
8. **Social Media Integration**: Share to social platforms
9. **Multi-language Support**: News in different languages
10. **Version History**: Track changes over time

### Code Improvements
1. **Pagination**: Load news in batches for performance
2. **Caching**: Cache news data to reduce server calls
3. **Optimistic Updates**: Update UI before server confirmation
4. **Offline Support**: Allow viewing cached news offline
5. **Image Optimization**: Resize/compress images automatically
6. **Better Error Handling**: More specific error messages
7. **Undo Delete**: Soft delete with recovery option
8. **Bulk Operations**: Delete/publish multiple news at once

## 📝 Code Highlights

### Date/Time Picker Integration

```dart
Future<void> _selectDateTime() async {
  // Date picker
  final date = await showDatePicker(
    context: context,
    initialDate: _publishedAt ?? DateTime.now(),
    firstDate: DateTime(2020),
    lastDate: DateTime(2100),
  );

  if (date != null && mounted) {
    // Time picker
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_publishedAt ?? DateTime.now()),
    );

    if (time != null) {
      setState(() {
        _publishedAt = DateTime(
          date.year, date.month, date.day,
          time.hour, time.minute,
        );
      });
    }
  }
}
```

### Image Loading with Error Handling

```dart
Image.network(
  news.imageUrl!,
  height: 150,
  width: double.infinity,
  fit: BoxFit.cover,
  errorBuilder: (context, error, stack) => Container(
    height: 150,
    color: Colors.grey[300],
    child: const Icon(Icons.image_not_supported, size: 48),
  ),
)
```

### URL Launching

```dart
Future<void> _openUrl(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Não foi possível abrir o link'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
```

### Dynamic Status Badge

```dart
Container(
  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  decoration: BoxDecoration(
    color: isPublished ? Colors.green[100] : Colors.orange[100],
    borderRadius: BorderRadius.circular(12),
  ),
  child: Text(
    isPublished ? 'Publicada' : 'Rascunho',
    style: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.bold,
      color: isPublished ? Colors.green[900] : Colors.orange[900],
    ),
  ),
)
```

## 📚 Dependencies

### Required Packages

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State management
  provider: ^6.1.2
  
  # Backend
  supabase_flutter: ^2.5.6
  
  # Routing
  go_router: ^14.2.7
  
  # Date formatting
  intl: ^0.19.0
  
  # URL launching
  url_launcher: ^6.3.0
  
  # Icons
  font_awesome_flutter: ^10.7.0
```

## 📞 Support

For issues or questions:
1. Check this documentation
2. Review the code comments
3. Test in development environment first
4. Check Supabase logs for errors
5. Verify user roles in database

## 📄 License

This code is part of the InterUF project and follows the project's license terms.

---

**Last Updated:** October 19, 2025  
**Version:** 1.0.0  
**Author:** Development Team
