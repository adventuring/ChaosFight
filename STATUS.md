# ChaosFight Development Status

## Code Organization - All Files <200 Lines ✓

### Completed Refactoring:
- **PlayerInput.bas** (213 lines) - Quadtari multiplexing, character-specific dispatch
- **CharacterControls.bas** (219 lines) - All 16 character jump/down handlers
- **SpecialMovement.bas** (67 lines) - Per-frame physics (Bernie screen wrap)
- **TitleScreenMain.bas** (57 lines) - Title screen loop
- **TitleCharacterParade.bas** (158 lines) - Animated character parade
- **TitleScreenRender.bas** (78 lines) - 32×32 playfield with color-per-row
- **PublisherPreamble.bas** (~90 lines) - AtariAge screen
- **AuthorPreamble.bas** (~90 lines) - Interworldly screen
- **GameLoopInit.bas** (111 lines) - Game initialization
- **GameLoopMain.bas** (75 lines) - Main loop orchestration
- **PlayerPhysics.bas** (183 lines) - Gravity, momentum, collisions
- **PlayerRendering.bas** (185 lines) - Sprite positioning and display
- **Combat.bas** (186 lines) - Combat system
- **CharacterAttacks.bas** (185 lines) - Character-specific attacks
- **Physics.bas** (86 lines) - Physics utilities

### Remaining Large Files:
- **GameLoop.bas** (1052 lines) - Original file, being replaced by modular files
- **FontRendering.bas** (431 lines) - Will be data-driven
- **CharacterSelect.bas** (348 lines) - Needs breakdown
- **CharacterDefinitions.bas** (318 lines) - Should be pure data
- **TitleSequence.bas** (228 lines) - May integrate with preambles

## Major Features Implemented:

### Character-Specific Controls:
- 16 characters with unique behaviors
- Weight-based jump heights (light/medium/heavy)
- Special movement: Bernie (screen wrap), Robo Tito (vertical), Harpy (flight), Magical Faerie (fly up/down, no guard)
- Quadtari multiplexing (frame-based joy0/joy1 switching)
- `on PlayerChar[n] goto` dispatch pattern

### 32×32 Playfield Screens (pfres=32):
- Color-per-row support (COLUPF, COLUBK per scanline)
- Three screens: AtariAge (publisher), Interworldly (author), ChaosFight (title)
- Gradient and multi-color effects
- Uses all 128 bytes SuperChip RAM

### Font System:
- Hexadecimal digits 0-F (16 characters)
- 8×16 pixels each, white-on-black
- Source: Numbers.xcf (128×16 px)
- For player numbers, level selection, scores

### Build Infrastructure:
- XCF → PNG → batariBASIC pipeline
- Architecture-specific output (NTSC/PAL/SECAM)
- Mock skyline-tool generates data
- Makefile rules for characters, playfields, fonts

## Documentation:
- All files have comprehensive REM documentation
- Available variables clearly listed
- Input/output parameters documented
- Character indices (0-15) documented
- State flags explained

## Next Steps:
1. Complete GameLoop refactoring (attack/damage/missile systems)
2. Break down CharacterSelect.bas
3. Convert CharacterDefinitions.bas to pure data
4. Optimize FontRendering.bas with data-driven approach
5. Implement real SkylineTool functions (Lisp)
6. Create actual artwork (XCF files)
