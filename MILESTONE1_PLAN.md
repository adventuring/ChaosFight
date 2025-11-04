# Milestone 1: Core Game Functionality

**Goal**: Create a playable, buildable 4-player fighting game with complete game flow from title screen through winner announcement.

**Status**: Planning Phase

---

## Phase 1: Critical Blockers (BLOCKING)

These issues must be resolved before any gameplay testing can occur.

### 1.1 Build System & ROM Generation
- **[#336]** CRITICAL: ROM build produces only 1276 bytes instead of 65536 bytes
  - **Sub-issues**:
    - [ ] Verify bankswitch hotspot configuration ($1FE0 for EFSC)
    - [ ] Verify all 16 banks are properly configured
    - [ ] Verify ROM vectors are correctly placed
    - [ ] Test ROM loads in emulator
- **[#220]** Build: produce a valid 64KiB ChaosFight ROM
  - **Dependencies**: #336
- **[#447]** Fix bankswitch hotspot: $FFF8 to $1FE0 for EFSC
  - **Dependencies**: #336

### 1.2 Memory & Data Integrity
- **[#473]** Fix memory aliasing: Reallocate SelectedChar3/4 and SelectedLevel variables
  - **Impact**: Variables overlap with animation system, causing crashes
  - **Sub-issues**:
    - [ ] Audit Variables.bas for all memory conflicts
    - [ ] Reallocate SelectedChar3 to unused SuperChip variable
    - [ ] Reallocate SelectedChar4 to unused SuperChip variable  
    - [ ] Reallocate SelectedLevel to unused SuperChip variable
    - [ ] Update all references to use new variable locations
- **[#253]** Bug: Memory aliasing - animation/subpixel variables overlap with character select
  - **Parent**: #473
- **[#256]** Code Audit: Verify Superchip read/write var pairs not used in read-modify-write
  - **Sub-issues**:
    - [ ] Audit all read-modify-write operations
    - [ ] Document safe usage patterns
    - [ ] Fix any violations

### 1.3 Combat System Core
- **[#474]** Fix hitbox collision detection inverted logic in Combat.bas
  - **Impact**: Attacks don't register hits correctly
  - **Sub-issues**:
    - [ ] Fix hit flag reset logic (lines 46-51)
    - [ ] Verify hitbox detection calculations
    - [ ] Test with all character types
- **[#252]** Hitbox collision detection (parent issue)
  - **Parent**: #474

---

## Phase 2: Animation System Foundation

Core animation infrastructure needed for character movement and combat.

### 2.1 Animation Constants & Naming
- **[#477]** Rename animation constants from Anim* to Action* prefix
  - **Sub-issues**:
    - [ ] Find all Anim* constant references
    - [ ] Rename to Action* prefix (13 constants total)
    - [ ] Update all usage sites
    - [ ] Verify no regressions
- **[#166]** Fix abbreviation 'Anim' to 'Action' in variable names
  - **Parent**: #477

### 2.2 Player State Management
- **[#475]** Add playerFacing bit to playerState and update on joystick input
  - **Sub-issues**:
    - [ ] Define playerState bit 0 as facing (0=left, 1=right)
    - [ ] Update PlayerInput.bas to set facing bit on joystick input
    - [ ] Initialize facing bit on character select
    - [ ] Test facing direction persistence
- **[#476]** Apply sprite reflection based on playerState facing bit
  - **Dependencies**: #475
  - **Sub-issues**:
    - [ ] Read playerState bit 0 in sprite rendering
    - [ ] Apply REFP0/REFP1 reflection when facing left
    - [ ] Test sprite reflection for all characters
- **[#204]** Maintain facing-direction during knockback/hurt movement
  - **Dependencies**: #475, #476

### 2.3 Animation Transitions
- **[#478]** Implement HandleAnimationTransition for generic action transitions
  - **Sub-issues**:
    - [ ] Define generic transition table (windup→execute→recovery)
    - [ ] Implement frame-based transition logic
    - [ ] Integrate with animation system
    - [ ] Test transition timing
- **[#472]** Implement character-specific attack transition handlers
  - **Dependencies**: #478
  - **Sub-issues**:
    - [ ] Define per-character attack transition overrides
    - [ ] Implement special move transitions
    - [ ] Test all character attack sequences
- **[#201]** Animation state machine rewrite (parent issue)
  - **Parent**: #478, #472
- **[#203]** Frame progression with transitions (parent issue)
  - **Parent**: #478

### 2.4 Missile System Enhancements
- **[#479]** Add missile NUSIZ tracking arrays for 4-player support
  - **Sub-issues**:
    - [ ] Add missileNUSIZ[4] array to Variables.bas
    - [ ] Update missile creation to set NUSIZ
    - [ ] Update missile rendering to use tracked NUSIZ
    - [ ] Test 4-player missile multiplexing

---

## Phase 3: Game Flow & Mode Transitions

Complete the game loop from title screen through winner announcement.

### 3.1 Setup Routines
- **[#480]** Audit and implement missing Begin* setup routines
  - **Sub-issues**:
    - [ ] Create BeginGameLoop.bas (referenced but missing)
    - [ ] Create BeginAttractMode.bas (referenced but missing)
    - [ ] Verify all Begin* routines are properly called
    - [ ] Test mode transitions
- **[#230]** Add BeginFallingAnimation setup routine
  - **Status**: Already exists, verify implementation
- **[#231]** Add BeginLevelSelect setup routine
  - **Status**: Already exists, verify implementation
- **[#232]** Add BeginGameLoop setup routine
  - **Parent**: #480
- **[#233]** Add BeginWinnerAnnouncement setup routine
  - **Status**: Already exists, verify implementation
- **[#224]** Implement ChangeGameMode dispatcher
  - **Status**: Exists, verify all modes are handled

### 3.2 Title Screen
- **[#482]** Fix title screen parade start timing to 5 seconds
  - **Sub-issues**:
    - [ ] Change timing from 10 seconds to 5 seconds
    - [ ] Test parade animation start
    - [ ] Verify button press still works during parade
- **[#401]** Title screen parade timing (parent issue)
  - **Parent**: #482
- **[#386]** Copyright timing & logo (parent issue)

### 3.3 Level Select
- **[#484]** Implement Level Select: 01-16/?? cycling display
  - **Sub-issues**:
    - [ ] Implement arena number display (01-16)
    - [ ] Add "??" option for random arena
    - [ ] Implement LEFT/RIGHT navigation
    - [ ] Test display formatting
- **[#485]** Add 1-second Fire button hold detection to return to Character Select
  - **Sub-issues**:
    - [ ] Implement fire button hold timer
    - [ ] Return to character select after 1 second hold
    - [ ] Visual feedback for hold progress
    - [ ] Test timing accuracy
- **[#486]** Add Game Select switch detection in Level Select
  - **Sub-issues**:
    - [ ] Detect Game Select switch state
    - [ ] Handle switch state changes
    - [ ] Test switch detection
- **[#384]** Fix Level Select: Implement 01-16/?? display, 1-second hold return, Game Select detection
  - **Parent**: #484, #485, #486
- **[#390]** Rename SelectedLevel to SelectedArena
  - **Dependencies**: #473 (memory aliasing fix)
  - **Sub-issues**:
    - [ ] Rename variable in Variables.bas
    - [ ] Update all references
    - [ ] Verify no regressions
- **[#388]** Standardize terminology: Use 'Arena' consistently, not 'Level'
  - **Parent**: #390

### 3.4 Falling Animation
- **[#385]** Fix Falling In: Implement quadrant-to-row2 movement with playfield nudging
  - **Sub-issues**:
    - [ ] Implement quadrant-based starting positions
    - [ ] Implement movement to row 2
    - [ ] Add playfield collision nudging
    - [ ] Test animation timing

### 3.5 Winner Screen
- **[#483]** Verify winner screen button press and return to title
  - **Sub-issues**:
    - [ ] Test button press detection
    - [ ] Verify return to title screen
    - [ ] Test with all player counts
- **[#387]** Winner screen flow (parent issue)
  - **Parent**: #483

---

## Phase 4: Code Quality & Syntax Refactoring

Improve code quality and fix syntax issues that don't block gameplay.

### 4.1 Syntax Refactoring
- **[#487]** Refactor if/then/else statements in PlayerRendering.bas (2 occurrences)
  - **Sub-issues**:
    - [ ] Find all if/then/else statements
    - [ ] Convert to if/then with goto labels
    - [ ] Test rendering functionality
- **[#488]** Refactor if/then/else statements in PlayerPhysics.bas (1 occurrence)
  - **Sub-issues**:
    - [ ] Find if/then/else statement
    - [ ] Convert to if/then with goto labels
    - [ ] Test physics functionality
- **[#489]** Refactor if/then/else statements in Data/Playfields.bas (multiple occurrences)
  - **Sub-issues**:
    - [ ] Find all if/then/else statements
    - [ ] Convert to if/then with goto labels
    - [ ] Verify playfield data integrity
- **[#432]** Syntax: if/then/else statements should be refactored (parent issue)
  - **Parent**: #487, #488, #489

### 4.2 Code Quality Improvements
- **[#433]** Syntax: Review indentation (must be 10 spaces unless label or end)
  - **Sub-issues**:
    - [ ] Audit all files for correct indentation
    - [ ] Fix indentation violations
    - [ ] Document indentation standard
- **[#434]** Syntax: Missing tail call optimizations
  - **Sub-issues**:
    - [ ] Find all gosub+return patterns
    - [ ] Convert to goto where appropriate
    - [ ] Test function calls
- **[#435]** Syntax: Jump-springboards (goto to label with only another goto)
  - **Sub-issues**:
    - [ ] Find all jump springboard patterns
    - [ ] Remove intermediate labels
    - [ ] Update all references
- **[#455]** Tail call optimization: Identify bank-crossing calls
  - **Parent**: #434
- **[#456]** Tail call optimization: Find same-bank tail calls
  - **Parent**: #434
- **[#457]** Tail call optimization: Convert to goto
  - **Parent**: #434

---

## Phase 5: Lower Priority (Non-Blocking)

These issues improve quality but don't block core functionality.

### 5.1 Asset Pipeline
- **[#218]** Placeholder: SpriteLoader still uses placeholder sprite data
  - **Dependencies**: Asset generation pipeline
- **[#219]** Placeholder: Sound effects tables contain fake data
  - **Dependencies**: Asset generation pipeline
- **[#282]** Fix asset dependency graph for Generated files
- **[#54]** Complete SkylineTool asset compilation pipeline

### 5.2 Technical Debt
- **[#249]** Bug: find-nearest-palette-color references undefined *region* variable
- **[#246]** Music compiler: Disable ADSR for 2600 path
- **[#173]** Audit: Remove negative-value logic on unsigned byte variables

### 5.3 Documentation
- **[#389]** Document per-character behaviors: missile types, weights, special moves
  - **Dependencies**: Character system complete

---

## Execution Priority (REVERSE ORDER)

**Execute in order: 5 → 4 → 3 → 2 → 1**

1. **Phase 5 (Lower Priority)** - Polish and improvements
2. **Phase 4 (Code Quality)** - Can be done incrementally
3. **Phase 3 (Game Flow)** - Required for complete gameplay loop
4. **Phase 2 (Animation System)** - Required for character movement
5. **Phase 1 (Critical Blockers)** - Must complete before any testing

---

## Success Criteria

Milestone 1 is complete when:
- ✅ **All `make all` build artifacts are ready**
  - ROM builds to 65536 bytes for all TV standards (NTSC, PAL, SECAM)
  - All generated files are present and valid
  - Documentation builds successfully
  - No build errors or warnings

---

## Estimated Timeline

- **Total**: 2-3 hours maximum for all phases
- Work will be done incrementally in reverse order (5→4→3→2→1)

---

## Notes

- Issues marked with ✓ are already implemented but need verification
- Sub-issues will be created as GitHub issues and linked to parent issues
- All issues will be assigned to Milestone 1
- Priority can be adjusted based on testing feedback

