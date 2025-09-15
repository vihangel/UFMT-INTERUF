# Setting Up Athletics Standings Query

This document explains how to set up the Supabase function for athletics standings.

## 1. Create the Supabase Function

Execute the SQL script in `supabase docs/get_athletics_standings_function.sql` in your Supabase Dashboard's SQL Editor.

This will create a function called `get_athletics_standings(series_filter TEXT)` that returns the athletics standings for a specific series ('A' or 'B').

## 2. Function Usage

The function can be called from the Flutter app using:

```dart
final response = await supabaseClient.rpc('get_athletics_standings', params: {
  'series_filter': 'A' // or 'B'
});
```

## 3. Fallback Behavior

If the Supabase function is not available or returns an error, the app will use mock data that matches the expected format from your query result example.

## 4. Data Structure

The function returns the following columns:
- `name`: Athletic name
- `gold_medals`: Number of gold medals
- `silver_medals`: Number of silver medals
- `bronze_medals`: Number of bronze medals
- `fourth_places`: Number of fourth places
- `total_medals`: Total number of medals
- `points`: Total points calculated based on medal weighting

## 5. Testing

You can test the function in Supabase SQL Editor with:

```sql
SELECT * FROM get_athletics_standings('A');
```

This should return results similar to your provided example.

## 6. Implementation Details

The Flutter implementation:
- Uses `AthleticsService` to fetch data
- Converts database results to `Atletica` model objects
- Provides loading states and error handling
- Falls back to mock data if the database query fails

The service is integrated with Provider for dependency injection and can be accessed in widgets using:

```dart
final athleticsService = context.read<AthleticsService>();
```