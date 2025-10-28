# ChaosFight 🎮

A sophisticated 4-player fighting game for the Atari 2600, featuring 16 unique characters with distinct abilities and advanced physics.

## Features

### ✅ Working Systems
- **4-Player Simultaneous Combat** - Advanced Quadtari support with frame multiplexing  
- **16 Unique Characters** - Each with custom weights, abilities, and attack types
- **Advanced Physics** - Gravity, momentum, fall damage with character-specific mechanics
- **Enhanced Controller Support** - CX-40, Genesis 3-button, Joy2B+, Quadtari
- **Collision Detection** - AABB missiles, AOE attacks, playfield boundaries
- **Special Abilities** - Flight (Magical Faerie), immunity (Bernie/RoboTito), reduced gravity (Harpy/Dragonet)
- **Memory Optimization** - SuperChip RAM with 96 variables during gameplay
- **Professional Architecture** - Modular design, data-driven character system

### 🎮 Characters & Combat
**Ranged Fighters** (projectile attacks): Bernie, CurlingSweeper, Dragonet, EXOPilot, MagicalFaerie, Ursulo  
**Melee Fighters** (AOE attacks): FatTony, GrizzardHandler, Harpy, KnightGuy, MysteryMan, NinjishGuy, PorkChop, RadishGoblin, RoboTito, VegDog

**Special Mechanics**:
- **Weight Classes**: Light (10-15) to Heavy (30-35) affecting jump height and fall damage
- **Handicapping System**: Hold DOWN+FIRE during character select for 25% health reduction
- **Fall Damage**: Weight-based calculation with character immunities
- **Recovery System**: Hitstun and momentum effects

## Building & Setup

### Requirements
- **batariBASIC** compiler (included in Tools/)
- **DASM** assembler (included)
- **SBCL** + Common Lisp libraries (for asset generation)
- **ImageMagick** (for XCF→PNG conversion)
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
- `Dist/ChaosFight.NTSC.a26` - NTSC ROM (64KB)
- `Dist/ChaosFight.PAL.a26` - PAL ROM  
- `Dist/ChaosFight.SECAM.a26` - SECAM ROM
- `Dist/ChaosFight-Manual.pdf` - Game manual

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
Automatically detected via frame multiplexing. Players 3&4 use same controls as 1&2.

**Note**: Enhanced controllers (Genesis/Joy2B+) limited to 2-player mode.

## Coding Conventions

### Variable Naming
- **Built-ins**: `lowercase` (`temp1`, `joy0fire`, `player0x`) 
- **User code**: `PascalCase` (`PlayerX`, `GameState`, `MissileActive`)

### Memory Layout
- **Standard RAM**: `a`-`z` (26 bytes)
- **SuperChip RAM**: `var0`-`var95` (96 bytes) 
- **Player Arrays**: `var0`-`var27` (28 bytes used)
- **Available**: `var28`-`var95` (68 bytes free)

## Architecture

### Bank Organization (64KB Cartridge)
- **Bank 1**: Core systems, controller detection, main loop
- **Bank 2**: Level data, character graphics (TV-specific)
- **Bank 5**: Character selection system
- **Banks 6-16**: Game systems (missiles, physics, combat)

### Key Systems
```
MissileSystem.bas      - Projectile lifecycle management
MissileCollision.bas   - AABB and AOE collision detection  
FallDamage.bas         - Weight-based physics and damage
CharacterData.bas      - Property lookups (O(1) via on-goto)
ControllerDetection.bas - Multi-controller auto-detection
```

## Project Status

**Current State**: ~80% complete with solid foundations but **asset compilation blocking playable builds**.

✅ **Complete**: Game logic, physics, controllers, documentation  
❌ **Blocking**: Character sprite generation, level graphics, SkylineTool compilation

See `STATUS.md` for detailed implementation status and remaining work.

---

**ChaosFight** - Advanced 4-player combat for Atari 2600  
© 2025 Interworldly Adventuring, LLC
