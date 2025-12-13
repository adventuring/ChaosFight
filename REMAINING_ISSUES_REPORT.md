# Remaining Issues Report
**Generated:** 2025-01-27  
**Source:** Codebase analysis via grep and file review

## Critical Issues

### Issue #1303 - CRITICAL FIX: MainLoop fall-through bug
**Location:** `Source/Routines/MainLoop.s:63`  
**Status:** TODO  
**Severity:** CRITICAL  
**Description:** `ongosub0` is at the same address as `MainLoopModePublisherPrelude`, causing fall-through. An explicit jump is needed to prevent fall-through into handlers.

### Issue #1241 - HandleFlyingCharacterMovement stack depth
**Location:** `Source/Routines/HandleFlyingCharacterMovement.s:9`  
**Status:** FIXME  
**Description:** Changed from Far to Near return to save stack depth. May need review to ensure this is correct for all call sites.

---

## High Priority Issues

### Issue #1306 - BudgetedPlayerCollisions phase implementations
**Location:** `Source/Routines/BudgetedPlayerCollisions.s:47,55,63`  
**Status:** TODO  
**Files affected:**
- `Source/Routines/BudgetedPlayerCollisions.s`

**Description:** Three phases need to be implemented:
- `BPC_Phase0`: Check pairs 0, 1 (P1 vs P2, P1 vs P3)
- `BPC_Phase1`: Check pairs 2, 3 (P1 vs P4, P2 vs P3)
- `BPC_Phase2`: Check pairs 4, 5 (P2 vs P4, P3 vs P4)

**Current state:** Phases are defined but not properly wired into the frame phase checking logic. The code has stub procedures that need to be connected.

### Issue #1291 - GPL_lockedState variable assignment
**Location:** `Source/Routines/PlayerLockedHelpers.s:63,72,89,108`  
**Status:** TODO (4 instances)  
**Description:** `GPL_lockedState` variable needs to be assigned from `temp2` in all `GetPlayerLockedP*` routines:
- `GetPlayerLockedP0` (line 63)
- `GetPlayerLockedP1` (line 72) 
- `GetPlayerLockedP2` (line 89)
- `GetPlayerLockedP3` (line 108)

### Issue #1302 - VblankTransitionToWinner implementation
**Location:** `Source/Routines/VblankHandlers.s:1168`  
**Status:** TODO  
**Description:** `VblankTransitionToWinner` routine needs to be implemented.

### Issue #1250 - Inlined routine consolidation
**Location:** Multiple files  
**Status:** FIXME (3 instances)  
**Files affected:**
- `Source/Routines/RoboTitoJump.s:74,225`
- `Source/Routines/CharacterControlsJump.s:50,58,380`

**Description:** `CCJ_ConvertPlayerXToPlayfieldColumn` has been inlined at all call sites. May need to be consolidated or removed.

### Issue #1252 - IsPlayerAlive inlining
**Location:** `Source/Banks/Bank12.bas:84`, `Source/Banks/Bank12.s:63`  
**Status:** FIXME  
**Description:** `IsPlayerAlive` has been inlined at all call sites. May need to be consolidated or removed.

### Issue #1236 - CheckEnhancedJumpButton inlining
**Location:** `Source/Routines/ProcessJumpInput.s:30`  
**Status:** FIXME  
**Description:** `CheckEnhancedJumpButton` has been inlined to save 4 bytes stack depth. May need review.

---

## Medium Priority Issues

### Issue #1254 - Loop unrolling/conversion (11 instances)
**Status:** TODO  
**Description:** Multiple `for currentPlayer = 0 to 3` loops need to be converted to assembly or optimized.

**Locations:**
1. `Source/Routines/CharacterSelectMain.s:815` - for currentPlayer = 0 to temp1
2. `Source/Routines/CharacterSelectMain.s:956` - for currentPlayer = 0 to 3
3. `Source/Routines/CharacterSelectMain.s:1072` - for currentPlayer = 0 to 3
4. `Source/Routines/MissileSystem.s:285` - for temp1 = 0 to 3
5. `Source/Routines/MissileSystem.s:1103` - for temp6 = 0 to 3
6. `Source/Routines/AnimationSystem.s:26` - for currentPlayer = 0 to 3
7. `Source/Routines/AnimationSystem.s:985` - for currentPlayer = 0 to 3
8. `Source/Routines/VblankHandlers.s:219` - for currentPlayer = 0 to 3
9. `Source/Routines/VblankHandlers.s:1023` - for currentPlayer = 0 to 3
10. `Source/Routines/GameLoopMain.s:212` - for currentPlayer = 0 to 3
11. `Source/Routines/GameLoopInit.s:249,287` - for currentPlayer = 0 to 3 (2 instances)
12. `Source/Routines/UpdateAttackCooldowns.s:15` - for temp1 = 0 to 3
13. `Source/Routines/MissileCollision.s:611` - for temp2 = 0 to 3
14. `Source/Routines/FindLastEliminated.s:20` - for currentPlayer = 0 to 3

### Issue #1296 - Music bank stream loading
**Location:** `Source/Routines/MusicBankHelpers.s:374,376`, `Source/Routines/MusicBankHelpers15.s:126,127`  
**Status:** TODO  
**Description:** Load 4 bytes from stream[pointer] implementation needed. Two files affected.

### Issue #1298 - Variable conversion assignments
**Location:** `Source/Routines/PlayerPlayfieldCollisions.s` (multiple lines)  
**Status:** TODO  
**Description:** Multiple variable assignments need to be converted from batariBASIC syntax to assembly:
- Line 18: `currentPlayer = player index (0-3)`
- Line 354: `temp3 = row span`
- Line 357: `temp4 = 1 if any solid pixel encountered`
- Line 360: `dim PCC_rowSpan = temp3`
- Line 439: `rowCounter = rowCounter + PCC_rowSpan`
- Line 459: `temp2 = row index, temp6 = center column`
- Line 462: `temp4 = 1 if any column collides`
- Line 799: `rowCounter = playfieldRow + temp5`

### Issue #1310 - Multiple implementations (5 instances)
**Status:** TODO  
**Locations:**
1. `Source/Routines/ConsoleHandling.s:426` - `DoneSwitchChange`
2. `Source/Routines/Combat.s:798` - for defenderID = 0 to 3
3. `Source/Routines/Combat.s:803` - `NextDefender`
4. `Source/Routines/Combat.s:864` - for attackerID = 0 to 3
5. `Source/Routines/CheckRoboTitoStretchMissileCollisions.s:124` - `CRTSMC_DoneSelf`

### Issue #1307 - HandleFlyingCharacterMovement Joy0 handlers
**Location:** `Source/Routines/HandleFlyingCharacterMovement.s:108,173`  
**Status:** TODO  
**Description:** Two handlers need implementation:
- `HandleFlyingCharacterMovementCheckRightJoy0`
- `HandleFlyingCharacterMovementVerticalJoy0`

### Issue #1308 - CharacterAttacksDispatch player checks
**Location:** `Source/Routines/CharacterAttacksDispatch.s:233,242`  
**Status:** TODO  
**Description:** Two player checks need implementation:
- `CEJB_CheckPlayer0`
- `CEJB_CheckPlayer2`

### Issue #1265 - HealthBarSystem BCD conversion
**Location:** `Source/Routines/HealthBarSystem.s:592,803-815,856-866`  
**Status:** TODO (15 instances)  
**Description:** BCD conversion loop and score storage implementation needed. Multiple sections commented out with TODO markers.

### Issue #1266 - GameLoopInit variable initialization
**Location:** `Source/Routines/GameLoopInit.s:86,88`  
**Status:** TODO  
**Description:** Two variable initializations needed:
- `pfrowheight = ScreenPfRowHeight`
- `pfrows = ScreenPfRows`

---

## Low Priority / Documentation Issues

### Issue #1304 - SpriteLoader documentation
**Location:** `Source/Routines/SpriteLoader.s:4-125`  
**Status:** TODO (extensive comments)  
**Description:** Large block of documentation comments that describe sprite loading behavior. May need to be converted to actual code documentation or removed if redundant.

### Issue #1311 - Various minor TODOs (12+ instances)
**Status:** TODO  
**Locations and descriptions:**
1. `Source/Routines/CharacterSelectRender.s:17` - Color indices: `ColIndigo(6), ColRed(6), ColYellow(6), ColTurquoise(6)`
2. `Source/Routines/ArenaSelect.s:323` - `cpx #3` check
3. `Source/Routines/FallDamage.s:681-686` - `DivideBy20` assembly routine documentation
4. `Source/Routines/CharacterControlsDown.s:199` - `HarpyDown = .HarpyDown`
5. `Source/Routines/CharacterControlsDown.s:517` - `FrootyDown = .FrootyDown`
6. `Source/Routines/MissileCharacterHandlers.s:209` - `MegaxMissileActive`
7. `Source/Routines/MissileCharacterHandlers.s:295` - `KnightGuyAttackActive`
8. `Source/Routines/MissileCharacterHandlers.s:376` - `KnightGuySwingLeft`
9. `Source/Routines/TitleScreenMain.s:63` - SCRAM variable read/write comment
10. `Source/Common/Variables.s:901` - Future expansion marker

### Issue #151 - Fountain.lisp player movement
**Location:** `SkylineTool/src/fountain.lisp:2674`  
**Status:** TODO  
**Description:** Move the player functionality needs implementation in the Fountain scripting system.

---

## Completed Issues (Referenced in Code)

These issues are mentioned in code comments but appear to be completed:

- **Issue #600** - HealthBarSystem (marked as completed in `HealthBarSystem.s:828,873`)
- **Issue #601** - PAL color palette verification (marked as verified)
- **Issue #875** - ApplyMomentumAndRecovery routine (completed)
- **Issue #930** - SuperChip SCRAM port exports (completed)
- **Issue #1147** - Combat system live attack evaluation (completed)
- **Issue #1148** - Missile hitbox calculations (completed)
- **Issue #1149** - Weight-tier calculation deduplication (completed)
- **Issue #1177** - Frooty lollipop charge-and-bounce attack (completed)
- **Issue #1178** - Bernie post-fall stun (completed)
- **Issue #1180** - Ursulo uppercut knock-up scaling (completed)
- **Issue #1188** - Missile system character handlers (completed)
- **Issue #1194** - Extended character tables to 32 entries (completed)
- **Issue #483** - Winner screen transition (completed)

---

## Documentation / External Issues

### ✅ WWW Link Completion (COMPLETED)
**File:** `WWW_LINK_SEARCH_RESULTS.md`  
**Status:** ✅ Complete  
**Completed:** December 2025  
**Description:** All AtariAge forum topic links and Steam app links have been successfully researched and updated throughout the codebase.

**Completed updates (13 forum threads + 1 Steam app):**
1. ✅ RealSports Curling - `topic/280059`
2. ✅ Grizzards - `topic/322957`
3. ✅ Harpy's Curse - `topic/342060`
4. ✅ Knight Guy - `topic/356587`
5. ✅ Magical Fairy Force - `topic/307426`
6. ✅ Magical Fairy Drop - `topic/368460`
7. ✅ Ninjish Guy - `topic/318874` (tournament thread)
8. ✅ Rob 'N' Banks - `topic/336986`
9. ✅ Ratcatcher - `topic/253218`
10. ✅ Robo Tito - `topic/365608`
11. ✅ Phantasia - `topic/343031`
12. ✅ Ducks Away - `topic/358950`
13. ⏳ Chaos Fight - To be created upon release
14. ✅ Magical Fairy Force Champion Edition on Steam - `app/2144100`

**Files updated:**
- All character HTML files (`WWW/26/characters/*.html`)
- Manual HTML (`WWW/26/manual/Characters.html`)
- TeXinfo source files (`Manual/*.texi`)
- About page (`WWW/26/about/index.html`)

See `WWW_LINK_SEARCH_RESULTS.md` for complete details and URLs.

---

## Summary Statistics

- **Critical Issues:** 2
- **High Priority Issues:** 7
- **Medium Priority Issues:** 9 (covering ~40+ TODO instances)
- **Low Priority Issues:** 3 (covering ~15+ TODO instances)
- **Documentation Issues:** 1 (13+ missing links)
- **Total TODO/FIXME markers:** ~90+ instances

---

## Recommended Action Plan

1. **Immediate (Critical):**
   - Fix Issue #1303 (MainLoop fall-through) - game-breaking bug

2. **High Priority:**
   - Complete Issue #1306 (BudgetedPlayerCollisions) - affects 4-player collision detection
   - Complete Issue #1291 (GPL_lockedState) - character select functionality
   - Complete Issue #1302 (VblankTransitionToWinner) - winner screen functionality

3. **Medium Priority:**
   - Batch conversion of Issue #1254 loops (11 instances) - performance optimization
   - Complete Issue #1298 variable conversions - code cleanup

4. **Low Priority:**
   - Complete Issue #1311 minor TODOs as time permits
   - Update WWW links (can be done separately)

---

**Note:** This report is generated from codebase analysis. Actual GitHub issues may have additional context, priorities, or status updates. Review actual GitHub issues for complete information.

