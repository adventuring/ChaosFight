# Bank Reorganization Plan

## Problem
Compile-time errors with addresses >$10000 indicate bank overruns.
With 64K bankswitch, each bank has ~3.5KB usable space (4KB minus 512B hotspot area).

## Current Bank 1 Contents (OVERLOADED)
- ColdStart.bas
- MainLoop.bas
- ControllerDetection.bas (196 lines)
- EnhancedButtonInput.bas
- CharacterSelect.bas (417 lines)
- FallingAnimation.bas
- LevelSelect.bas
- **LevelData.bas (634 lines)** ← LARGEST FILE
- GameLoopInit.bas (131 lines)
- GameLoopMain.bas

**Total: ~2000+ lines in Bank 1 - WAY TOO BIG!**

## Large Files to Redistribute
1. **LevelData.bas** (634 lines) - All 16 arena definitions
2. **MissileSystem.bas** (609 lines)
3. **MissileCollision.bas** (487 lines)
4. **CharacterSelect.bas** (417 lines)
5. **CharacterData.bas** (385 lines)
6. **PlayerRendering.bas** (369 lines)

## Recommended Reorganization

### Bank 1 (Core/Entry)
- ColdStart.bas
- MainLoop.bas
- ControllerDetection.bas
- EnhancedButtonInput.bas
- LevelSelect.bas
- **Keep light, entry point code only**

### Bank 2 (Level Data)
- **LevelData.bas** ← Move from Bank 1
- Playfield collision routines (if needed)

### Bank 3 (Character Selection)
- CharacterSelect.bas
- CharacterSelectMain.bas
- TitleSequence.bas
- TitleCharacterParade.bas

### Bank 4 (Character Data)
- CharacterData.bas
- CharacterDefinitions.bas (data tables)
- CharacterControls.bas

### Bank 5 (Player Rendering)
- PlayerRendering.bas
- FontRendering.bas
- FallingAnimation.bas

### Bank 6 (Missile System)
- MissileSystem.bas

### Bank 7 (Missile Collision)
- MissileCollision.bas

### Bank 8 (Game Loop)
- GameLoopInit.bas
- GameLoopMain.bas
- PlayerInput.bas
- ConsoleHandling.bas

### Bank 9 (Combat & Physics)
- Combat.bas
- PlayerPhysics.bas
- FallDamage.bas

### Bank 10 (Character Attacks)
- CharacterAttacks.bas
- (room for more attack routines)

### Banks 11-16
- Reserved for future expansion
- Additional character data
- Additional arenas
- Music/sound effects

## Implementation Steps
1. Move LevelData.bas to Bank 2 (immediate priority)
2. Move CharacterSelect routines to Bank 3
3. Redistribute remaining large files
4. Update bank switching calls where needed
5. Test compilation to verify no overruns
