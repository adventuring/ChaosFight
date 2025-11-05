# ChaosFight Coding Style Guide

**Version**: 1.0  
**Last Updated**: 2025  
**Copyright © 2025 Interworldly Adventuring, LLC.**

This document defines the coding standards for the ChaosFight project. All code must conform to these standards to ensure consistency, maintainability, and clarity.

---

## Table of Contents

1. [Naming Conventions](#naming-conventions)
2. [Variable Assignments](#variable-assignments)
3. [Subroutine Communication](#subroutine-communication)
4. [Documentation](#documentation)
5. [File Organization](#file-organization)
6. [Memory Management](#memory-management)
7. [Indentation](#indentation)
8. [Includes](#includes)
9. [Control Flow](#control-flow)
10. [Code Review Checklist](#code-review-checklist)

---

## Naming Conventions

### PascalCase

Use **PascalCase** for:
- **Labels/Routines**: `LoadCharacterSprite`, `ApplyDamage`, `CheckPlayerElimination`
- **Constants**: `MaxCharacter`, `RandomArena`, `ColIndigo(14)`
- **Enums**: `ActionStanding`, `ActionWalking`, `ModeGame`, `ModeCharacterSelect`

**Examples:**
```basic
LoadCharacterSprite
          rem Load sprite data for a character
          rem Input: temp1 = character index, temp2 = animation frame
          rem Output: Sprite data loaded into appropriate player register

const MaxCharacter = 15
const RandomArena = 255
```

### camelCase

Use **camelCase** for:
- **Zero-page variables** (standard RAM): `gameState`, `playerX`, `selectedChar1`, `playerHealth`
- **Built-in variables**: `temp1`, `temp2`, `qtcontroller`, `frame` (already lowercase)

**Examples:**
```basic
dim gameState = g
dim playerX = var0
dim selectedChar1 = s
```

### camelCase_R and camelCase_W

Use **camelCase_R** and **camelCase_W** suffixes for:
- **SCRAM (SuperChip RAM) variables**: Separate read and write ports

**CRITICAL**: SCRAM variables have separate read (`r000`-`r127`) and write (`w000`-`w127`) ports that map to the same physical 128-byte RAM. All SCRAM variable declarations **MUST** include both `_R` and `_W` variants.

**Examples:**
```basic
dim selectedArena_W = w014
dim selectedArena_R = r014
```

**Forbidden:**
```basic
dim selectedArena = w014  ; "Convenience alias" not acceptable
dim selectedArena = w014  ; ERROR: Missing _R/_W variants
```

**Rationale**: SCRAM has separate read/write ports. Using convenience aliases without explicit `_R`/`_W` makes it unclear which port is accessed, which can lead to bugs where writes are attempted via read ports or reads via write ports.

### Subroutine-Local Variables

Use **XX_varName** pattern for subroutine-local temporary variables:
- Prefix with subroutine initials (2-4 letters) followed by underscore
- Use camelCase for the variable name portion

**Examples:**
```basic
LoadCharacterSprite
          dim LCS_characterIndex = temp1
          dim LCS_animationFrame = temp2
          dim LCS_playerNumber = temp3

ApplyDamage
          dim AD_attackerID = attackerID
          dim AD_defenderID = defenderID
          dim AD_damage = temp1
```

**Pattern**: `[SubroutineInitials]_[descriptiveName]`

---

## Variable Assignments

### Built-in Variables

**DO NOT** use `LET` for built-in batariBASIC variables:
- TIA registers: `player0x`, `player0y`, `COLUP0`, `NUSIZ0`, `pf0`-`pf11`, `VBLANK`, etc.
- Built-in variables: `temp1`-`temp6`, `frame`, `qtcontroller`
- Hardware registers: `joy0up`, `joy0down`, `joy0fire`, `INPT0`, etc.

**Correct:**
```basic
player0x = 56
player0y = 40
COLUP0 = ColBlue(14)
VBLANK = VBlankGroundINPT0123
temp2 = 0
frame = 0
```

### User-Defined Variables

**MUST** use `LET` statement for all user-defined variable assignments:
- Game state: `gameState`, `playerHealth[]`, `selectedArena`, etc.
- Temporary calculations: All intermediate values
- Arrays and tables: Any user-defined data structures

**Correct:**
```basic
let selectedArena = selectedArena - 1
let gameState = 1
let playerHealth[0] = PlayerHealthMax
let colorBWOverride = colorBWOverride ^ 1
```

**Incorrect:**
```basic
selectedArena = selectedArena - 1  ; ERROR: Missing let
gameState = 1  ; ERROR: Missing let
```

**Note**: All batariBASIC keywords (`let`, `goto`, `gosub`, `dim`, `if`, `then`, `return`, `rem`, `asm`, `end`, `data`, `const`) must be lowercase.

**Rationale**: The `LET` keyword distinguishes user-defined variables from built-in system variables, improving code clarity and making assignments explicit.

---

## Subroutine Communication

### Global Variables and Temps

Subroutines communicate via:
- **Global variables**: Shared state (e.g., `playerX[]`, `playerHealth[]`, `gameState`)
- **temp1-temp6**: Temporary storage for parameter passing and scratch space

Can also use "static" subroutine-specific variables with global extent.

**Examples:**
```basic
rem Input: temp1 = character index, temp2 = animation frame
rem        temp3 = player number
LoadCharacterSprite
          dim LCS_characterIndex = temp1
          dim LCS_animationFrame = temp2
          dim LCS_playerNumber = temp3
          rem ... subroutine body ...
          return
```

### Subroutine-Local Variables

Subroutine-local temporary variables should be:
- **Dimmed** at the start of the subroutine
- **Namespaced** with subroutine initials (abbreviations): `XX_varName`
- **Mapped** to `temp1`-`temp6` or other appropriate variables

**Important**: Use **abbreviated routine names** (2-4 letters) as prefixes, not full routine names. This keeps variable names concise and readable.

**Example:**
```basic
SpawnMissile
          dim SM_playerIndex = temp1
          dim SM_facing = temp4
          dim SM_characterType = temp5
          dim SM_bitFlag = temp6
          rem ... subroutine body ...
          return

UpdatePlayerAnimation
          dim UPA_animCounterRead = temp4
          dim UPA_animFrameRead = temp2
          rem ... subroutine body ...
          return
```

**Pattern**: `[RoutineAbbreviation]_[descriptiveName]`
- ✅ `UPA_animCounterRead` (UpdatePlayerAnimation → UPA)
- ❌ `UpdatePlayerAnimation_animCounterRead` (too verbose)

---

## Documentation

### Remark Length

**All remarks/comments MUST NOT exceed 72 columns** for readability, consistency, and compatibility with various display formats.

**Examples:**
```basic
rem This is a short remark that fits within 72 columns

rem This remark is too long and extends beyond the 72-column limit
rem   and should be split across multiple lines
```

### Subroutine Documentation

Every subroutine **MUST** have documentation comments immediately after the label describing:
- **Input**: Parameters (via temp variables or globals)
- **Output**: Return values or side effects
- **Side Effects**: Any global state modifications

**Format:**
```basic
LoadCharacterSprite
          rem Load sprite data for a character based on character index
          rem Input: temp1 = character index (0-31), temp2 = animation frame (0-7)
          rem        temp3 = player number (0-3)
          rem Output: Sprite data loaded into appropriate player register
          rem Side Effects: Updates player0-3pointerlo/hi and player0-3height
          dim LCS_characterIndex = temp1
          rem ... implementation ...
```

**Minimal acceptable format:**
```basic
ApplyDamage
          rem Apply damage from attacker to defender
          rem Input: attackerID, defenderID (must be set before calling)
          rem Output: Damage applied, recovery frames set, health decremented
```

### File Headers

All source files should begin with:
```basic
rem ChaosFight - Source/Path/To/File.bas
rem Copyright © 2025 Interworldly Adventuring, LLC.
```

---

## File Organization

### File Size and Structure

- **Break down files into manageable sizes**
- **Ideally one subroutine per file** for very large or frequently-modified subroutines
- **Group related subroutines** in the same file when they are tightly coupled (e.g., `SpriteLoader.bas` contains multiple sprite loading functions)
- **Inline very small subroutines** directly into calling code when appropriate

**Acceptable grouping examples:**
- `SpriteLoader.bas`: Contains multiple sprite loading functions (`LoadCharacterSprite`, `LoadSpecialSprite`, `LoadPlayerSprite`, etc.) - all related to sprite loading
- `MissileSystem.bas`: Contains missile management functions (`SpawnMissile`, `UpdateMissiles`, `DeactivateMissile`) - all related to missile system

**Split when:**
- File exceeds ~500 lines
- Subroutines are independent and may be modified separately
- Subroutines are in different banks

### File Naming

- Use **PascalCase** for file names: `SpriteLoader.bas`, `MissileSystem.bas`
- Match file name to primary subroutine or functionality: `LoadArena.bas` for `LoadArena` subroutine

---

## Memory Management

### Zero-Page (Standard RAM)

Use **zero-page variables** (standard RAM: `var0`-`var47`, `a`-`z`) for:
- **Variables accessed every frame**: Physics variables, player positions, game state
- **Performance-critical data**: Variables used in tight loops or hot paths

**Examples:**
```basic
dim playerX = var0          ; Accessed every frame for rendering
dim playerVelocityX = var20  ; Accessed every frame for physics
dim gameState = g           ; Accessed every frame for state machine
```

### SCRAM (SuperChip RAM)

Use **SCRAM variables** (`r000`-`r127`/`w000`-`w127`) for:
- **Less-frequently-accessed variables**: Animation counters (updated at 10fps, not 60fps), elimination timers, music state
- **Low-frequency data**: Variables accessed only on specific screens or events

**Examples:**
```basic
dim animationCounter_W = w077  ; Updated at 10fps, not every frame
dim winScreenTimer_W = w044    ; Only accessed on winner screen
dim selectedArena_W = w014     ; Only accessed during arena select
```

**Rationale**: Zero-page access is faster (2 bytes, 3 cycles) than SCRAM access (3 bytes, 4-5 cycles). Reserve zero-page for variables accessed every frame.

### No Redimming

**DO NOT** "redim" variables (reuse the same memory location for different purposes) except:
- **Admin Mode vs Game Mode**: Variables can be redimmed between these two contexts (documented in `Variables.bas`)
- **Example**: `var24`-`var27` used for arena select in Admin Mode, `playerVelocityX_lo` in Game Mode

**Forbidden:**
```basic
dim temp1 = var10  ; Used for player index
dim temp2 = var10  ; ERROR: Redim in same context
```

---

## Indentation

### Code Blocks

Use **exactly 10 spaces** for indentation of code blocks within subroutines.

**Correct:**
```basic
LoadCharacterSprite
          dim LCS_characterIndex = temp1
          dim LCS_animationFrame = temp2
          if LCS_characterIndex = 255 then goto LoadSpecialSprite
          rem ... more code ...
          return
```

**Incorrect:**
```basic
LoadCharacterSprite
         dim LCS_characterIndex = temp1  ; ERROR: Only 9 spaces
          dim LCS_animationFrame = temp2
```

### Labels and First Lines

- **Labels** (subroutine names) start at column 0 (no indentation)
- **First line after label** (typically `rem` or `dim`) uses 10 spaces
- **Remarks** within code blocks use 10 spaces

**Example:**
```basic
LoadCharacterSprite
          rem Load sprite data for a character
          dim LCS_characterIndex = temp1
          if LCS_characterIndex = 255 then goto LoadSpecialSprite
          rem Normal character loading
          return
```

---

## Includes

### batariBASIC Files (.bas, .h)

Use **`#include`** (C-style preprocessor) for batariBASIC source files:

```basic
#include "Source/Common/Constants.bas"
#include "Source/Common/Variables.bas"
#include "Source/Common/Colors.h"
```

### Assembly Files (.s)

Use **`include`** (assembly directive) for assembly source files, wrapped in `asm` blocks:

```basic
asm
include "Source/Generated/Art.AtariAge.s"
include "Source/Routines/CharacterArtBank2.s"
end
```

### batariBASIC Include Files (.inc)

Use **`includesfile`** (batariBASIC directive) for batariBASIC include files:

```basic
includesfile multisprite_superchip.inc
```

### Summary

| File Type | Directive | Example |
|-----------|-----------|---------|
| `.bas`, `.h` | `#include` | `#include "Source/Common/Constants.bas"` |
| `.s` | `include` (in `asm` block) | `asm`<br>`include "file.s"`<br>`end` |
| `.inc` | `includesfile` | `includesfile multisprite_superchip.inc` |

---

## Control Flow

### IF/THEN Statements

batariBASIC uses **line-based IF/THEN**, not block syntax. All IF/THEN statements must be single-line commands.

**Correct:**
```basic
if selectedArena = RandomArena then DisplayRandomArena
if joy0fire then ArenaSelectConfirm
if !LCS_isValid then goto LoadSpecialSprite
```

**Incorrect (block syntax):**
```basic
if selectedArena = RandomArena then
    DisplayRandomArena
    rem More code
end if
```

### Tail Call Optimization

When a subroutine ends with `gosub` immediately followed by `return`, optimize to a tail call using `goto`:

**Before (inefficient):**
```basic
LoadPlayer0Sprite
          gosub LoadCharacterSprite
          return
```

**After (optimized):**
```basic
LoadPlayer0Sprite
          rem tail call
          goto LoadCharacterSprite
```

**Rationale**: Tail calls don't push the current function onto the call stack. The target function can return directly to the original caller, saving stack space and improving performance on the 6502 processor.

---

## Code Review Checklist

When reviewing code, check for:

### ✅ Naming Conventions
- [ ] Labels use PascalCase
- [ ] Constants use PascalCase
- [ ] Variables use camelCase
- [ ] SCRAM variables have both `_R` and `_W` variants
- [ ] Subroutine-local variables use `XX_varName` pattern

### ✅ Variable Assignments
- [ ] User-defined variables use `LET` statement
- [ ] Built-in variables do NOT use `LET` (use `=` directly)
- [ ] No assignments to built-in variables with `LET`

### ✅ Documentation
- [ ] All subroutines have documentation comments
- [ ] Documentation describes input, output, and side effects
- [ ] File headers include copyright notice

### ✅ Memory Management
- [ ] Zero-page variables are used for frequently-accessed data
- [ ] SCRAM variables are used for less-frequently-accessed data
- [ ] No inappropriate redimming (except admin vs game mode)

### ✅ Indentation
- [ ] Code blocks use exactly 10 spaces
- [ ] Labels start at column 0
- [ ] Consistent indentation throughout file

### ✅ Includes
- [ ] `.bas`/`.h` files use `#include`
- [ ] `.s` files use `include` in `asm` blocks
- [ ] `.inc` files use `includesfile`

### ✅ Control Flow
- [ ] IF/THEN statements are line-based (not blocks)
- [ ] Tail calls optimized where appropriate

---

## Examples

### Complete Subroutine Example

```basic
          rem ChaosFight - Source/Routines/Example.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem =================================================================
          rem EXAMPLE SUBROUTINE
          rem =================================================================

          rem Process player input and update game state
          rem Input: temp1 = player index (0-3)
          rem        temp2 = input flags (bit-packed)
          rem Output: Player state updated based on input
          rem Side Effects: Modifies playerState[], playerX[], playerY[]
ProcessPlayerInput
          dim PPI_playerIndex = temp1
          dim PPI_inputFlags = temp2
          dim PPI_isMoving = temp3
          
          rem Check if player is moving
          LET PPI_isMoving = PPI_inputFlags & InputFlagLeft
          if PPI_isMoving then UpdatePlayerMovement
          
          rem Check if player is jumping
          if PPI_inputFlags & InputFlagUp then UpdatePlayerJump
          
          return

UpdatePlayerMovement
          rem Update player horizontal position
          rem Input: temp1 = player index (already set)
          rem Output: playerX[] updated
          dim UPM_playerIndex = temp1
          LET playerX[UPM_playerIndex] = playerX[UPM_playerIndex] + 1
          return

UpdatePlayerJump
          rem Update player vertical position for jump
          rem Input: temp1 = player index (already set)
          rem Output: playerY[] updated, playerState[] jump flag set
          dim UPJ_playerIndex = temp1
          LET playerY[UPJ_playerIndex] = playerY[UPJ_playerIndex] - 4
          LET playerState[UPJ_playerIndex] = playerState[UPJ_playerIndex] | PlayerStateJumping
          return
```

---

## Questions and Clarifications

If you have questions about these standards or encounter edge cases not covered here:

1. **Check Requirements.md** for project-specific requirements
2. **Review existing code** for consistent patterns
3. **Ask the project maintainer** for clarification on ambiguous cases

---

## Version History

- **1.0** (2025): Initial style guide creation based on code review and Requirements.md

---

**End of Style Guide**

