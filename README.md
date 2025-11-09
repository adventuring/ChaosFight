# ChaosFight - System Architecture

A 4-player fighting game for the Atari 2600, built with batariBASIC targeting the 64KB SuperChip cartridge format.

## Overview

ChaosFight uses a dual-context execution model: **Admin Mode** (title screens, menus) and **Game Mode** (gameplay). The game runs on a multisprite kernel, requiring 4-player sprite support while maintaining 60fps performance through careful frame budgeting.

## Memory Architecture

### RAM Layout

**Standard RAM** (74 bytes total):
- `a`-`z`: 26 bytes (built-in and user variables)
- `var0`-`var47`: 48 bytes ($A4-$D3)

**SuperChip RAM (SCRAM)** (128 bytes):
- **Read ports**: `r000`-`r127` ($F080-$F0FF)
- **Write ports**: `w000`-`w127` ($F000-$F07F)
- **Critical**: SCRAM has separate read/write ports mapping to the same physical RAM. Always use `_R` suffix for reads, `_W` for writes (e.g., `selectedArena_W`, `selectedArena_R`).

**Memory Contexts**:
- **Admin Mode** (GameModes 0-5, 7): Title, preambles, character select, arena select, winner screen
- **Game Mode** (GameMode 6): Active gameplay
- Variables can be redimmed between contexts (see `Source/Common/Variables.bas` for allocations)

### Variable Conventions

- **Zero-page** (Standard RAM): Frame-critical variables (physics, positions, state)
- **SCRAM**: Less-frequent variables (animation counters, timers, menu state)

See `Source/Common/Variables.bas` for complete memory layout.

## Bank Organization (64KB Cartridge)

### Asset Banks (Separate Memory Budget)
**Music/Sound Assets:**
- **Bank 1**: Character theme songs (IDs 6-28) - Bolero, LowRes, RoboTito, SongOfTheBear, DucksAway, Character16-30 themes
- **Bank 15**: Sound effects + character theme songs (IDs 0-5) - Bernie, OCascadia, Revontuli, EXO, Grizzards, MagicalFairyForce

**Character Art Assets:**
- **Bank 2**: Character sprites (0-7) - Bernie, Curler, DragonOfStorms, ZoeRyen, FatTony, Megax, Harpy, KnightGuy
- **Bank 3**: Character sprites (8-15) - Frooty, Nefertem, NinjishGuy, PorkChop, RadishGoblin, RoboTito, Ursulo, Shamone
- **Bank 4**: Character sprites (16-23) - Character16-23 (placeholders)
- **Bank 5**: Character sprites (24-31) - Character24-30, MethHound

### General Code Banks (8 Banks - Shared Memory Budget)
- **Bank 6**: Character selection (main/render)
- **Bank 7**: Missile system (tables, physics, collision) + combat system
- **Bank 8**: Physics system (gravity, movement, special abilities) + screen layout + health bars + main loop dispatcher
- **Bank 10**: Sprite rendering (character art loader, player rendering, elimination) + character attacks system
- **Bank 11**: Gameplay loop (init/main/collision resolution/animation) + attack support data
- **Bank 12**: Character data system (definitions, cycles, falling animation, fall damage)
- **Bank 13**: Input system (movement, player input, guard effects)
- **Bank 14**: Console handling (detection, controllers, game mode transitions, character controls)

### Special Purpose Banks
- **Bank 9**: Titlescreen system (graphics assets, titlescreen kernel, preambles, attract mode, winner/data tables)
- **Bank 16**: Arenas + drawscreen (main loop, arena data/loader, special sprites, numbers font, font rendering)

## Execution Flow

### Main Loop (`Source/Routines/MainLoop.bas`)

Central dispatcher that routes to mode-specific handlers:

```basic
MainLoop
  if switchreset then gosub bank11 WarmStart : goto MainLoopContinue
  if gameMode = 0 then gosub bank9 PublisherPreambleMain : goto MainLoopContinue
  if gameMode = 1 then gosub bank9 AuthorPreamble : goto MainLoopContinue
  ...
```

**Game Modes**:
- `0`: Publisher Prelude
- `1`: Author Prelude  
- `2`: Title Screen
- `3`: Character Select
- `4`: Falling Animation
- `5`: Arena Select
- `6`: Gameplay (dispatches to `GameMainLoop` in Bank 11)
- `7`: Winner Announcement

### Gameplay Loop (`Source/Routines/GameLoopMain.bas`)

Per-frame sequence:
1. Console switches (pause, reset)
2. Player input (with Quadtari multiplexing)
3. Animation updates (10fps)
4. Movement/physics
5. Collisions (players, missiles, playfield)
6. Combat/damage
7. Sprite rendering
8. Health bar updates
9. Screen draw

Frame budgeting distributes expensive operations (health bars, multi-player collisions) across multiple frames.

## Key Systems

### Controller System (`Source/Routines/ControllerDetection.bas`)
- Auto-detects: CX-40, Genesis 3-button, Joy2B+, Quadtari
- Quadtari: Frame multiplexing (even=P1/P2, odd=P3/P4)
- Enhanced controllers: Additional button mappings via INPT0-5

### Character System (`Source/Common/CharacterDefinitions.bas`)
- Data-driven via `on-goto` dispatch (O(1) lookups)
- Character properties: Weight, missile types, special abilities
- Sprite loading: `SpriteLoader.bas` → bank-specific assembly routines

### Missile System (`Source/Routines/MissileSystem.bas`)
- Supports up to 4 active missiles
- Physics: Gravity, bounce, friction (character-specific)
- Collision: AABB detection vs players, playfield

### Physics System (`Source/Routines/PlayerPhysics.bas`)
- Gravity (character-specific, some ignore)
- Weight-based: Jump height, fall damage, knockback resistance
- Momentum: 8.8 fixed-point velocity with recovery frames

### Animation System (`Source/Routines/AnimationSystem.bas`)
- 8 frames × 16 actions per character
- 10fps update rate (spread across frames)
- Character-specific attack dispatches to `CharacterAttacks.bas`

## Asset Pipeline

### Character Sprites

**Source Format**: `Source/Art/CharacterName.xcf` (GIMP)

**Pipeline**:
```bash
# XCF → PNG (automatic via Makefile)
make Source/Art/CharacterName.png

# PNG → batariBASIC data (automatic)
make Source/Generated/CharacterName.bas

# Generate all characters
make characters
```

**Generated Output** (`Source/Generated/CharacterName.bas`):
- `data CharacterNameFrames`: Deduplicated sprite frame data
- `data CharacterNameFrameMap`: Indirection table (action × frame → frame index)

**Bank Allocation**:
- Bank 2: Characters 0-7
- Bank 3: Characters 8-15
- Bank 4: Characters 16-23 (placeholders)
- Bank 5: Characters 24-31

**Sprite Loading**: `Source/Routines/SpriteLoader.bas` dispatches to bank-specific assembly routines (`CharacterArtBank*.s`).

### Other Assets

- **Bitmaps** (48×42px): `Source/Art/BitmapName.xcf` → `Source/Generated/Art.BitmapName.s`
- **Music**: `Source/Art/SongName.mscz` → `Source/Generated/Song.SongName.{NTSC,PAL,SECAM}.bas`
- **Sounds**: `Source/Art/SoundName.wav` → `Source/Generated/Sound.SoundName.{NTSC,PAL,SECAM}.bas`
- **Fonts**: `Source/Art/FontName.png` → `Source/Generated/FontName.bas`

All asset compilation handled by **SkylineTool** (included submodule).

## Build System

### Requirements
- **batariBASIC** (included in `Tools/`)
- **DASM** assembler (included)
- **SBCL** + Common Lisp (for SkylineTool)
- **GIMP** (for XCF→PNG export)
- **MuseScore** (optional, for music)

### Build Commands

```bash
# Build all ROMs (NTSC, PAL, SECAM)
make all

# Build ROMs only
make game

# Build documentation
make doc

# Generate all character sprites
make characters

# Test in Stella emulator
make emu
```

### Output Files
- `Dist/ChaosFight25.{NTSC,PAL,SECAM}.a26` - ROM files
- `Dist/ChaosFight25.{sym,lst,pro}` - Debug symbols/listings
- `Dist/ChaosFight25.{pdf,html}` - Game manual

### Build Process
1. Preprocess batariBASIC (C preprocessor with `-traditional` flag)
2. Compile to assembly via batariBASIC
3. Assemble via DASM with bank switching
4. Link and generate ROM

## Coding Conventions

### Naming
- **Built-ins**: `lowercase` (`temp1`, `joy0fire`)
- **User variables**: `camelCase` (`playerX`, `gameState`)
- **Constants**: `PascalCase` (`MaxCharacter`, `ColBlue(14)`)
- **Routines/Labels**: `PascalCase` (`LoadCharacterSprite`, `HandleInput`)
- **SCRAM variables**: `camelCase_R` / `camelCase_W` (separate read/write)

### File Organization
- One subroutine per file for large/complex routines
- Group related subroutines when tightly coupled
- Files in `Source/Routines/`, included by bank files in `Source/Banks/`

### Documentation
All subroutines must include header comments:
```basic
LoadCharacterSprite
  rem Load sprite data for character
  rem Input: temp1 = character index, temp2 = frame
  rem Output: Sprite loaded into player register
```

See `Source/StyleGuide.md` for complete coding standards.

## Development Setup

```bash
# Install dependencies (Fedora/RHEL)
sudo dnf install gcc make gimp sbcl texlive texinfo

# Initialize submodules
git submodule update --init --recursive

# Build tools
make bin/skyline-tool bin/zx7mini

# Build game
make all
```

## Key Files Reference

- `Source/Routines/MainLoop.bas` - Main execution dispatcher
- `Source/Routines/GameLoopMain.bas` - Gameplay per-frame loop
- `Source/Common/Variables.bas` - Memory layout and variable declarations
- `Source/Common/CharacterDefinitions.bas` - Character data tables
- `Source/Routines/ControllerDetection.bas` - Controller auto-detection
- `Source/Routines/MissileSystem.bas` - Projectile management
- `Source/Routines/SpriteLoader.bas` - Character sprite loading
- `Source/Banks/Banks.bas` - Bank organization and includes
- `Makefile` - Build configuration and asset pipeline

---

**ChaosFight** - (c) 2025 Interworldly Adventuring, LLC.
