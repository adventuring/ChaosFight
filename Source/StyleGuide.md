<!-- markdownlint-disable-file MD013 -->
# ChaosFight Coding Style Guide

**Version**: 1.0
**Last Updated**: 2025
**Copyright (c) 2025 Interworldly Adventuring, LLC.**

This document defines the coding standards for the ChaosFight project.
All code must conform to these standards to ensure consistency,
maintainability, and clarity.

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

- **Labels/Routines**: `LoadCharacterSprite`, `ApplyDamage`,
  `CheckPlayerElimination`
- **Constants**: `MaxCharacter`, `RandomArena`, `ColIndigo(14)`
- **Enums**: `ActionStanding`, `ActionWalking`, `ModeGame`,
  `ModeCharacterSelect`

**Examples:**

```basic
LoadCharacterSprite
          rem Load sprite data for a character
          rem Input: temp1 = character index, temp2 = animation frame
          rem Output: Sprite data loaded into appropriate player
          rem register

const MaxCharacter = 15
const RandomArena = 255
```

### Abbreviations

**DO NOT use abbreviations** in names except for subroutine-local
variable prefixes (see [Subroutine-Local Variables](#subroutine-local-
variables) below).

**Forbidden:**

```basic
const SpritePtr = 0          ; Use: SpritePointer
CharacterSpritePtrLoBank2    ; Use: CharacterSpriteBank2L
CharacterSpritePtrHiBank2    ; Use: CharacterSpriteBank2H
```

**Rationale**: Abbreviations reduce clarity and make code harder to
understand. Fully spelled names are more readable and self-documenting.

### High/Low Byte Suffixes

When using pairs of tables or variables for high-byte/low-byte values,
use a final **`H`** or **`L`** to distinguish them.

**Correct:**

```basic
CharacterSpriteBank2L        ; Low byte table
CharacterSpriteBank2H        ; High byte table
SongPointers1L               ; Low byte lookup table
SongPointers1H               ; High byte lookup table
```

**Forbidden:**

```basic
CharacterSpriteLBank2        ; "L" is not final
CharacterSpriteLoBank2       ; Never use "Lo" for "low"
CharacterSpriteHiBank2       ; Never use "Hi" for "high"
CharacterSpritePtrLoBank2    ; Redundant "Ptr" + wrong suffix
CharacterSpritePtrHiBank2    ; Redundant "Ptr" + wrong suffix
```

**Note**: `H`/`L` as the final character of a variable name is
acceptable, but never use "Hi" for "high" or "Lo" for "low" as separate
words.

### 16-bit Variables

Declare every 16-bit variable with batariBASIC’s dot syntax so the low and
high bytes share a single symbolic name:

```basic
dim songPointer = var39.var40
dim musicVoice0StartPointer_W = w067.w068
dim soundPointer = y.z
```

Do **not** create separate variables for the low and high bytes of the same
16-bit value. Use 16-bit arithmetic (`let songPointer = songPointer + 4`)
instead of manual carry propagation.

### camelCase

Use **camelCase** for:

- **Zero-page variables** (standard RAM): `gameState`, `playerX`,
  `playerCharacter[0]`, `playerHealth`
- **Built-in variables**: `temp1`, `temp2`, `qtcontroller`, `frame`
  (already lowercase)

**Examples:**

```basic
dim gameState = g
dim playerX = var0
dim playerCharacter = j
```

### camelCase_R and camelCase_W

Use **camelCase_R** and **camelCase_W** suffixes for:

- **SCRAM (SuperChip RAM) variables**: Separate read and write ports

**CRITICAL**: SCRAM variables have separate read (`r000`-`r127`) and
write (`w000`-`w127`) ports that map to the same physical 128-byte RAM.
All SCRAM variable declarations **MUST** include both `_R` and `_W`
variants.

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

**Rationale**: SCRAM has separate read/write ports. Using convenience
aliases without explicit `_R`/`_W` makes it unclear which port is
accessed, which can lead to bugs where writes are attempted via read
ports or reads via write ports.

---

## Variable Assignments

### Built-in Variables

**DO NOT** use `let` for hardware register shadow variables:

- TIA registers: `player0x`, `player0y`, `COLUP0`, `NUSIZ0`,
  `pf0`-`pf11`, `VBLANK`, etc.
- Hardware registers: `joy0up`, `joy0down`, `joy0fire`, `INPT0`, etc.
- Kernel control registers exposed as variables (`switchbw`, `rand`, etc.)
  that the batariBASIC runtime treats as device or kernel state.

**Correct:**

```basic
player0x = 56
player0y = 40
COLUP0 = ColBlue(14)
VBLANK = VBlankGroundINPT0123
frame = 0
qtcontroller = 0
```

### User-Defined Variables

**MUST** use `LET` statement for all user-defined variable assignments:

- Game state: `gameState`, `playerHealth[]`, `selectedArena`, etc.
- Temporary calculations: All intermediate values (including `temp1`-`temp6`)
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

**Note**: All batariBASIC keywords (`let`, `goto`, `gosub`, `dim`, `if`,
`then`, `return`, `rem`, `asm`, `end`, `data`, `const`) must be
lowercase.

**Rationale**: The `LET` keyword distinguishes user-defined variables
from built-in system variables, improving code clarity and making
assignments explicit.

---

## Subroutine Communication

### Global Variables and Temps

Subroutines communicate via:

- **Global variables**: Shared state (e.g., `playerX[]`,
  `playerHealth[]`, `gameState`)
- **temp1-temp6**: Temporary storage for parameter passing and scratch
  space

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

**Important**: Use **abbreviated routine names** (2-4 letters) as
prefixes, not full routine names. This keeps variable names concise and
readable.

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
          dim UPA_animationCounterRead = temp4
          dim UPA_animationFrameRead = temp2
          rem ... subroutine body ...
          return
```

**Pattern**: `[RoutineAbbreviation]_[descriptiveName]`

- ✅ `UPA_animationCounterRead` (UpdatePlayerAnimation → UPA)

**Note**: This is the **only exception** to the "no abbreviations" rule.
Subroutine-local variable prefixes may use abbreviations to keep names
manageable, but all other names (labels, constants, global variables,
etc.) must use full words.

**CRITICAL - Cross-Bank Access**: Variables with numeric prefixes
(subroutine-local variables using the `XX_varName` pattern) are **local
to their bank** and **will NOT be available cross-bank at all without a
separate label for it**. If a subroutine needs to access a local
variable from another bank, that variable must be exposed via a separate
label or passed through global variables (`temp1`-`temp6` or other
globals).

---

## Documentation

### Apostrophes in Remarks

**MUST use right single quotes (`'`) instead of straight apostrophes
(`'`) in `rem` comments** - the C preprocessor (`cpp`) treats straight
apostrophes as string delimiters, causing compilation warnings. Right
single quotes are typographically correct and do not trigger
preprocessor warnings.

**Correct:**

```basic
rem Check for negative velocity using two's complement
rem It's important to note that this uses two's complement
rem The player won't move if velocity is zero
rem Other screens' minikernels should have window=0
rem Character's weight affects fall damage
```

**Incorrect:**

```basic
rem Check for negative velocity using two's complement  ; Wrong:
rem straight apostrophe causes cpp warnings
rem It's important to note that this uses two's complement  ; Wrong:
rem straight apostrophe causes cpp warnings
rem The player won't move if velocity is zero  ; Wrong: straight
rem apostrophe causes cpp warnings
rem Other screens' minikernels should have window=0  ; Wrong: straight
rem apostrophe causes cpp warnings
```

**Rationale**: The C preprocessor parses all comments and treats
straight apostrophes (`'`) as potential string delimiters, causing
compilation warnings. Right single quotes (`'`, U+2019) are the
typographically correct character for apostrophes in English text and do
not trigger preprocessor warnings. Always use right single quotes for
contractions and possessives in remarks.

### Remark Length

**All remarks/comments MUST NOT exceed 72 columns** for readability,
consistency, and compatibility with various display formats.

**Examples:**

```basic
rem This is a short remark that fits within 72 columns

rem This remark is too long and extends beyond the 72-column limit
rem   and should be split across multiple lines
```

### Subroutine Documentation

Every subroutine **MUST** place its documentation comments **immediately
after the label**. The label comes first on column 0, followed directly
by the documentation block. Within the documentation block, insert a
blank remark line (`rem` with no trailing text) between major sections
to improve readability.

Every documentation block **MUST** describe:

- **Input**: Parameters (via temp variables or globals), including all
  variables read
- **Output**: Return values or state changes
- **Mutates**: All variables modified, including `temp1`-`temp6` when
  modified
- **Called Routines**: Subroutines called and their variable access
- **Constraints**: Colocation requirements, cross-bank access
  limitations, entry point status

**Format:**

```basic
LoadCharacterSprite
          rem Load sprite data for a character based on character index
          rem
          rem Input: temp1 = character index (0-31), temp2 = animation
          rem frame (0-7)
          rem        temp3 = player number (0-3)
          rem        playerCharacter[] (global array) = player character
          rem        selections
          rem
          rem Output: Sprite data loaded into appropriate player
          rem register
          rem
          rem Mutates: temp1-temp3 (used for calculations), player
          rem sprite pointers
          rem
          rem Called Routines: LoadSpecialSprite - accesses temp1,
          rem playerCharacter[]
          rem
          rem Constraints: Must be colocated with LoadSpecialSprite
          rem (called via goto)
          dim LCS_characterIndex = temp1
          rem ... implementation ...
```

**Minimal acceptable format:**

```basic
ApplyDamage
          rem Apply damage from attacker to defender
          rem
          rem Input: attackerID (global), defenderID (global),
          rem        playerCharacter[] (global array)
          rem
          rem Output: Damage applied, recovery frames set, health
          rem decremented
          rem
          rem Mutates: temp1-temp4 (used for calculations),
          rem playerHealth[], playerRecoveryFrames[]
          rem
          rem Called Routines: GetCharacterDamage (bank6),
          rem SetPlayerAnimation (bank11), CheckPlayerElimination,
          rem PlayDamageSound
          rem
          rem Constraints: None
```

**CRITICAL - Cross-Bank Variable Access**: When documenting subroutines,
note that variables with numeric prefixes (subroutine-local variables
using the `XX_varName` pattern) are **local to their bank** and **will
NOT be available cross-bank at all without a separate label for it**.
Document this in the **Constraints** section if a subroutine uses local
variables that might need cross-bank access.

### File Headers

All source files should begin with:

```basic
          rem ChaosFight - Source/Path/To/File.bas
          rem Copyright (c) 2025 Interworldly Adventuring, LLC.
```

---

## File Organization

### File Size and Structure

- **Break down files into manageable sizes**
- **Ideally one subroutine per file** for very large or frequently-
  modified subroutines
- **Group related subroutines** in the same file when they are tightly
  coupled (e.g., `SpriteLoader.bas` contains multiple sprite loading
  functions)
- **Inline very small subroutines** directly into calling code when
  appropriate

**Acceptable grouping examples:**

- `SpriteLoader.bas`: Contains multiple sprite loading functions
  (`LoadCharacterSprite`, `LoadSpecialSprite`, `LoadPlayerSprite`, etc.)
  - all related to sprite loading
- `MissileSystem.bas`: Contains missile management functions
  (`SpawnMissile`, `UpdateMissiles`, `DeactivateMissile`) - all related
  to missile system

**Split when:**

- File exceeds ~500 lines
- Subroutines are independent and may be modified separately
- Subroutines are in different banks

### File Naming

- Use **PascalCase** for file names: `SpriteLoader.bas`,
  `MissileSystem.bas`
- Match file name to primary subroutine or functionality:
  `LoadArena.bas` for `LoadArena` subroutine

---

## Memory Management

### Zero-Page (Standard RAM)

Use **zero-page variables** (standard RAM: `var0`-`var47`, `a`-`z`) for:

- **Variables accessed every frame**: Physics variables, player
  positions, game state
- **Performance-critical data**: Variables used in tight loops or hot
  paths

**Examples:**

```basic
dim playerX = var0          ; Accessed every frame for rendering
dim playerVelocityX = var20  ; Accessed every frame for physics
dim gameState = g           ; Accessed every frame for state machine
```

### SCRAM (SuperChip RAM)

Use **SCRAM variables** (`r000`-`r127`/`w000`-`w127`) for:

- **Less-frequently-accessed variables**: Animation counters (updated at
  10fps, not 60fps), elimination timers, music state
- **Low-frequency data**: Variables accessed only on specific screens or
  events

**Examples:**

```basic
dim animationCounter_W = w077  ; Updated at 10fps, not every frame
dim winScreenTimer_W = w044    ; Only accessed on winner screen
dim selectedArena_W = w014     ; Only accessed during arena select
```

**Rationale**: Zero-page access is faster (2 bytes, 3 cycles) than SCRAM
access (3 bytes, 4-5 cycles). Reserve zero-page for variables accessed
every frame.

### No Redimming

**DO NOT** "redim" variables (reuse the same memory location for
different purposes) except:

- **Admin Mode vs Game Mode**: Variables can be redimmed between these
  two contexts (documented in `Variables.bas`)
- **Example**: `var24`-`var27` used for arena select in Admin Mode,
  `playerVelocityXL` in Game Mode

**Forbidden:**

```basic
dim temp1 = var10  ; Used for player index
dim temp2 = var10  ; ERROR: Redim in same context
```

---

## Indentation

### Code Blocks

Use **at least 10 spaces** for indentation of code blocks within
subroutines.

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
- **Remarks** use 10 spaces

**Example:**

```basic
LoadCharacterSprite
          rem Load sprite data for a character
          dim LCS_characterIndex = temp1
          if LCS_characterIndex = 255 then goto LoadSpecialSprite
          rem Normal character loading
          return
```

### Additional indentation

- Block-level code elements like **data**, **playfield**, **asm**
  are indented on their first line to the current level (typically 10
  spaces) and then their interior is indented an additional 2
  spaces more (e.g. 12 spaces).

- Code with block extent (typically a **for** loop or similar)
  contents are indented 4 spaces more than their beginning/ending

**Example:**

```basic
          for currentPlayer = 0 to 3
              for someValue = 0 to 100
                  gosub Subroutine
              next
          next
```

---

## Includes

### batariBASIC Files (.bas, .h)

Use **`#include`** (C-style preprocessor) for batariBASIC source files:

Start in column 0

```basic
#include "Source/Common/Constants.bas"
#include "Source/Common/Variables.bas"
#include "Source/Common/Colors.h"
```

### Assembly Files (.s)

Use **`include`** (assembly directive) for assembly source files.

```basic
          include "SomeFile.s"
```

When not practical or not allowed, use `#include` (cpp command)
wrapped in `asm` blocks:

```basic
          asm
#include "Source/Generated/Art.AtariAge.s"
#include "Source/Routines/CharacterArtBank2.s"
end
```

### Assembly Accumulator Shifts

If you write `asl a`, `lsr a`, `rol a`, or `ror a`, you deserve the
unresolved symbol storm you’re about to get. DASM reads that trailing
`a` as the batariBASIC zero-page alias, not the accumulator, and the
build detonates. Use the bare opcodes (`asl`, `lsr`, `rol`, `ror`) and
quit pretending the assembler will read your mind.

### batariBASIC Include Files (.inc)

Use **`includesfile`** (batariBASIC directive) for batariBASIC include
files:

```basic
          includesfile multisprite_superchip.inc
```

### Lexical Order Requirements

**CRITICAL**: All constants, data tables, and labels (except subroutine
labels) **MUST** be defined lexically prior to their use. This ensures
the compiler can resolve references correctly.

**What must be defined before use:**

- ✅ **Constants**: `const MaxCharacter = 15` must appear before `if
  characterIndex > MaxCharacter`
- ✅ **Data tables**: `data CharacterColors` must appear before `let
  color = CharacterColors[index]`
- ✅ **Labels** (non-subroutine): Jump targets, data labels, etc. must be
  defined before use
- ❌ **Subroutine labels**: Subroutine labels can be called via `gosub`
  or `goto` without prior definition (forward references are allowed)

**Correct (constants defined before use):**

```basic
const MaxCharacter = 15
const RandomArena = 255

ProcessCharacter
          if characterIndex > MaxCharacter then InvalidCharacter
          rem ... rest of code ...
```

**Incorrect (constant used before definition):**

```basic
ProcessCharacter
          if characterIndex > MaxCharacter then InvalidCharacter  ; ERROR: MaxCharacter not yet defined
          rem ... rest of code ...

const MaxCharacter = 15  ; Too late - already used above
```

**Correct (data table defined before use):**

```basic
data CharacterColors
$0E, $0C, $0A, $08
end

LoadCharacterColor
          let color = CharacterColors[characterIndex]  ; OK: table defined above
          rem ... rest of code ...
```

**Incorrect (data table used before definition):**

```basic
LoadCharacterColor
          let color = CharacterColors[characterIndex]  ; ERROR: CharacterColors not yet defined
          rem ... rest of code ...

data CharacterColors
$0E, $0C, $0A, $08
end
```

**Correct (subroutine forward reference allowed):**

```basic
ProcessInput
          gosub ValidateInput  ; OK: subroutine forward reference allowed
          rem ... rest of code ...

ValidateInput
          rem Validation logic
          return
```

**Rationale**: batariBASIC requires constants, data tables, and non-
subroutine labels to be defined before use because it performs a single-
pass compilation. Subroutine labels are an exception because `gosub` and
`goto` can resolve forward references to subroutines.

### Summary

- `.bas`, `.h`: Use `#include`, for example `#include
  "Source/Common/Constants.bas"`.
- `.s`: Use `include` within `asm` blocks:

  ```basic
  asm
  include "file.s"
  end
  ```

- `.inc`: Use `includesfile`, for example `includesfile
  multisprite_superchip.inc`.

---

## Control Flow

### IF/THEN Statements

batariBASIC uses **line-based IF/THEN**, not block syntax. All IF/THEN
statements must be single-line commands.

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

**Never bounce through a label just to run a one-liner.** Patterns like
the following waste a branch and should be collapsed so the work happens
directly in the `then` clause:

```basic
if CONDITION then goto SomeLabel
goto SkipLabel
SomeLabel
          let flag = 1
SkipLabel
```

Refactor to:

```basic
if CONDITION then let flag = 1
```

If the label performs more than a one-liner, factor it into a proper
subroutine or early `return`; do not leave a dummy detour just to hide a
single assignment.

### Tail Call Optimization

When a subroutine ends with `gosub` immediately followed by `return`,
optimize to a tail call using `goto`:

**Current (optimized):**

```basic
LoadPlayerSprite
          rem Generic sprite loading for any player
          rem Input: currentCharacter, temp2=frame, temp3=player, temp4=action
          rem Uses bank10 art system for all players
          goto LoadPlayerSpriteDispatch
```

This cannot be used when the "gosub" is to a cross-bank routine.

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
- [ ] `.s` files use `#include` in `asm` blocks
- [ ] `.inc` files use `includesfile`
- [ ] Constants defined before use
- [ ] Data tables defined before use
- [ ] Non-subroutine labels defined before use
- [ ] Subroutine labels can be forward-referenced (exception)

### ✅ Control Flow

- [ ] IF/THEN statements are line-based (not blocks)
- [ ] Tail calls optimized where appropriate

---

## Examples

### Complete Subroutine Example

```basic
          rem ChaosFight - Source/Routines/Example.bas
          rem Copyright (c) 2025 Interworldly Adventuring, LLC.

          rem =========================================================
          rem EXAMPLE SUBROUTINE
          rem =========================================================

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

If you have questions about these standards or encounter edge cases not
covered here:

1. **Check Requirements.md** for project-specific requirements
2. **Review existing code** for consistent patterns
3. **Ask the project maintainer** for clarification on ambiguous cases

---

## Version History

- **1.0** (2025): Initial style guide creation based on code review and
  Requirements.md

---

## End of Style Guide
