# Voting System Implementation

## Overview
This document explains the voting system implementation for the UFMT InterUF app, which allows users to vote for their favorite athletic teams across different platforms (Android, iOS, Web).

## Solution: UUID-Based Voter Identification

### Why UUID?
We use a **UUID (Universally Unique Identifier)** approach combined with **local storage** to identify voters across different platforms. This solution:

1. **Works on all platforms** (Android, iOS, Web, Desktop)
2. **Preserves privacy** - no personal information required
3. **Persists across sessions** - stored in SharedPreferences
4. **Allows vote changes** - users can change their vote
5. **Platform tracking** - includes platform prefix for analytics

### Voter ID Format
```
{platform}-{uuid}
```

Examples:
- `android-550e8400-e29b-41d4-a716-446655440000`
- `ios-6ba7b810-9dad-11d1-80b4-00c04fd430c8`
- `web-6ba7b814-9dad-11d1-80b4-00c04fd430c8`

## Database Schema

### `athletic_vote` Table
```sql
CREATE TABLE athletic_vote (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  athletic_id UUID NOT NULL REFERENCES athletics(id),
  votante_id TEXT NOT NULL,
  series TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(votante_id)  -- Ensures one vote per user
);

-- Index for faster queries
CREATE INDEX idx_athletic_vote_votante_id ON athletic_vote(votante_id);
CREATE INDEX idx_athletic_vote_athletic_id ON athletic_vote(athletic_id);
CREATE INDEX idx_athletic_vote_series ON athletic_vote(series);
```

## Implementation Details

### VotingService (`lib/core/services/voting_service.dart`)

#### Key Methods:

1. **`getOrCreateVotanteId()`**
   - Gets existing voter ID or creates a new one
   - Stores in SharedPreferences for persistence
   - Returns: String (voter ID)

2. **`vote(athleticId, series)`**
   - Registers a vote for an athletic
   - Handles vote changes (deletes old vote)
   - Prevents duplicate votes for same athletic
   - Stores vote status locally

3. **`hasVoted()`**
   - Checks if user has already voted
   - Returns: bool

4. **`getVotedAthleticId()`**
   - Gets the ID of the athletic the user voted for
   - Returns: String? (athletic ID or null)

5. **`clearVote()`**
   - Removes vote from database and local storage
   - Useful for testing or allowing vote reset

### Integration in `escolha_atletica_page.dart`

The page automatically:
1. Initializes VotingService on page load
2. Registers vote when user clicks "Escolher"
3. Shows loading indicator during vote registration
4. Displays success/error messages
5. Saves athletic preference locally
6. Navigates to home page

## User Flow

```
1. User opens app → EscolhaAtleticaPage
2. User selects athletic from carousel
3. User clicks "Escolher" button
   ├─ Loading indicator shown
   ├─ VotingService generates/retrieves voter ID
   ├─ Vote inserted into database
   ├─ Vote status saved locally
   ├─ Success message shown
   └─ Navigate to home page
```

## Vote Change Handling

When a user changes their vote:
1. System checks if user has already voted
2. If yes, deletes the old vote from database
3. Inserts new vote
4. Updates local storage

## Privacy & Security Considerations

### What We Store:
- ✅ Randomly generated UUID
- ✅ Platform information (android/ios/web)
- ✅ Athletic choice
- ✅ Vote timestamp

### What We DON'T Store:
- ❌ Personal information (name, email, phone)
- ❌ Device IMEI or serial numbers
- ❌ IP addresses
- ❌ Location data
- ❌ User accounts (anonymous voting)

## Querying Votes

### Get Vote Count by Athletic (Torcidômetro)
```sql
SELECT 
  COUNT(*) as pontos,
  a.nickname as nome,
  a.logo_url as logo
FROM athletic_vote av
INNER JOIN athletics a ON av.athletic_id = a.id
WHERE av.series = 'A'
GROUP BY a.nickname, a.logo_url
ORDER BY pontos DESC;
```

### Get Total Votes by Series
```sql
SELECT 
  series,
  COUNT(*) as total_votes
FROM athletic_vote
GROUP BY series;
```

### Get Votes by Platform
```sql
SELECT 
  CASE 
    WHEN votante_id LIKE 'android-%' THEN 'Android'
    WHEN votante_id LIKE 'ios-%' THEN 'iOS'
    WHEN votante_id LIKE 'web-%' THEN 'Web'
    ELSE 'Other'
  END as platform,
  COUNT(*) as votes
FROM athletic_vote
GROUP BY platform;
```

## Testing

### Debug Voting Stats
```dart
final votingService = VotingService(Supabase.instance.client);
final stats = await votingService.getVotingStats();
print(stats);
// Output: {votante_id: android-..., has_voted: true, voted_for: athletic-id}
```

### Clear Vote (for testing)
```dart
await votingService.clearVote();
```

## Limitations & Considerations

### Current Approach (UUID + Local Storage):
- ✅ Simple and works on all platforms
- ✅ No authentication required
- ✅ Privacy-friendly
- ⚠️ Users can reset app data to vote again
- ⚠️ Multiple devices = multiple votes
- ⚠️ Uninstall/reinstall = new voter ID

### Alternative Approaches (Future Enhancements):

1. **Device Fingerprinting**
   - Use device_info_plus for hardware IDs
   - More persistent but privacy concerns
   
2. **Authentication-Based**
   - Supabase Auth with email/phone
   - One vote per account
   - Best for preventing fraud

3. **IP-Based Limiting**
   - Rate limiting by IP address
   - Works for web, limited on mobile

## Dependencies Added

```yaml
dependencies:
  uuid: ^4.5.1  # For generating unique voter IDs
```

## Files Modified/Created

### Created:
- `lib/core/services/voting_service.dart` - Voting logic
- `docs/VOTING_SYSTEM.md` - This documentation

### Modified:
- `lib/features/escolha_atletica_page.dart` - Added voting integration
- `pubspec.yaml` - Added uuid dependency

## Future Enhancements

1. **Vote Analytics Dashboard**
   - Real-time vote tracking
   - Platform breakdown
   - Time-series data

2. **Vote Verification**
   - Email/SMS verification (optional)
   - reCAPTCHA for web

3. **Vote Campaigns**
   - Time-limited voting periods
   - Multiple voting categories

4. **Social Features**
   - Share vote on social media
   - See friends' votes (if authenticated)

## Support

For questions or issues, contact the development team.
