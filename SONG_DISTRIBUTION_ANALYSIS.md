# Song Distribution Analysis - Banks 15-16

## Current Situation

**Bank 16** (Songs Bank):
- Currently includes: 3 songs (AtariToday, Interworldly, Chaotica)
- Remaining space: **260 bytes** (nearly full!)
- Contains: MusicSystem.bas, MusicBankHelpers.bas, SongPointers.bas

**Bank 15** (Sound Effects Bank):
- Contains: SoundSystem.bas, SoundBankHelpers.bas, 10 sound effects
- Remaining space: **3015 bytes** (available)

## Songs Required (29 total)

### Character Theme Songs (26 songs, Song IDs 0-25):
1. Bernie (Song ID 0) - 30,396 bytes
2. OCascadia (Song ID 1) - 2,828 bytes  
3. Revontuli (Song ID 2) - 1,014 bytes
4. EXO (Song ID 3) - 30,390 bytes
5. Grizzards (Song ID 4) - 30,402 bytes
6. MagicalFairyForce (Song ID 5) - 30,418 bytes
7. Bolero (Song ID 6) - 7,665 bytes
8. LowRes (Song ID 7) - 30,396 bytes
9. RoboTito (Song ID 8) - 30,400 bytes
10. SongOfTheBear (Song ID 9) - 30,410 bytes
11. DucksAway (Song ID 10) - 30,402 bytes
12-26. Character16Theme-Character30Theme (Song IDs 11-25) - 786 bytes each (11,790 bytes total)

### Admin Screen Songs (3 songs, Song IDs 26-28):
27. Chaotica (Song ID 26) - 7,941 bytes ✅ **Already in Bank 16**
28. AtariToday (Song ID 27) - 3,028 bytes ✅ **Already in Bank 16**
29. Interworldly (Song ID 28) - 1,734 bytes ✅ **Already in Bank 16**

**Total character theme songs: ~266,511 bytes (260 KB)**

## Problem

**Bank 16 only has 260 bytes remaining** - cannot fit any character theme songs!

The 26 character theme songs are **NOT currently included in any bank** - they're missing from the ROM!

## Solution: Duplicate Music Player in Bank 15

### Architecture

**Option 1: Split Songs Across Banks 15-16**
- Put music player code in **both** Bank 15 and Bank 16
- Bank 15: Store some songs (e.g., smaller ones + overflow)
- Bank 16: Store remaining songs
- Each bank's music player can only access songs in its own bank

**Option 2: Unified Music Player with Bank Switching**
- Keep music player code in Bank 16 only
- Add bank switching logic to access songs in Bank 15
- More complex but avoids code duplication

### Recommendation: Option 1 (Duplicate Code)

**Why duplicate the music player:**
1. **Only one music player runs at a time** - no conflict
2. **Simpler bank switching** - each bank handles its own songs independently
3. **Clear separation** - Bank 15 songs vs Bank 16 songs
4. **Code duplication cost is minimal** - music player helpers are small

**Implementation:**

1. **Duplicate MusicBankHelpers.bas into Bank 15:**
   - Create `Source/Routines/MusicBankHelpers15.bas` (for Bank 15 songs)
   - Create `Source/Routines/MusicBankHelpers16.bas` (rename existing, for Bank 16 songs)
   - Both have same functions but access different song data

2. **Split songs between banks:**
   - **Bank 15**: Smaller songs + overflow (fit in 3015 bytes)
     - OCascadia (2,828 bytes)
     - Revontuli (1,014 bytes)
     - Character16-30 themes (11,790 bytes total) - **Won't all fit!**
   - **Bank 16**: Larger songs (need to move some out to make room)
     - Bernie, EXO, Grizzards, MagicalFairyForce, LowRes, RoboTito, SongOfTheBear, DucksAway, Bolero (all ~30KB each)

3. **Update MusicSystem.bas:**
   - Add song-to-bank mapping
   - Call appropriate bank's LoadSongPointer based on song ID

### Song Size Analysis

**Songs that fit in Bank 15 (3015 bytes available):**
- OCascadia: 2,828 bytes ✅
- Revontuli: 1,014 bytes ✅  
- **Total: 3,842 bytes** - **EXCEEDS Bank 15 capacity!**

**Songs that DON'T fit in any single bank (all >4KB):**
- Most character songs: ~30KB each (7.5x larger than a bank!)
- Bolero: 7.6KB (nearly 2x bank size!)
- Chaotica: 7.9KB (already in Bank 16 somehow - must be compressed?)

## Critical Issue

**Individual songs are LARGER than entire banks!** 

Most songs are 30KB each, but each bank is only 4KB. This means:
- Songs MUST be compressed or split across multiple banks
- OR songs are stored externally and loaded dynamically (unlikely on 2600)
- OR the .bas files are source data, not final ROM data

**Next Steps:**
1. Verify if song .bas files are source or compiled format
2. Check if SkylineTool compresses songs during compilation
3. Calculate actual ROM size of compiled songs

