# ChaosFight 🎮

A sophisticated 4-player fighting game for the Atari 2600, featuring 16 unique characters with distinct abilities and advanced physics.

## Features

### ✅ Working Systems
- **4-Player Simultaneous Combat** - Advanced Quadtari support with frame multiplexing  
- **16 Unique Characters** - Each with custom weights, abilities, and attack types
- **Advanced Physics** - Gravity, momentum, fall damage with character-specific mechanics
- **Enhanced Controller Support** - CX-40, Genesis 3-button, Joy2B+, Quadtari
- **Collision Detection** - AABB missiles, AOE attacks, playfield boundaries
- **Special Abilities** - Flight (Frooty), immunity (Bernie/RoboTito), reduced gravity (Harpy/Dragon of Storms)
- **Memory Optimization** - SuperChip RAM with 96 variables during gameplay
- **Professional Architecture** - Modular design, data-driven character system

### 🎮 Characters & Combat

#### Character Types
**Ranged Fighters** (projectile attacks): Bernie, Curler, Dragon of Storms, Zoe Ryen, Fat Tony, Frooty, Megax, Ursulo                                             
**Melee Fighters** (close-range AOE attacks): Harpy, Knight Guy, Nefertem, Ninjish Guy, Pork Chop, Radish Goblin, Robo Tito, Shamone                                             

#### Character Stats & Missile Types

| Character | Weight | Attack Type | Missile Size | Missile Behavior | Special Move |
|-----------|--------|-------------|--------------|------------------|--------------|
| **Bernie** | 5 (Light) | Ranged | 1×1 px | Fast horizontal (momentum 5), 4-frame lifetime | Small quick projectile |
| **Curler** | 53 (Medium) | Ranged | 4×2 px | Slow ball with gravity/bounce/friction (momentum 8), infinite lifetime | Bouncing curling stone |
| **Dragon of Storms** | 100 (Heavy) | Ranged | 2×2 px | Ballistic arc (momentum X:4 Y:-4), hits background, infinite lifetime | Parabolic fireball |
| **Zoe Ryen** | 48 (Medium) | Ranged | 2×2 px | Fast horizontal (momentum 6), infinite lifetime | Energy bolt |
| **Fat Tony** | 57 (Medium) | Ranged | 2×2 px | Magic ring laser (momentum 0), 4-frame lifetime | Magic ring attack |
| **Megax** | 100 (Heavy) | Ranged | 2×2 px | Heavy projectile (momentum 0), 4-frame lifetime | Powerful blast |
| **Harpy** | 23 (Light) | Melee | N/A | Close-range attack, 5-frame lifetime | Aerial melee strike |
| **Knight Guy** | 57 (Medium) | Melee | N/A | Sword attack, 6-frame lifetime | Sword slash |
| **Frooty** | 45 (Medium) | Ranged | 2×2 px | Ballistic arc (momentum X:6 Y:-5), hits background, infinite lifetime | Parabolic fruit |
| **Nefertem** | 66 (Heavy) | Melee | N/A | Claw attack, 5-frame lifetime | Lion pounce |
| **Ninjish Guy** | 47 (Medium) | Melee | N/A | Ninja strike, 4-frame lifetime | Stealth attack |
| **Pork Chop** | 57 (Medium) | Melee | N/A | Close-range attack, 4-frame lifetime | Melee strike |
| **Radish Goblin** | 31 (Light) | Melee | N/A | Quick attack, 3-frame lifetime | Fast melee |
| **Robo Tito** | 60 (Heavy) | Melee | N/A | Robot punch, 5-frame lifetime | Mechanical strike |
| **Ursulo** | 83 (Heavy) | Ranged | 2×2 px | Ballistic arc (momentum X:7 Y:-6), hits background, infinite lifetime | Parabolic ice ball |
| **Shamone** | 35 (Light) | Melee | N/A | Quick attack, 4-frame lifetime | Fast melee combo |

**Weight Effects**:
- **Jump Height**: Lighter characters (5-23) jump higher, heavier characters (57-100) jump lower
- **Movement Speed**: Lighter characters move faster, heavier characters are slower but have more momentum
- **Fall Damage**: Heavier characters take less fall damage per velocity unit (weight/20 multiplier)
- **Impact Resistance**: Heavier characters resist knockback better
- **Safe Fall Velocity**: Calculated as 120/weight (heavier characters can fall faster safely)

**Missile Behavior Flags**:
- **Hit Background**: Missiles disappear on collision with walls/floors (Dragon of Storms, Frooty, Ursulo)
- **Hit Player**: Missiles cause damage and disappear on player contact (Curler)
- **Gravity**: Missiles affected by gravity creating ballistic arcs (Curler)
- **Bounce**: Missiles bounce off walls/floors (Curler)
- **Friction**: Missiles decelerate over time (Curler)

**Special Mechanics**:
- **Handicapping System**: Hold DOWN+FIRE during character select for 25% health reduction                                                                      
- **Fall Damage**: Weight-based calculation with character immunities
- **Recovery System**: Hitstun and momentum effects

## Building & Setup

### Requirements
- **batariBASIC** compiler (included in Tools/)
- **DASM** assembler (included)
- **SBCL** + Common Lisp libraries (for asset generation via SkylineTool)
- **GIMP** (for XCF→PNG conversion)
- **MuseScore** (for MSCZ→MIDI conversion, optional)
- **Linux/Unix** environment

### Quick Build
```bash
# Build for all TV systems
make all

# Build game ROMs only  
make game

# Build documentation
make doc

# Test in emulator
make emu
```

### Generated Files
- `Dist/ChaosFight25.NTSC.a26` - NTSC ROM (64KB)
- `Dist/ChaosFight25.PAL.a26` - PAL ROM  
- `Dist/ChaosFight25.SECAM.a26` - SECAM ROM
- `Dist/ChaosFight25.pdf` - Game manual (PDF)
- `Dist/ChaosFight25.html` - Game manual (HTML)

## Controller Setup

### Standard CX-40 Joystick
- **Directions**: Move character
- **UP**: Jump  
- **DOWN**: Guard
- **FIRE**: Attack

### Genesis 3-Button Controller
- **D-pad**: Move/Jump/Guard
- **Button B** (INPT4/5): Attack  
- **Button C** (INPT0/2): Enhanced Jump

### Joy2B+ Enhanced Controller  
- **Stick**: Move/Jump/Guard
- **Button I** (INPT4/5): Attack
- **Button II** (INPT0/2): Enhanced Jump
- **Button III** (INPT1/3): Pause

### Quadtari (4-Player)  
**Detection Method**: Check paddle ports INPT0-3 for signature patterns - if INPT0 LOW + INPT1 HIGH (left side) AND INPT2 LOW + INPT3 HIGH (right side), Quadtari detected.  
**Multiplexing**: Even frames read P1/P2, odd frames read P3/P4 (same physical ports). Players 3&4 use same controls as 1&2.

## Enhanced Controller Support

### Genesis 3-Button
- **Button A**: Fire (INPT4/5)  
- **Button B**: Secondary action (INPT4/5 alternate reading)
- **Button C**: Special ability (INPT0/2 - reliable input method)
- **D-Pad**: Standard joystick movement

### Joy2B+ Enhanced  
- **Button I**: Fire (INPT4/5)
- **Button II**: Secondary action (INPT1/3 - reliable input method)  
- **Button III**: Special ability / Pause toggle
- **D-Pad**: Standard joystick movement

**Note**: TH line toggling is not used. Buttons B/C are reliably read on INPT4/5 and INPT0/2 respectively.

**Note**: Enhanced controllers (Genesis/Joy2B+) limited to 2-player mode.

## Coding Conventions

### Variable Naming
- **Built-ins**: `lowercase` (`temp1`, `joy0fire`, `player0x`) 
- **User variables**: `camelCase` (`playerX`, `gameState`, `missileActive`)
- **Constants**: `PascalCase` (`MaxCharacter`, `KnockbackDistance`)
- **Enums**: `PascalCase` (`AnimStanding`, `ModeGame`)
- **Labels/Routines**: `PascalCase` (`LoadCharacterSprite`, `HandleInput`)

### Memory Layout
- **Standard RAM**: `a`-`z` (26 bytes)
- **SuperChip RAM**: `var0`-`var95` (96 bytes) 
- **Player Arrays**: `var0`-`var27` (28 bytes used)
- **Available**: `var28`-`var95` (68 bytes free)

## Architecture

### Mode Organization
The game uses two main execution contexts:
- **Admin Mode** - Title screen, preambles (publisher/author), level select screens
- **Game Mode** - Character select, falling animation, gameplay, winner announcement
- **Common Vars** - Variables shared between Admin Mode and Game Mode

### Bank Organization (64KB Cartridge)
- **Bank 1**: Core systems, controller detection, main loop, titlescreen kernel
- **Bank 2**: Level data, character graphics (TV-specific)
- **Bank 5**: Character selection system
- **Banks 6-16**: Game systems (missiles, physics, combat, rendering)

### Key Systems
```
MissileSystem.bas      - Projectile lifecycle management
MissileCollision.bas   - AABB and AOE collision detection  
FallDamage.bas         - Weight-based physics and damage
CharacterDefinitions.bas - Property lookups (O(1) via on-goto)
ControllerDetection.bas - Multi-controller auto-detection
```

## Development Environment Setup

### Required Tools
```bash
# Core development (Fedora/RHEL)
sudo dnf install gcc make gimp sbcl texlive texinfo

# Common Lisp (for SkylineTool)  
curl -O https://beta.quicklisp.org/quicklisp.lisp
sbcl --load quicklisp.lisp

# Install GIMP export script
make gimp-export
```

### Asset Pipeline Dependencies
- **GIMP** with batch processing capability for XCF→PNG conversion
- **MuseScore** (optional) for MSCZ→MIDI conversion
- **SkylineTool** (included) for asset compilation (sprites, fonts, music, bitmaps)
- **batariBASIC** compiler (included)

### Asset Pipeline

The asset pipeline converts source artwork into batariBASIC-compatible data files:

**Character Sprites** (64×256px PNG, 8 frames × 16 poses):
1. Source: `Source/Art/CharacterName.xcf` (GIMP format)
2. Export: `Source/Art/CharacterName.png` (via GIMP batch script)
3. Compile: `Source/Generated/CharacterName.bas` (via `skyline-tool compile-chaos-character`)
   - Generates `data CharacterNameFrames` with deduplicated sprite frames
   - Generates `data CharacterNameFrameMap` with indirection table
   - Assembly code references `CharacterNameFrames` labels in `CharacterArtBank*.s`

**Pipeline Process:**
```bash
# XCF → PNG (automatic via Makefile if XCF is newer)
make Source/Art/CharacterName.png

# PNG → batariBASIC (automatic via Makefile)
make Source/Generated/CharacterName.bas

# Generate all character sprites
make characters
```

**Character Bank Organization:**
- Bank 2: Characters 0-7 (Bernie, Curler, DragonOfStorms, ZoeRyen, FatTony, Megax, Harpy, KnightGuy)
- Bank 3: Characters 8-15 (Frooty, Nefertem, NinjishGuy, PorkChop, RadishGoblin, RoboTito, Ursulo, Shamone)
- Bank 4: Characters 16-23 (Character16-23 placeholders)
- Bank 5: Characters 24-31 (Character24-30, MethHound)

**Sprite Loading:**
- `LoadCharacterSprite` in `SpriteLoader.bas` dispatches to bank-specific routines
- `LocateCharacterArt` calculates sprite address from action (0-15) and frame (0-7)
- Assembly routines (`CharacterArtBank*.s`) set player sprite pointers using generated data
- All sprites use compiled data from generated `.bas` files (no hardcoded placeholders)

**Special Sprites:**
- QuestionMark, CPU, and No sprites are hardcoded in `Source/Data/SpecialSprites.bas`
- Used for character selection placeholders (unselected, CPU player, random)

## Project Status

**Current State**: Actively in development with core systems implemented.

✅ **Complete**: Game logic, physics, controllers, character system, collision detection  
🔨 **In Progress**: Asset pipeline, arena design, character animations, Milestone 1 completion  
📋 **Planned**: Additional arenas, character mechanics, performance optimizations

### Milestone 1 Progress
- ✅ Fixed critical build errors: duplicate BeginGameLoop call (#580), rem comment syntax (#579)
- ✅ Verified hotspot configuration (#544) and missile systems (#416-422)
- ✅ Broke down complex issues into actionable sub-issues (#431, #429, #434)
- ✅ Code review complete for all missile implementations
- ✅ Character sprite generation complete (#218): All 32 characters have generated sprite files

### Recent Improvements
- Fixed syntax errors and code quality issues (#352, #305, #325, #580, #579)
- Standardized naming conventions (Arena vs Level terminology)
- Replaced magic numbers with symbolic constants (#292, #314)
- Improved collision detection and player separation (#255)
- Fixed health bar rendering for B&W and color modes (#250)
- Cleaned up unused Titlescreen files (#333)

See GitHub Issues for detailed tracking of remaining work.

---

**ChaosFight** - Advanced 4-player combat for Atari 2600  
© 2025 Interworldly Adventuring, LLC
