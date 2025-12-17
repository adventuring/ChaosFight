# Open Tickets Summary by Area

## Critical Bugs (Require Debug Traces)

### Stack/Execution Corruption
- **#1323**: Crash at $3:ffe4 - execution jumped into EFSC header area
  - PC jumped into bank switching hotspot area (data, not code)
  - $ffe4 is null byte after "EFSC" header - execution should never reach here
  - Related to stack corruption or incorrect return address handling

- **#1314**: Stack pointer corrupted: SP = $32 before Startup.s txs
  - Stack pointer is wrong value when Startup.s tries to initialize it
  - Code path: Reset → Bank 13 → ColdStart → ConsoleDetection.s → Startup.s
  - Something between Reset and Startup.s is corrupting SP

- **#1232**: Stack underflow at $5:fb63
  - Stack underflow detected during execution
  - Needs investigation of code at $fb63 in bank 5 and its call chain

- **#1246**: Write to read port: $378d at $3:ffe4
  - Attempting to write to read-only port
  - Related to #1323 crash location

- **#1245**: Crash: Accessing non-connected memory space around $2axx
  - Accessing invalid memory region
  - Requires debug trace for exact address and context

### Verified/Fixed (Awaiting Closure)
- **#1330**: BS_jsr encoding inconsistencies - **VERIFIED COMPLETE**
  - All BS_jsr calls now properly encode return addresses
  - Systematic check confirmed all ~130 routines use `jmp BS_return` correctly

## Rendering/Display Issues

- **#1226**: Publisher Prelude: Unstable frame display with wild scanline variations (up to 924 lines)
  - Frame timing instability causing excessive scanlines
  - Rendering performance issue

- **#1227**: Publisher Prelude: Player graphics positioning incorrect for 48px display
  - Graphics positioning bug in title screen area
  - Affects 48-pixel display mode

## Code Completion TODOs

### Core Game Systems
- **#1310**: Complete Combat loop and label TODOs
  - Missing loop conversions (for defenderID = 0 to 3, for attackerID = 0 to 3)
  - Missing NextDefender label

- **#1269**: Complete PlayerBoundaryCollisions TODO
  - Remaining TODO items in boundary collision system

- **#1298**: Complete PlayerPlayfieldCollisions Convert assignment TODOs
  - Multiple "Convert assignment" TODOs from batariBASIC conversion
  - Variables: currentPlayer, temp2-6, playfieldRow, playfieldColumn, etc.
  - Need proper assembly implementation

- **#1265**: Complete HealthBarSystem TODOs
  - Health bar system completion items

### Character-Specific Systems
- **#1308**: Complete CharacterAttacksDispatch enhanced jump button check TODOs
  - Missing enhanced jump button checks (CEJB_CheckPlayer0, CEJB_CheckPlayer2)
  - Needed for proper enhanced controller support

- **#1307**: Complete HandleFlyingCharacterMovement HFCM_CheckRightJoy0 TODO
  - Missing handler for Player 0 right movement check in flying character movement

- **#1249**: Implement Shamone <-> MethHound form switching
  - Feature implementation: character form switching mechanic

### Input/Controller Systems
- **#1251**: Implement Genesis/MegaDrive controller detection
  - Feature implementation: detect Genesis/MegaDrive controllers

- **#1254**: Complete loop conversions: for currentPlayer = 0 to 3
  - Convert remaining batariBASIC loops to assembly

### Rendering Systems
- **#1304**: Complete SpriteLoader documentation TODOs
  - Convert TODO-prefixed documentation to proper comments
  - Lines 4-11, 93-124 need cleanup

- **#1309**: Complete DisplayWinScreen color loading comment TODOs
  - Convert TODO comments to regular documentation comments
  - Missing DWS_RankNext label

- **#1306**: Complete BudgetedPlayerCollisions phase label TODOs
  - Missing phase labels: BPC_Phase0, BPC_Phase1, BPC_Phase2

### State Management
- **#1291**: Complete PlayerLockedHelpers TODOs
  - GPL_lockedState = temp2 assignments (lines 75, 85, 102, 121)

- **#1302**: Complete VblankHandlers VblankTransitionToWinner TODO
  - Missing transition handler for winner announcement

### Miscellaneous Code Cleanup
- **#1311**: Complete remaining miscellaneous TODOs
  - ArenaSelect.s: cpx #3 (line 294)
  - CharacterSelectRender.s: Color constants (line 17)
  - TitleScreenMain.s: SCRAM read/write port usage (line 68)
  - PlayfieldRead.s: Multiple implementation detail TODOs (lines 30, 38, 40, 53, 85-86)
  - MissileCharacterHandlers.s: MegaxMissileActive (line 209), KnightGuyAttackActive (line 295)

- **#1305**: Complete LoadArenaByIndex optimization comment TODOs
  - Convert TODO comments explaining optimization to regular comments
  - Code is already implemented correctly, just needs documentation cleanup

## Code Optimization

- **#1316**: Find and optimize unnecessary cmp/cpx/cpy # 0 operations
  - Found 130 occurrences across codebase
  - Many are redundant when Z flag is already set by previous operations

- **#1317**: Find and optimize unnecessary cmp/cpx/cpy # 0 before beq/bne
  - Specific optimization: remove redundant compares before conditional branches
  - Saves cycles and bytes

## Tooling (SkylineTool)

### Lisp Code Cleanup
- **#1312**: Review and clean up XXX comments in SkylineTool
  - graphics.lisp: NTSC color names (line 3138)
  - maps.lisp: Tileset comments (lines 78, 286)
  - music.lisp: Duration calculation comment (line 1406)
  - fountain.lisp: Symbolic script IDs (line 80)
  - decode-map.lisp: Undefined byte/bit comments (lines 57-58, 81)
  - forth.lisp: Unknown word comment (line 277)

### Lisp Feature Implementation
- **#1284**: Fix SkylineTool graphics.lisp unimplemented function
  - atari-colu-run function is unimplemented (line 1206)
  - Needs completion

- **#1287**: Complete SkylineTool graphics.lisp remaining TODOs
  - +apple-hires-palette+ constant (line 52) - references #1243: #1223
  - +ted-palette+ constant (line 221) - references #1243: #1224
  - Relative positioning capture (line 1654) - references #1226
  - Function to generate file contents (line 1664) - references #1243: #1227
  - Conditional compilation (line 2191) - references #1243: #1242
  - Unimplemented mode error (line 2552)
  - NTSC color names note (line 3138)

- **#1288**: Complete SkylineTool fountain.lisp walk TODO
  - Player movement in walk stage direction (line 2674)
  - References issue #151

## Summary Statistics

**Total Open Issues: 30**

- **Critical Bugs**: 5 (all require debug traces for diagnosis)
- **Rendering/Display**: 2
- **Code Completion**: 15 (various systems)
- **Code Optimization**: 2
- **Tooling (SkylineTool)**: 6

**By Priority:**
- **High Priority** (crashes, stack corruption): #1323, #1314, #1232, #1246, #1245
- **Medium Priority** (rendering, missing features): #1226, #1227, #1249, #1251, #1254
- **Low Priority** (code cleanup, documentation, optimization): Remaining issues

