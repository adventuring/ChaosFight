# Bug Report - ChaosFight
Generated: 2025-12-13
Last Updated: 2025-12-13

## Summary
This report documents all remaining bugs in the codebase, excluding CPU player implementation issues. Each bug is linked to its GitHub issue for tracking.

---

## GitHub Issues (Open Bugs)

### #1323: Crash at $3:ffe4 - execution jumped into EFSC header area
**Status:** OPEN  
**Priority:** CRITICAL  
**Location:** Bank 3, address $ffe4 (EFSC header area)

**Description:**
Execution jumped into the EFSC identification header area. PC = $3:ffe4, which is the null byte after "EFSC" string (data, not code).

**Analysis:**
- $ffe0-$ffe3: "EFSC" header ($45, $46, $53, $43)
- $ffe4: 0 (null terminator) - **This is where execution jumped**
- Execution should never reach $ffe4 as it's data, not code

**Possible Causes:**
1. Corrupted return address on stack causing BS_return to decode bad address
2. Stack corruption leading to RTS jumping to $ffe4
3. Issue with BS_return decoding logic when stack contains invalid data

**Required for Debugging:**
- Stack pointer value when crash occurred
- Stack contents (top 4-8 bytes)
- Routine executing before crash
- Whether crash occurred after BS_return call

**Related:** Issue #1246

---

### #1314: Stack pointer corrupted: SP = $32 before Startup.s txs
**Status:** OPEN  
**Priority:** CRITICAL  
**Location:** Startup.s initialization

**Description:**
Stack pointer is corrupted (SP = $32 instead of expected value) when Startup.s tries to initialize it.

**Code Path:**
Reset → Bank 13 → ColdStart → ConsoleDetection.s → Startup.s

**Possible Causes:**
1. Something between Reset and Startup.s corrupting SP
2. Bank switch might affect SP (unlikely)
3. ConsoleDetection.s using stack (code review shows no stack usage)
4. Detection loop affecting SP somehow

**Required for Debugging:**
- Verify Reset handler actually executes
- Check if bank switch affects SP
- Verify no stack operations between Reset and Startup.s

---

### #1246: Write to read port: $378d at $3:ffe4
**Status:** OPEN  
**Priority:** HIGH  
**Location:** Bank 3

**Description:**
Reported write to read port at file offset $378d (Bank 3 CPU $F78D) from location $3:ffe4.

**Investigation:**
- File offset $378D is all zeros (padding/uninitialized)
- Bank 3 CPU $FFE4 is in EFSC header area (data, not code)
- No STA instructions found in listing writing to SCRAM read ports ($F080-$F0FF)

**Possible Interpretations:**
- Code at Bank 3 CPU $FFE4 writing to file offset $378D (CPU $F78D) - but $F78D is not a valid SCRAM address
- Code at file offset $378D writing to a read port - but $378D is padding
- Typo: maybe meant $F08D (r013) instead of $F78D?

**Required for Debugging:**
- Full debugger/emulator trace
- Operation being performed when this occurred
- Clarification on address format (file offset vs CPU address)

**Related:** Issue #1323

---

### #1245: Crash: Accessing non-connected memory space around $2axx
**Status:** OPEN  
**Priority:** CRITICAL  
**Location:** Memory space around $2axx

**Description:**
Crash observed accessing non-connected memory space around address $2axx.

**Possible Causes:**
- Stack pointer corruption (SP pointing to invalid RAM)
- Array/buffer overflow
- Uninitialized pointer dereference
- Stack underflow leading to execution of garbage return addresses

**Required for Debugging:**
- Exact crash address(es) and context
- Stack trace (SP, A, X, Y registers at crash)
- What action/state was active when crash occurred
- Full crash trace if available
- Whether this is related to stack underflow issue (#1232)

---

### #1232: Stack underflow at $5:fb63
**Status:** OPEN  
**Priority:** CRITICAL  
**Location:** Bank 5, CPU address $fb63

**Description:**
Stack underflow crash - stack pointer went below bottom of stack.

**Stack Contents:**
Most recent top of stack: fc 6a 5b ec fa d9 da ba da 6b a9 0f fc f9 5f fb

**Problem:**
Stack underflow occurs when:
- Too many `RTS` or `BS_return` calls (popping more than was pushed)
- Stack pointer wraps around from $00 to $FF
- Mismatched call/return pairs (near call with far return, or vice versa)

**Required Investigation:**
1. Find code at $fb63 in bank 5
2. Analyze call chain leading to this location
3. Check for mismatched call/return pairs
4. Verify stack depth calculations
5. Check for missing return statements or extra returns

---

### #1228: Publisher Prelude: Playfield showing garbage instead of blank screen
**Status:** OPEN  
**Priority:** MEDIUM  
**Location:** Publisher Prelude screen (gameMode 0)

**Description:**
Publisher Prelude screen improperly shows garbage in the playfield when it should be blank.

**Expected:** Playfield should be blank (no graphics displayed).  
**Actual:** Garbage/artifacts are displayed in the playfield area.

**Possible Causes:**
- Playfield initialization in PublisherPreambleMain routine (Bank 9)
- Playfield register settings not being properly cleared
- Residual data from previous game modes

**Note:** May be related to #1222 (TitleScreen rendering bugs) which was just fixed.

---

### #1227: Publisher Prelude: Player graphics positioning incorrect for 48px display
**Status:** OPEN  
**Priority:** MEDIUM  
**Location:** Publisher Prelude screen (gameMode 0)

**Description:**
Player graphics are positioned incorrectly in 48px display mode.

**Possible Causes:**
- NUSIZ register settings (player size/number configuration) in Publisher Prelude
- Player positioning logic for wide players (48px = 3x normal width, divider = 2)
- Sprite rendering in the PublisherPreambleMain routine (Bank 9)

---

### #1226: Publisher Prelude: Unstable frame display with wild scanline variations (up to 924 lines)
**Status:** OPEN  
**Priority:** CRITICAL  
**Location:** Publisher Prelude screen (gameMode 0)

**Description:**
Frame scanline counts vary wildly, reaching up to 924 lines instead of the expected 262 lines (NTSC standard).

**Possible Causes:**
- VSYNC/VBLANK handling in the Publisher Prelude routine
- Frame boundary detection in the main loop
- Timing issues in the PublisherPreambleMain routine (Bank 9)

---

### #1225: Publisher Prelude screen ignoring all button presses
**Status:** OPEN  
**Priority:** HIGH  
**Location:** Publisher Prelude screen (gameMode 0)

**Description:**
Publisher Prelude screen does not respond to any button presses on any controller.

**Expected:** Any button press on any controller should immediately transition to Author Prelude screen.

**Potential Issues:**
1. Button state variables (joy0fire, joy1fire) may not be updated correctly
2. INPT0-3 bit 7 checks may have incorrect logic (!INPT0{7} vs (INPT0 & $80) = 0)
3. controllerStatus flags may not be set correctly
4. Button checks happen before other code - if there's an early return or crash, buttons won't be checked

**Code locations:**
- Button checks: Source/Routines/PublisherPrelude.bas:123-153
- PublisherPreludeComplete: Source/Routines/PublisherPrelude.bas:189-220

---

### #1224: Publisher Prelude screen not auto-advancing to Author Prelude after song completes
**Status:** OPEN  
**Priority:** MEDIUM  
**Location:** Publisher Prelude screen (gameMode 0)

**Description:**
Publisher Prelude screen does not automatically transition to Author Prelude after the "Atari Today" jingle finishes playing.

**Expected:** Should transition to Author Prelude (gameMode 1) 0.5 seconds after musicPlaying becomes 0.

**Auto-advance condition:** `if preambleTimer > 30 && musicPlaying = 0 then goto PublisherPreludeComplete`

**Potential Issues:**
1. musicPlaying may never become 0 (music system bug)
2. musicPlaying variable may not be updated correctly by PlayMusic
3. Condition logic may be incorrect
4. preambleTimer may not be incrementing

**Code locations:**
- Auto-advance check: Source/Routines/PublisherPrelude.bas:165
- Timer increment: Source/Routines/PublisherPrelude.bas:169
- Timer init: Source/Routines/BeginPublisherPrelude.bas:41

---

### #1223: Publisher Prelude screen not playing Atari Today jingle
**Status:** OPEN  
**Priority:** MEDIUM  
**Location:** Publisher Prelude screen (gameMode 0)

**Description:**
Publisher Prelude screen (gameMode 0) does not play the "Atari Today" jingle music.

**Expected:** Should start playing MusicAtariToday (song ID 27) when screen initializes.

**Investigation:**
- BeginPublisherPrelude calls StartMusic bank15 with MusicAtariToday (27)
- MusicAtariToday = 27, Bank1MinSongID = 7, Bank15MaxSongID = 6
- Since 27 >= 7, song should load from Bank 1 (not Bank 15)

**Potential Issues:**
1. Is LoadSongPointer bank1 working correctly?
2. Is the song data actually in Bank 1?
3. Is PlayMusic being called every frame from MainLoop?

**Code locations:**
- BeginPublisherPrelude: Source/Routines/BeginPublisherPrelude.bas:49-50
- StartMusic routing: Source/Routines/MusicSystem.bas:123-131
- PlayMusic call: Source/Routines/MainLoop.bas:106

---

### #1222: Publisher Prelude screen not drawing bitmaps (FIXED)
**Status:** FIXED  
**Priority:** HIGH  
**Location:** Publisher Prelude screen (gameMode 0)

**Description:**
Publisher Prelude screen (gameMode 0) displays blank/black screen with no graphics.

**Expected:** Should display AtariAge logo (bmp_48x2_1) and AtariAge text (bmp_48x2_2) bitmaps.

**Bugs Fixed:**
1. Infinite loop in DrawTitleScreenOnly - duplicate label jumped to itself
2. Missing titlescreenWindow1 assignments in BeginPublisherPrelude, BeginTitleScreen, BeginAuthorPrelude
3. Missing titlescreenWindow1 assignments in DrawPublisherScreen, DrawAuthorScreen, DrawTitleScreenOnly

**Fix:** Added missing titlescreenWindow1 assignments and removed infinite loop.

---

### #1220: TitleScreen crash: isb $f3d3,x at $1:f56c writes to read port f3d4
**Status:** OPEN  
**Priority:** CRITICAL  
**Location:** Bank 1, CPU address $f56c

**Description:**
Crash with illegal opcode `isb $f3d3, x` attempting to write to read port f3d4 (TIA read register).

**Context:**
- Occurs after fix for issue #1219 (titledrawscreen symbol resolution)
- Stack: s f3 ( fd c1 c4 f1 2c 54 11 8a ed fa a3 fa ) a 6a x 01 y fb ps -----i-c
- Memory at $00f2: 6b f5 fd c1 …

**Investigation Needed:**
- Why is illegal opcode ISB being generated?
- What code is at $1:f56c?
- Why is it trying to write to TIA read register f3d4?
- Is this related to the titlescreen_colors.s rorg change?

---

### #1218: Suspicious lda # 1 / ora # 2 pattern at $d:f50e
**Status:** OPEN  
**Priority:** LOW  
**Location:** Bank $d, offset $f50e

**Description:**
Found suspicious code pattern during stack trace analysis:
```assembly
lda # 1
ora # 2
```

This pattern loads 1, then ORs with 2, resulting in 3. This seems inefficient and may indicate:
- Missing optimization opportunity (should be `lda #3`)
- Incorrect logic (should be separate operations)
- Placeholder code that needs review

**Context:** Found during investigation of issue #1217 (stack underflow crash)

**Action:** Review code at this location and determine if this is intentional or should be optimized/fixed.

---

## Code Bugs Found

### 1. UpdatePlayerMovementSingle - Missing Elimination Check
**Status:** TODO comment (not implemented)  
**Priority:** MEDIUM  
**Location:** `Source/Routines/UpdatePlayerMovementSingle.s:16`

**Description:**
The function has a TODO comment: "Skip if player is eliminated - TODO: implement elimination check"

**Impact:**
- Eliminated players may still have movement updated
- Wasted CPU cycles processing dead players

**Note:** This is documented as a TODO, not a critical bug.

---

### 2. MissileSystem.s - Duplicate Code and Incomplete Implementation (FIXED)
**Status:** FIXED in this session  
**Priority:** HIGH  
**Location:** `Source/Routines/MissileSystem.s`

**Bugs Found:**
1. **Duplicate velocity inversion** (lines 857-865): Same calculation done twice
2. **Duplicate lifetime decrement** (lines 907, 915): Lifetime decremented twice with unreachable code
3. **Incomplete bounce velocity calculation**: Calculated `temp6 - velocityCalculation` but never stored back to `missileVelocityX[temp1]`

**Impact:**
- Bounce velocity not properly applied (missile doesn't reduce speed on bounce)
- Lifetime decremented twice (missiles expire too quickly)
- Wasted CPU cycles with duplicate calculations

**Fix:** Removed duplicates, fixed array indexing, completed bounce velocity storage.

---

## Bugs Fixed in This Session

The following bugs were fixed during this code review session:

1. **WarmStart optimization (#1329)** - Changed inefficient BS_jsr to same-bank far call
2. **Pause toggle logic** - Fixed inverted logic in HandleConsoleSwitches
3. **CheckEnhancedPause unreachable code** - Fixed early return preventing button checking
4. **Combat.s health check** - Fixed inverted logic (dead attackers continuing processing)
5. **SpriteLoader.s duplicates** - Removed duplicate code and fixed infinite loop
6. **Missile collision temp6 reuse** - Fixed critical variable corruption bug
7. **CacheAOERightHitbox/CacheAOELeftHitbox** - Fixed incomplete implementations
8. **VCS-Consts.s header** - Fixed file header (Grizzards → ChaosFight)
9. **MissileSystem.s duplicate code** - Fixed duplicate velocity inversion and lifetime decrement
10. **#1222: TitleScreen rendering bugs** - Fixed infinite loop and missing titlescreenWindow1 assignments

---

## Bugs Requiring Runtime Debugging

All three open GitHub issues (#1323, #1314, #1246) require:
- Runtime debugger traces
- Stack dumps
- Execution context information

These cannot be diagnosed from static code analysis alone and require running the game in a debugger (e.g., Stella debugger) to capture the crash state.

---

## Recommendations

1. **Priority 1:** Debug issues #1323 and #1314 (stack corruption/crash issues)
   - Use Stella debugger to capture full state at crash
   - Trace execution from Reset handler through to crash point
   - Capture stack contents and register state

2. **Priority 2:** Resolve issue #1246 (write to read port)
   - Clarify address format and get full trace
   - Verify if this is related to #1323

3. **Priority 3:** Implement elimination check in UpdatePlayerMovementSingle
   - Currently a TODO, can be implemented when convenient

---

## Notes

- All critical code bugs found in static analysis have been fixed
- Remaining bugs require runtime debugging information
- Codebase appears to be in good shape from a static analysis perspective
- No other obvious bugs found beyond those documented above

