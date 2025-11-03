<!-- 1e3cebd0-749d-4481-ab71-73277d9d65fa a499a8cc-a3a3-44ca-ac79-a9884fe91a76 -->
# Sound and Music System Implementation Plan

## Overview

Complete implementation of music and sound effect subsystems for ChaosFight. Music uses 2-voice polyphony for publisher/author/title/winner screens. Sound effects use 1 voice during gameplay. Systems never overlap on the same screen. Songs and Sounds each occupy full ROM banks.

## Architecture

### Music System (Polyphony 2)

- **Format**: Interleaved 4-byte streams per voice (RAM optimization):
  - Voice 0: `AUDCV, AUDF, Duration, Delay, AUDCV, AUDF, Duration, Delay, ...` (repeating 4-byte pattern)
  - Voice 1: Same pattern
- **Song IDs**: 0-255 (byte width), starts at 0
- **Music Screens**:
  - Song 0: Publisher preamble (gameMode 0) - AtariToday.mscz
  - Song 1: Author preamble (gameMode 1) - Interworldly.mscz
  - Song 2: Title screen (gameMode 2) - ChaosFight.mscz (create if missing)
  - Song 3: GameOver screen (gameMode 7, defeat) - GameOver.mscz
  - Song 4: Victory screen (gameMode 7, win) - Victory.mscz
- **RAM Usage**: ~8-10 bytes (SongPointerL/H, MusicVoice0PointerL/H, MusicVoice1PointerL/H, frame counters)
  - **High byte = 0 indicates voice inactive** (no separate active flags needed)
- **Memory Bank**: Full ROM bank dedicated to Songs

### Sound Effect System (Polyphony 1)

- **Format**: Interleaved 4-byte stream:
  - `AUDCV, AUDF, Duration, Delay, AUDCV, AUDF, Duration, Delay, ...` (repeating pattern)
- **Sound IDs**: 0-255 (byte width), starts at 0 (separate namespace from songs)
- **Sound Types**:
  - 0: Attack hit
  - 1: Guard block
  - 2: Jump
  - 3: Player eliminated
  - 4: Menu navigation
  - 5: Menu selection confirm
  - 6: Special move
  - 7: Powerup
  - 8: Landing safely (no damage)
  - 9: Landing with damage
  - 10-255: Reserved for future
- **Priority**: Play if either voice is free, else forget (no queuing)
- **RAM Usage**: ~4-5 bytes (SoundPointerL/H, SoundEffectPointerL/H, frame counter)
  - **High byte = 0 indicates sound inactive**
- **Memory Bank**: Full ROM bank dedicated to Sounds

### Pointer Tables

- **Songs Bank**: `SongPointerL[]` and `SongPointerH[]` (256 entries each, high/low split)
- **Sounds Bank**: `SoundPointerL[]` and `SoundPointerH[]` (256 entries each, high/low split)
- Both use ID as index: `pointer = SongPointerL[songID] | (SongPointerH[songID] << 8)`

## Implementation Steps

### Phase 1: SkylineTool Music Compiler Enhancement ✅ COMPLETED

**File**: `SkylineTool/src/music.lisp`

✅ Implemented `write-batari-song` command with polyphony and frame-rate support  
✅ Completed `write-song-binary` for batariBASIC format with interleaved 4-byte streams  
✅ Added `score->batari-notes` function using proper TIA note conversion for NTSC/PAL  
✅ Registered command in interface and package exports  

### Phase 2: Music System Implementation ✅ COMPLETED

**File**: `Source/Routines/MusicSystem.bas`

✅ Implemented RAM variables in zero-page (var39-var44) and SCRAM (w020-w021)  
✅ Implemented StartMusic, UpdateMusic, UpdateMusicVoice0/1, StopMusic functions  
✅ Frame counter based timing for note durations  

### Phase 3: Sound Effect System Implementation ✅ COMPLETED

**File**: `Source/Routines/SoundSystem.bas`

✅ Implemented RAM variables in zero-page (var39, y, z, var41) and SCRAM (w022)  
✅ Implemented PlaySoundEffect, UpdateSoundEffect, StopSoundEffects functions  
✅ Music priority checking (sound won't play if music active)  
✅ Voice management (forgets if busy, no queuing)  

### Phase 4: Bank Helper Functions ✅ COMPLETED

**Files**: `Source/Banks/Bank16.bas` (Music), `Source/Banks/Bank15.bas` (Sounds)

✅ Implemented LoadSongPointer, LoadSongVoice1Pointer in Bank16  
✅ Implemented LoadMusicNote0, LoadMusicNote1 with assembly indirect addressing  
✅ Implemented LoadSoundPointer, LoadSoundNote in Bank15  
✅ Placeholder pointer tables (256 entries each, will be populated during asset generation)  
✅ Voice1 offset calculation for 2-voice polyphony  

### Phase 5: Constants and Integration ✅ COMPLETED

**Files**: `Source/Common/Constants.bas`, `Source/Routines/ChangeGameMode.bas`, `Source/Routines/MainLoop.bas`, `Source/Routines/GameLoopMain.bas`

✅ Defined Song constants (0-4) and Sound constants (0-9)  
✅ Added compatibility aliases for legacy sound constants  
✅ Integrated StartMusic calls in ChangeGameMode for all music screens  
✅ Integrated UpdateMusic calls in MainLoop for gameMode 0-2, 7  
✅ Integrated UpdateSoundEffect calls in GameLoopMain for gameMode 6  

### Phase 6: Menu Navigation Sound Effects 🔨 IN PROGRESS

**Issues**: #361, #362, #363, #364

#### Issue #361: Character/Level Select Navigation Sounds
**Status**: Pending  
**Files**: `Source/Banks/Bank5.bas` (Character Select), `Source/Banks/Bank12.bas` (Level Select)

**Implementation**:
- Character select: Navigate left/right → `temp1 = SoundMenuNavigate : gosub bank15 PlaySoundEffect`
- Level select: Navigate left/right → `temp1 = SoundMenuNavigate : gosub bank15 PlaySoundEffect`

#### Issue #362: Fix Character Select Down Input Bug
**Status**: Pending  
**Priority**: HIGH  
**Files**: `Source/Banks/Bank5.bas`, character select input handlers

**Bug**: Down input on character select triggers wrong animations/sounds  
**Expected**: No effect or navigate to previous character  
**Root Cause**: Input state machine incorrectly interpreting gameplay vs menu context  

#### Issue #363: Character Lock/Unlock Sounds
**Status**: Pending  
**Files**: `Source/Banks/Bank5.bas` (Character Select)

**Implementation**:
- Lock in character → `temp1 = SoundMenuSelect : gosub bank15 PlaySoundEffect`
- Unlock character → `temp1 = SoundMenuNavigate : gosub bank15 PlaySoundEffect`

#### Issue #364: Level Select Confirm Sound
**Status**: Pending  
**Files**: `Source/Banks/Bank12.bas` (Level Select)

**Implementation**:
- Confirm level selection → `temp1 = SoundMenuSelect : gosub bank15 PlaySoundEffect`

### Phase 7: Testing & Validation 🔨 PENDING

- Generate actual MIDI music files for AtariToday, Interworldly, ChaosFight, GameOver, Victory
- Generate actual sound effect data for all 10 defined sounds
- Verify each song plays on correct screen
- Test song transitions (StopMusic before StartMusic)
- Test all sound IDs trigger correctly
- Verify sound doesn't play if music is active
- Verify voice frees when sound/music ends
- RAM usage verification (< 15 bytes total as planned)
- TV standard testing (NTSC/PAL/SECAM)
- Issue #362: Test character select down input fix

## Files Modified

### ✅ Completed Implementation

- `SkylineTool/src/music.lisp` - Complete batariBASIC music compiler with polyphony support
- `SkylineTool/src/interface.lisp` - Registered write-batari-song command
- `SkylineTool/src/package.lisp` - Exported write-batari-song
- `Source/Routines/MusicSystem.bas` - Full music player implementation
- `Source/Routines/SoundSystem.bas` - Full sound effect player implementation
- `Source/Banks/Bank16.bas` - Music helper functions with assembly routines
- `Source/Banks/Bank15.bas` - Sound helper functions with assembly routines
- `Source/Common/Variables.bas` - All music/sound RAM variables allocated
- `Source/Common/Constants.bas` - Song and Sound ID constants with aliases
- `Source/Routines/ChangeGameMode.bas` - Music integration for all screens
- `Source/Routines/MainLoop.bas` - Music update integration
- `Source/Routines/GameLoopMain.bas` - Sound effect update integration

### 🔨 Pending Implementation

- `Source/Banks/Bank5.bas` - Add menu sounds to character select (#361, #363)
- `Source/Banks/Bank12.bas` - Add menu sounds to level select (#364)
- Character select input handlers - Fix down input bug (#362)
- Makefile - Add music generation rules for MIDI→batariBASIC compilation

## Technical Notes

### Interleaved Stream Format

- Each note = 4 consecutive bytes: `AUDCV, AUDF, Duration, Delay`
- Stream access: `stream[pointer], stream[pointer+1], stream[pointer+2], stream[pointer+3]`
- Advance pointer by 4 bytes per note

### Pointer Management

- High byte = 0 indicates inactive (no separate active flags)
- Pointer tables split into L/H arrays for bank compatibility
- Bank switching required before accessing pointer tables or data streams

### Bank Assignment

- **Bank 16**: Songs (music data and helper functions)
- **Bank 15**: Sounds (sound effect data and helper functions)
- Each bank gets full ROM space (no sharing)

## Additional Issues

### Issue #361: Add menu selection sounds to character select
When changing characters or levels on character/level select screens, play the 'menu selection changed' sound effect.

### Issue #362: Fix character select - down input triggers wrong animations and sounds
Bug: On character select, pulling back (down) on stick causes character to appear in 'recovering from fall' animation and play hurt sound. Expected: No effect or navigate to previous character.

### Issue #363: Add lock/unlock sounds to character select
When locking in or unlocking a character on character select, play appropriate sound effects.

### Issue #364: Add menu sounds to level select
When navigating and confirming on level (arena) select screen, play menu sound effects.

## Implementation Status

**Phase 1-5**: ✅ COMPLETE  
**Phase 6**: 🔨 IN PROGRESS (menu sound integration)  
**Phase 7**: 🔨 PENDING (asset generation and testing)

**Core Framework**: ✅ FULLY IMPLEMENTED AND FUNCTIONAL  
**Asset Generation**: 🔨 PENDING (requires MIDI/sound effect source files)  
**Menu Integration**: 🔨 PENDING (requires input handler fixes)

