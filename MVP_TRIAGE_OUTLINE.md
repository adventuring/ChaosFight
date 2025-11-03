# ChaosFight MVP Issue Triage Outline

**Date**: Generated from Requirements.md analysis  
**Focus**: Issues directly related to MVP requirements from Source/Requirements.md

## Summary
Issues categorized into three clusters based on implementation complexity and requirements clarity.

---

## Category 1: TRIVIAL IMPLEMENTATIONS

**Definition**: Issues that are straightforward to implement with clear, minimal requirements. Can be completed quickly with simple code changes.

### Issues Included:
- **#362**: Fix character select - down input triggers wrong animations and sounds
  - **Requirement**: DOWN button should unlock selection, not trigger hurt animations/sounds
  - **Fix**: Isolate menu input handling from gameplay input handlers
  - **Files**: CharacterSelectMain.bas, PlayerInput.bas

- **#383**: Fix Game Reset to perform instant hard reboot from any mode
  - **Requirement**: Game Reset calls ColdStart (clears vars, reinitializes hardware)
  - **Fix**: Modify ConsoleHandling.bas to jump to ColdStart instead of CharacterSelect
  - **Files**: ConsoleHandling.bas

- **#390**: Level Select: Rename SelectedLevel to SelectedArena
  - **Requirement**: Standardize terminology on "Arena"
  - **Fix**: Find/replace variable name across codebase
  - **Files**: Variables.bas, LevelSelect.bas, GameLoopInit.bas

- **#400**: Title Screen: Separate copyright timer from parade timer
  - **Requirement**: Copyright disappears at 5 seconds, separate timer needed
  - **Fix**: Add TitleCopyrightTimer variable, increment each frame
  - **Files**: Variables.bas, TitleScreenMain.bas

- **#401**: Title Screen: Update parade start timing to 5 seconds
  - **Requirement**: Parade starts when copyright disappears (300 frames)
  - **Fix**: Update TitleCharacterParade.bas to check copyright timer
  - **Files**: TitleCharacterParade.bas

- **#402**: Winner Screen: Add button press detection for return to title
  - **Requirement**: Winner presses button to return to title screen
  - **Fix**: Add button check in WinnerAnnouncement loop, transition on press
  - **Files**: WinnerAnnouncement.bas

- **#408**: Level Select: Implement 2-digit decimal formatting (01-16)
  - **Requirement**: Format arena ID (0-15) as "01" through "16"
  - **Fix**: Create FormatArenaNumber function using division/modulo
  - **Files**: LevelSelect.bas

- **#410**: Level Select: Implement '??' display for random arena
  - **Requirement**: Display '??' when SelectedArena = 255
  - **Fix**: Check for RandomArena value, render two '?' characters
  - **Files**: LevelSelect.bas

- **#393**: Level Select: Add Game Select switch detection
  - **Requirement**: Game Select returns to Character Select
  - **Fix**: Add switchselect check in LevelSelect loop
  - **Files**: LevelSelect.bas

- **#392**: Level Select: Add 1-second Fire button hold detection
  - **Requirement**: Hold Fire for 60 frames returns to Character Select
  - **Fix**: Add timer variable, increment when Fire pressed, reset when released
  - **Files**: LevelSelect.bas

- **#395**: Falling In: Define quadrant starting positions
  - **Requirement**: Position players at four quadrants before animation
  - **Fix**: Set PlayerX/Y[0-3] to quadrant coordinates in BeginFallingAnimation
  - **Files**: BeginFallingAnimation.bas

- **#426**: Fix terminology: Clarify participant numbers (1-4) vs sprite indices (P0-P3)
  - **Requirement**: Update comments to clarify participant vs sprite numbering
  - **Fix**: Search/replace "Player 0" → "Participant 1 (array [0])" in comments
  - **Files**: Multiple .bas files (comments only)

- **#438**: Document Shamone's special upward attack/jump and Meth Hound form switching
  - **Requirement**: Already implemented, needs documentation verification
  - **Fix**: Verify Requirements.md matches implementation (already complete per issue)
  - **Files**: Requirements.md (verification only)

- **#439**: Update character attack types: Ninjish Guy should be ranged (shuriken), not melee
  - **Requirement**: Update Requirements.md documentation
  - **Fix**: Change Character 10 attack type from Melee to Ranged in Requirements.md
  - **Files**: Requirements.md

- **#427**: Rename EXOPilot.texi to ZoeRyen.texi and update references
  - **Requirement**: Already completed per issue status
  - **Status**: ✅ COMPLETED

### Total Issues: 15 (14 open, 1 completed)

---

## Category 2: ACHIEVABLE WITH CLEAR REQUIREMENTS

**Definition**: Issues that require moderate effort but have clear requirements and acceptance criteria. Implementation path is well-defined.

### Issues Included:
- **#234**: Main loop integration: Authors Prelude
  - **Requirement**: Refactor to use centralized ChangeGameMode/MainLoop structure
  - **Implementation**: Split into BeginAuthorPrelude (setup) + AuthorPrelude loop (main loop)
  - **Files**: AuthorPreamble.bas, MainLoop.bas, ChangeGameMode.bas

- **#237**: Main loop integration: Falling Animation
  - **Requirement**: Refactor to use centralized dispatcher
  - **Implementation**: Split into BeginFallingAnimation (setup) + FallingAnimation loop
  - **Files**: FallingAnimation.bas, MainLoop.bas, ChangeGameMode.bas

- **#238**: Main loop integration: Level Select
  - **Requirement**: Refactor to use centralized dispatcher
  - **Implementation**: Split into BeginLevelSelect (setup) + LevelSelect loop
  - **Files**: LevelSelect.bas, MainLoop.bas, ChangeGameMode.bas

- **#239**: Main loop integration: Game Loop
  - **Requirement**: Migrate GameLoop to centralized dispatcher
  - **Implementation**: BeginGameLoop (setup) + GameMainLoop (already exists)
  - **Files**: GameLoopInit.bas, GameLoopMain.bas, MainLoop.bas

- **#240**: Main loop integration: Winner Announcement
  - **Requirement**: Refactor to use centralized dispatcher
  - **Implementation**: Split into BeginWinnerAnnouncement (setup) + WinnerAnnouncement loop
  - **Files**: WinnerAnnouncement.bas, MainLoop.bas, ChangeGameMode.bas

- **#382**: Implement Attract mode after 3-minute title screen timeout
  - **Requirement**: After 10800 frames, transition to Attract mode (loops back to Publisher Prelude)
  - **Implementation**: Add ModeAttract enum, BeginAttractMode setup, AttractMode loop
  - **Files**: Enums.bas, MainLoop.bas, ChangeGameMode.bas, TitleScreenMain.bas (timer check)

- **#384**: Fix Level Select: Implement 01-16/?? display, 1-second hold return, Game Select detection
  - **Requirement**: Parent issue for Level Select features
  - **Breakdown**: Sub-issues #390, #391, #392, #393, #394 (some trivial, others achievable)
  - **Status**: Meta-issue (spawned sub-issues)

- **#385**: Fix Falling In: Implement quadrant-to-row2 movement with playfield nudging
  - **Requirement**: Parent issue for Falling In features
  - **Breakdown**: Sub-issues #395-399, #411-413 (some trivial, others achievable)
  - **Status**: Meta-issue (spawned sub-issues)

- **#386**: Fix Title Screen: Copyright disappears at 5s, not 10s; verify logo positioning
  - **Requirement**: Parent issue for Title Screen timing
  - **Breakdown**: Sub-issues #400, #401 (both trivial)
  - **Status**: Meta-issue (mostly resolved by trivial fixes)

- **#387**: Verify Winner Screen button press return to title screen
  - **Requirement**: Parent issue for Winner Screen
  - **Breakdown**: Same as #402 (trivial)
  - **Status**: Meta-issue (resolved by #402)

- **#391**: Level Select: Implement 01-16 number display with '??' option
  - **Requirement**: Parent issue for arena number display
  - **Breakdown**: Sub-issues #408, #409, #410
  - **Files**: LevelSelect.bas, FontRendering.bas

- **#394**: Level Select: Render locked-in player graphics
  - **Requirement**: Display four player sprites in quadrants
  - **Breakdown**: Sub-issues #414, #415
  - **Files**: LevelSelect.bas, SpriteLoader.bas

- **#397**: Falling In: Implement playfield collision scanning for row 2 positioning
  - **Requirement**: Find first clear row from top of screen
  - **Breakdown**: Sub-issues #411, #412, #413
  - **Files**: FallingAnimation.bas

- **#399**: Falling In: Call BeginGameLoop before switching to Game Mode
  - **Requirement**: Initialize game state before entering Game Mode
  - **Implementation**: Call BeginGameLoop after FallingAnimation completes, then switch mode
  - **Files**: FallingAnimation.bas

- **#396**: Falling In: Implement quadrant-to-center horizontal+vertical movement
  - **Requirement**: Players move from quadrants toward center positions
  - **Implementation**: Update FallingAnimation loop to move both X and Y axes simultaneously
  - **Files**: FallingAnimation.bas

- **#398**: Falling In: Add playfield nudging if collision at starting position
  - **Requirement**: Nudge player down if playfield pixels at starting position
  - **Implementation**: After row 2 positioning, check collision, move down if needed
  - **Files**: FallingAnimation.bas

- **#409**: Level Select: Render two digits side-by-side using font system
  - **Requirement**: Display formatted arena number using DrawDigit function
  - **Implementation**: Call DrawDigit twice, position player0/player1 sprites side-by-side
  - **Files**: LevelSelect.bas, FontRendering.bas

- **#411**: Falling In: Create playfield collision detection helper function
  - **Requirement**: Reusable function to check playfield pixels at position
  - **Implementation**: Create CheckPlayfieldCollision(X, Y) function
  - **Files**: FallingAnimation.bas

- **#412**: Falling In: Implement row-by-row scanning loop from top of screen
  - **Requirement**: Scan 8 rows starting from top, find first clear row
  - **Implementation**: Loop Y from 0 to 64, increment by 8, check each row
  - **Files**: FallingAnimation.bas

- **#413**: Falling In: Verify width requirement (16 pixels) for double-width player
  - **Requirement**: Ensure found row has 16 pixels clear width
  - **Implementation**: Check center, left (X-8), right (X+8) all clear
  - **Files**: FallingAnimation.bas

- **#414**: Level Select: Load player character sprites from SelectedChar variables
  - **Requirement**: Load sprites using LoadPlayer0-3Sprite functions
  - **Implementation**: Check SelectedChar1-4, call sprite loading functions
  - **Files**: LevelSelect.bas, SpriteLoader.bas

- **#415**: Level Select: Position and render player sprites in screen quadrants
  - **Requirement**: Position sprites at fixed screen coordinates
  - **Implementation**: Set player0x/player0y, player1x/player1y, etc. to quadrant positions
  - **Files**: LevelSelect.bas

- **#403**: Verify Frooty free flight special move implementation
  - **Requirement**: Verify UP/DOWN move Frooty vertically, no guard action
  - **Verification**: Check PlayerInput.bas, SpecialMovement.bas, Physics.bas
  - **Files**: PlayerInput.bas, SpecialMovement.bas, Physics.bas

- **#404**: Verify Harpy fly-by-jumping special move implementation
  - **Requirement**: Verify repeated UP presses maintain flight, swoop attack works
  - **Verification**: Check PlayerInput.bas, CharacterAttacks.bas, Physics.bas
  - **Files**: PlayerInput.bas, CharacterAttacks.bas, Physics.bas

- **#405**: Verify RoboTito ceiling stretch special move implementation
  - **Requirement**: Verify UP stretches to ceiling, DOWN returns to floor, no jumping
  - **Verification**: Check PlayerInput.bas, SpecialMovement.bas, Physics.bas
  - **Files**: PlayerInput.bas, SpecialMovement.bas, Physics.bas

- **#407**: Verify weights affect physics correctly (jump height, movement speed, knockback)
  - **Requirement**: Parent issue for weight physics verification
  - **Breakdown**: Sub-issues #423, #424, #425
  - **Files**: Physics.bas, MovementSystem.bas, Combat.bas

- **#406**: Verify missile systems work for all ranged characters
  - **Requirement**: Parent issue for missile verification
  - **Breakdown**: Sub-issues #416-422
  - **Files**: MissileSystem.bas, CharacterAttacks.bas, CharacterDefinitions.bas

- **#416**: Verify Curler missile system (curling stone from feet)
  - **Requirement**: Verify 4×2 curling stone spawns at feet, slides horizontally
  - **Verification**: Check missile data in CharacterDefinitions.bas, MissileSystem.bas
  - **Files**: CharacterDefinitions.bas, MissileSystem.bas

- **#417**: Verify Dragonet missile system (ballistic 2×2 projectile)
  - **Requirement**: Verify 2×2 projectile with ballistic arc (parabolic)
  - **Verification**: Check missile data, gravity flags
  - **Files**: CharacterDefinitions.bas, MissileSystem.bas

- **#418**: Verify EXO Pilot missile system (horizontal arrowshot)
  - **Requirement**: Verify 2×2 laser travels horizontally, fast speed
  - **Verification**: Check missile data, momentum values
  - **Files**: CharacterDefinitions.bas, MissileSystem.bas

- **#419**: Verify Fat Tony missile system (magic ring lasers)
  - **Requirement**: Verify magic ring projectile behavior
  - **Verification**: Check missile data, test in-game
  - **Files**: CharacterDefinitions.bas, MissileSystem.bas

- **#420**: Verify Harpy missile system (diagonal swoop attack)
  - **Requirement**: Verify diagonal swoop (character movement, not separate missile)
  - **Verification**: Check CharacterAttacks.bas for swoop implementation
  - **Files**: CharacterAttacks.bas

- **#421**: Verify Frooty missile system (lollipop sparkle, ballistic)
  - **Requirement**: Verify 2×2 sparkle with ballistic arc
  - **Verification**: Check missile data, gravity flags
  - **Files**: CharacterDefinitions.bas, MissileSystem.bas

- **#422**: Verify Ursulo missile system (ballistic arc, strongest throw)
  - **Requirement**: Verify strongest ballistic throw (momentum X=7, Y=-6)
  - **Verification**: Check missile data, test trajectory
  - **Files**: CharacterDefinitions.bas, MissileSystem.bas

- **#423**: Verify weight affects jump height calculation
  - **Requirement**: Verify heavier characters jump lower
  - **Verification**: Test light (10) vs heavy (35) characters, measure jump heights
  - **Files**: Physics.bas, PlayerPhysics.bas

- **#424**: Verify weight affects movement speed calculation
  - **Requirement**: Verify heavier characters move slower
  - **Verification**: Test light (10) vs heavy (30) characters, measure speeds
  - **Files**: MovementSystem.bas, PlayerPhysics.bas

- **#425**: Verify weight affects knockback resistance calculation
  - **Requirement**: Verify heavier characters resist knockback more
  - **Verification**: Test knockback from attacks between different weights
  - **Files**: Combat.bas, PlayerPhysics.bas

- **#388**: Standardize terminology: Use 'Arena' consistently, not 'Level'
  - **Requirement**: Update all comments, variable names to use 'Arena'
  - **Implementation**: Search/replace across codebase (partial, some done)
  - **Files**: Multiple .bas files

### Total Issues: 35 (some are parent/meta issues containing sub-issues)

---

## Category 3: COMPLEX OR REQUIRES ADDITIONAL INFORMATION

**Definition**: Issues that require investigation, architectural decisions, or have unclear requirements. May need design discussion before implementation.

### Issues Included:
- **#336**: CRITICAL: ROM build produces only 1276 bytes instead of 65536 bytes
  - **Requirement**: Fix ROM generation to produce full 64KB bankswitched ROM
  - **Complexity**: Critical build blocker, requires investigation of DASM/optimization pipeline
  - **Questions**: 
    - Is bankswitching configuration correct?
    - Is DASM format flag (-f3) correct?
    - Is postprocessing corrupting output?
    - Are ORG/RORG directives correct?
  - **Files**: Makefile, DASM configuration, Source/Common/Preamble.bas

- **#431**: Syntax: Missing 'let' keyword on variable assignments
  - **Requirement**: Add 'let' keyword to 2000+ variable assignments
  - **Complexity**: Large-scale refactoring across entire codebase
  - **Questions**:
    - Should this be automated or manual?
    - Are there edge cases (temp1-temp6, built-ins)?
    - What about existing memory about LET usage?
  - **Files**: All .bas files in Source/Routines/

- **#429**: Syntax: Labels should be PascalCase
  - **Requirement**: Convert labels to PascalCase (excluding batariBASIC keywords)
  - **Complexity**: Need to identify which labels are keywords vs user-defined
  - **Questions**:
    - How to identify batariBASIC keywords reliably?
    - Should this be done incrementally?
    - Are there goto/gosub references to update?
  - **Files**: Multiple .bas files

- **#434**: Syntax: Missing tail call optimizations
  - **Requirement**: Replace gosub+return with goto where appropriate
  - **Complexity**: Requires manual review to identify tail calls safely
  - **Questions**:
    - Which subroutines are safe to convert?
    - Are there bank-switching considerations?
    - Should this be automated?
  - **Files**: Multiple .bas files

### Total Issues: 4

**Note**: Issue #431, #429, #434 are part of a broader code quality initiative but are large-scale refactoring tasks that may require architectural decisions about automation vs manual work.

---

## Summary Statistics

- **Trivial**: 15 issues (14 open, 1 completed)
- **Achievable**: 35 issues (many are parent issues with sub-issues)
- **Complex**: 4 issues
- **Total MVP-Related Issues**: 54

---

## Recommendations

1. **Start with Trivial cluster**: These can be completed quickly and unblock other work.
2. **Then tackle Achievable cluster**: Well-defined requirements allow systematic implementation.
3. **Investigate Complex cluster**: These require deeper analysis before implementation planning.

---

**Generated by**: Automated triage from Requirements.md analysis  
**Next Steps**: Create three GitHub issues (one per cluster) referencing this outline.

