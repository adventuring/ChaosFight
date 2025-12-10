<!-- markdownlint-disable-file MD013 -->
# ChaosFight Coding Style Guide

**Version**: 3.0
**Last Updated**: 2025
**Copyright © 2025 Bruce-Robert Pocock.**

This document defines the coding standards for the ChaosFight project.
All code must conform to these standards to ensure consistency,
maintainability, and clarity.

**Note**: This project uses **64tass** (Turbo Assembler for 65xx processors) for assembly.
All syntax and examples in this guide reflect 64tass syntax requirements.

---

## Table of Contents

1. [Naming Conventions](#naming-conventions)
2. [Variable Assignments](#variable-assignments)
3. [Subroutine Communication](#subroutine-communication)
4. [Documentation](#documentation)
5. [File Organization](#file-organization)
6. [Memory Management](#memory-management)
7. [Indentation](#indentation)
8. [Blank Lines](#blank-lines)
9. [Includes](#includes)
10. [Control Flow](#control-flow)
11. [Code Review Checklist](#code-review-checklist)

---

## Naming Conventions

### PascalCase

Use **PascalCase** for:

- **Labels/Routines**: `LoadCharacterSprite`, `ApplyDamage`,
  `CheckPlayerElimination`
- **Constants**: `MaxCharacter`, `RandomArena`, `ColIndigo(14)`
- **Enums**: `ActionStanding`, `ActionWalking`, `ModeGame`,
  `ModeCharacterSelect`

**Label Format:**

Labels **MUST**:
- Start at the **left margin** (column 0)
- Use **PascalCase**
- Suffix with a colon `:` followed by (where appropriate) `.proc` or `.block`

**Examples:**

```assembly
LoadCharacterSprite:
.proc
          ;; Load sprite data for a character
          ;; Input: temp1 = character index, temp2 = animation frame
          ;; Output: Sprite data loaded into appropriate player register
          ;; ... assembly code ...
          rts
.pend

MultiSpriteKernel:
.block
          ;; Main kernel block
          ;; ... code ...
.bend
```

**Constants Format:**

Constants **MUST**:
- Use **PascalCase**
- Be **indented 10 spaces**
- Use `=` followed by the value

**Examples:**

```assembly
          MaxCharacter = 15
          RandomArena = 255
          FineAdjustTableEnd = FineAdjustTableBegin - 241
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

```assembly
CharacterSpriteBank2L        ;; Low byte table
CharacterSpriteBank2H        ;; High byte table
SongPointers1L               ;; Low byte lookup table
SongPointers1H               ;; High byte lookup table
```

**Forbidden:**

```assembly
CharacterSpriteLBank2        ;; "L" is not final
CharacterSpriteLoBank2       ;; Never use "Lo" for "low"
CharacterSpriteHiBank2       ;; Never use "Hi" for "high"
CharacterSpritePtrLoBank2    ;; Redundant "Ptr" + wrong suffix
CharacterSpritePtrHiBank2    ;; Redundant "Ptr" + wrong suffix
```

**Note**: `H`/`L` as the final character of a variable name is
acceptable, but never use "Hi" for "high" or "Lo" for "low" as separate
words.

### 16-bit Variables

In assembly, 16-bit variables are accessed via indexed addressing. Use pairs
of low/high byte labels or access via zero-page pairs:

```assembly
songPointer = var39          ;; Low byte
songPointer+1 = var40        ;; High byte (or use separate label)

;; 16-bit arithmetic example:
          lda songPointer
          clc
          adc #4
          sta songPointer
          bcc .no_carry
          inc songPointer+1
.no_carry:
```

Do **not** create separate variables for the low and high bytes of the same
16-bit value unless using distinct labels (e.g., `CharacterSpriteBank2L`/`CharacterSpriteBank2H`).

### camelCase (initialLowerCamelCase)

Use **initialLowerCamelCase** (camelCase starting with lowercase) for:

- **Zero-page variables** (standard RAM): `gameState`, `playerX`,
  `playerCharacter[0]`, `playerHealth`
- **Built-in variables**: `temp1`, `temp2`, `qtcontroller`, `frame`
  (already lowercase)
- **All user-defined variables**: Must start with lowercase letter

**CRITICAL**: Variables that are currently PascalCase (e.g., `NewSpriteX`, `NewSpriteY`) must be converted to initialLowerCamelCase (e.g., `newSpriteX`, `newSpriteY`).

**Examples:**

```assembly
gameState = g               ;; Zero-page variable
playerX = var0              ;; Zero-page variable
playerCharacter = j         ;; Zero-page variable
newSpriteX = $85            ;; Converted from NewSpriteX
newSpriteY = $8E            ;; Converted from NewSpriteY
```

### camelCase_R and camelCase_W

Use **camelCase_R** and **camelCase_W** suffixes for:

- **SCRAM (SuperChip RAM) variables**: Separate read and write ports

**CRITICAL**: SCRAM variables have separate read (`r000`-`r127`) and
write (`w000`-`w127`) ports that map to the same physical 128-byte RAM.
All SCRAM variable declarations **MUST** include both `_R` and `_W`
variants.

**Examples:**

```assembly
selectedArena_W = w014      ;; SCRAM write port
selectedArena_R = r014      ;; SCRAM read port
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

**STRICT SYNTAX REQUIREMENT**: **MUST use typographic apostrophes (`’`,
U+2019) instead of straight apostrophes (`'`, U+0027) in ALL comments**
(`rem` statements and `;` comments in `asm` blocks). The C preprocessor
(`cpp`) treats straight apostrophes as string delimiters, causing
compilation warnings ("missing terminating ' character"). Typographic
apostrophes are typographically correct and do not trigger preprocessor
warnings.

**This is a hard syntax requirement - code will not compile correctly
without it.**

**Correct:**

```basic
rem Check for negative velocity using two’s complement
rem It’s important to note that this uses two’s complement
rem The player won’t move if velocity is zero
rem Other screens’ minikernels should have window=0
rem Character’s weight affects fall damage
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
straight apostrophes (`'`, U+0027) as potential string delimiters,
causing compilation warnings ("missing terminating ' character").
Typographic apostrophes (`’`, U+2019) are the typographically correct
character for apostrophes in English text and do not trigger
preprocessor warnings.

**CRITICAL**: This applies to:
- All `rem` comments in `.bas` files
- All `;` comments in `asm` blocks
- All comments in `.s` assembly files included via `#include`

**Violations will cause build failures.** Always use typographic
apostrophes (`'`) for contractions and possessives in all comments.

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
          rem Copyright © 2025 Bruce-Robert Pocock.
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

### The 20-Byte Rule for Far Calls

**CRITICAL**: Routines smaller than 20 bytes should NOT be far-called
across banks. Far calls incur 15-20 bytes of overhead (bank switch,
BS_jsr, BS_return scaffolding), which often exceeds the routine size
itself.

**Rule**: If a routine is **strictly less than 20 bytes** and is
far-called, it should be:
1. **Inlined** at every call site if it's a simple helper (one-liner or
   trivial)
2. **Made local** by creating a local copy in each consumer bank if it
   needs to be shared but is too small for far-call overhead

**Examples**:
- `SetGameScreenLayout` (11 bytes, 5 call sites): Inlined at all call
  sites
- `DeactivatePlayerMissiles` (16 bytes, 1 call site): Inlined at call
  site
- `UrsuloAttack` (18 bytes, 1 call site): Inlined as tail call to
  `PerformMeleeAttack`
- `StartGuard` (20 bytes, 1 call site): Inlined at call site

**Rationale**: Wasting more ROM on the trampoline than on the actual
routine defeats the purpose of code sharing. Inlining small routines
saves ROM and improves performance by eliminating bank switch overhead.

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

Use **at least 10 spaces** for indentation of code blocks. When nested in a block other than `.block` or `.proc`, such as `.rept` or `.if`, add an additional 2 spaces for each level of nesting.

**Correct:**

```assembly
LoadCharacterSprite:
.proc
          lda temp1
          sta LCS_characterIndex
          cmp # 255
          beq LoadSpecialSprite
          ;; ... more code ...
          rts
.pend
```

**Nested Blocks:**

```assembly
          .if screenheight
                    lda # screenheight
                    sta temp1
          .else
                    lda # 88
                    sta temp1
          .fi
```

**Incorrect:**

```assembly
LoadCharacterSprite:
.proc
         lda temp1          ;; ERROR: Only 9 spaces
          sta LCS_characterIndex
.pend
```

### Labels and First Lines

- **Labels** start at column 0, use PascalCase, suffix with `:` and optionally `.proc` or `.block`
- **Local labels** within blocks use dot notation: `Block.Label` or `Proc.Label`
- **Code inside procedures/blocks** uses at least 10 spaces
- **Comments** use 10 spaces (or inline after code)
- **Directives** (`.proc`, `.pend`, `.block`, `.bend`, `.if`, `.fi`, etc.) use same indentation as surrounding code

**Example:**

```assembly
LoadCharacterSprite .proc
          ;; Load sprite data for a character
          lda temp1
          sta LCS_characterIndex
          cmp # 255
          beq LoadSpecialSprite

          ;; Normal character loading
          rts

.pend
```

### Block and Procedure Scoping

**Prefer `.block`/`.bend`** to scope labels locally. Do not embed namespacing information into labels; use nested labels with `.` dot notation in the form `Block.Label`.

**Not all labels need to establish block scope** - typically one per file. The block or proc scope label encompassing the majority or all of a file should be the same as the file name.

**Example:**

```assembly
MultiSpriteKernel .block
          ;; Main kernel code
          
          SetupP1Subroutine .proc
                    ;; Setup code
                    rts

          .pend
          
          KernelRoutine .proc
                    ;; Kernel code
                    jsr SetupP1Subroutine

                    rts

          .pend
.bend
```

### Additional indentation

- Block-level code elements like **`.byte`**, **`.word`**, **`.include`**
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

## Blank Lines

**CRITICAL RULE**: After any branch or jump instruction (`jmp`, `jsr`, `brk`, `beq`, `bne`, `bcc`, `bcs`, `bpl`, `bmi`, `bvc`, `bvs`, `rts`, etc.), there **MUST** be exactly one blank line. In any other case, there should be **no blank lines**.

**Never**:
- Between a label and remarks describing a routine entered via that label
- Between a remark and the subsequent line which it describes
- Between lines in one series of remarks
- Anywhere except after branch/jump instructions

**Correct:**

```assembly
LoadCharacterSprite .proc
          ;; Load sprite data for a character
          ;; Input: temp1 = character index, temp2 = animation frame
          lda temp1
          cmp # 255
          beq LoadSpecialSprite

          ;; Normal character loading
          rts

LoadSpecialSprite .proc
          ;; Load special sprite variant
          lda temp2
          rts
```

**Incorrect:**

```assembly
LoadCharacterSprite .proc

          ;; Load sprite data for a character
          ;; Input: temp1 = character index, temp2 = animation frame

          lda temp1
          cmp # 255
          beq LoadSpecialSprite
          ;; Normal character loading
          rts
LoadSpecialSprite .proc
          ;; Load special sprite variant
```

**Rationale**: Blank lines serve a clear structural purpose: marking the end of control flow paths. They should never break the visual connection between a label and its documentation, or between documentation and the code it describes.

---

## Includes

### batariBASIC Files (.bas, .h)

Use **`#include`** (C-style preprocessor) for batariBASIC source files:

Start in column 0

```basic
#include "Source/Common/Constants.bas"
#include "Source/Common/Variables.bas"
#include "Source/Common/Colors.s"
```

### Assembly Files (.s)

Use **`.include`** (64tass directive) for assembly source files.

```assembly
.include "Source/Common/Preamble.s"
.include "Source/Banks/Bank1.s"
```

**DO NOT** use `#include` (cpp preprocessor) or `include` without dot prefix.

### Assembly Accumulator Shifts

If you write `asl a`, `lsr a`, `rol a`, or `ror a`, you deserve the
unresolved symbol storm you’re about to get. DASM reads that trailing
`a` as the batariBASIC zero-page alias, not the accumulator, and the
build detonates. Use the bare opcodes (`asl`, `lsr`, `rol`, `ror`) and
quit pretending the assembler will read your mind.

### Procedure Blocks

Every routine **MUST** be wrapped in a `.proc` / `.pend` block:

```assembly
LoadCharacterSprite .proc
          ;; Procedure body with 10-space indentation
          ;; ... assembly code ...
          rts

.pend
```

**CRITICAL**: The label **MUST** be on the same line as `.proc` or `.block`, with a space between them: `LabelName .proc` or `LabelName .block`. Do not use a colon before `.proc` or `.block`, and do not use `.proc LabelName` syntax.

### Lexical Order Requirements

**CRITICAL**: All constants, data tables, and labels (except procedure
labels) **MUST** be defined lexically prior to their use. This ensures
the assembler can resolve references correctly.

**What must be defined before use:**

- ✅ **Constants**: `MaxCharacter = 15` must appear before use in expressions
- ✅ **Data tables**: `.byte` data blocks must appear before use
- ✅ **Labels** (non-procedure): Jump targets, data labels, etc. must be
  defined before use
- ❌ **Procedure labels**: Procedure labels can be called via `jsr` or `jmp`
  without prior definition (forward references are allowed)

**Correct (constants defined before use):**

```assembly
MaxCharacter = 15
RandomArena = 255

ProcessCharacter
.proc
          lda characterIndex
          cmp #MaxCharacter
          bcs InvalidCharacter
          ;; ... rest of code ...
          rts
.pend
```

**Incorrect (constant used before definition):**

```assembly
ProcessCharacter
.proc
          lda characterIndex
          cmp #MaxCharacter          ;; ERROR: MaxCharacter not yet defined
          ;; ... rest of code ...
          rts
.pend

MaxCharacter = 15                    ;; Too late - already used above
```

**Correct (data table defined before use):**

```assembly
CharacterColors:
          .byte $0E, $0C, $0A, $08

LoadCharacterColor
.proc
          ;; ... load color using CharacterColors table ...
          rts
.pend
```

**Incorrect (data table used before definition):**

```assembly
LoadCharacterColor
.proc
          ;; ERROR: CharacterColors not yet defined
          rts
.pend

CharacterColors:
          .byte $0E, $0C, $0A, $08
```

**Correct (procedure forward reference allowed):**

```assembly
ProcessInput
.proc
          jsr ValidateInput    ;; OK: procedure forward reference allowed
          ;; ... rest of code ...
          rts
.pend

ValidateInput
.proc
          ;; Validation logic
          rts
.pend
```

**Rationale**: 64tass requires constants, data tables, and non-procedure
labels to be defined before use. Procedure labels are an exception because
`jsr` and `jmp` can resolve forward references to procedures.

### Summary

- `.s` files: Use `.include` directive, for example `.include "Source/Common/Constants.s"`.
- All directives use dot prefix: `.proc`, `.pend`, `.if`, `.fi`, `.include`, `.byte`, `.error`, etc.
- Do NOT use `#include` (cpp preprocessor) or `include` without dot prefix.

---

## Control Flow

### Conditional Assembly

64tass uses **conditional assembly directives** (`.if` / `.fi`) for compile-time conditionals:

**Correct:**

```assembly
.ifdef TV_NTSC
          .include "Source/Generated/Song.NTSC.s"
.else
          .include "Source/Generated/Song.PAL.s"
.fi

.if MaxCharacter > 15
          .error "MaxCharacter exceeds limit"
.fi
```

### Runtime Conditionals

For runtime conditionals, use assembly branches:

**Correct:**

```assembly
          lda selectedArena
          cmp #RandomArena
          beq DisplayRandomArena
          
          lda joy0fire
          beq .skip_fire
          jmp ArenaSelectConfirm
.skip_fire:
          
          lda LCS_isValid
          bne .valid
          jmp LoadSpecialSprite
.valid:
```

If the label performs more than a one-liner, factor it into a proper
subroutine or early `return`; do not leave a dummy detour just to hide a
single assignment.

### Immediate Values

**CRITICAL**: Immediate values follow the octothorpe (`#`) with a space, e.g., `lda # 0` or `cmp # SomeConstant`. However, hexadecimal immediate values do **not** have a space before the peso sign (`$`), e.g., `lda #$80`.

**Correct:**

```assembly
          lda # 0
          lda # 15
          lda # MaxCharacter
          lda #$80
          lda #$FF
          cmp # screenheight
          cmp #$59
```

**Incorrect:**

```assembly
          lda #0          ;; ERROR: Missing space after #
          lda # $80       ;; ERROR: Space before $ in hex
          lda #$ 80       ;; ERROR: Space after $ in hex
          cmp #screenheight  ;; ERROR: Missing space after #
```

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

### ✅ Includes and Directives

- [ ] `.s` files use `.include` directive (not `#include` or `include`)
- [ ] All directives use dot prefix (`.proc`, `.pend`, `.if`, `.fi`, `.byte`, `.include`, etc.)
- [ ] Labels precede `.proc` on same line: `LabelName .proc` (not `.proc LabelName` or separate lines)
- [ ] Constants defined before use
- [ ] Data tables defined before use
- [ ] Non-procedure labels defined before use
- [ ] Procedure labels can be forward-referenced (exception)
- [ ] `.error` used only for fatal errors (e.g., PC mismatch)
- [ ] `.warn` used for informational messages: `.warn format("Message %d", value)`
- [ ] All directives use dot prefix (`.proc`, `.pend`, `.if`, `.fi`, `.byte`, `.include`, etc.)

### ✅ Control Flow and Syntax

- [ ] Conditional assembly uses `.if` / `.fi` (not `IF` / `ENDIF`)
- [ ] Macros use `.macro` / `.endm` (not `MAC` / `ENDM`)
- [ ] Repeat blocks use `.rept` / `.next` (not `REPEAT` / `REPEND`)
- [ ] Comments use `;;` (double semicolon) at column 10
- [ ] File headers use `;;;` (triple semicolon) at column 0
- [ ] All procedures wrapped in `.proc` / `.pend` blocks

---

## Examples

### Complete Subroutine Example

```basic
          rem ChaosFight - Source/Routines/Example.bas
          rem Copyright © 2025 Bruce-Robert Pocock.

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
- **2.0** (2025): Updated with comprehensive naming conventions and documentation standards
- **3.0** (2025): Updated label format (colon suffix for regular labels, `LabelName .proc`/`.block` format without colon before directive), constants indentation (10 spaces), variable naming (initialLowerCamelCase), blank line rules (exactly one after branch/jump/`rts`), immediate value formatting (space after `#`, no space before `$` in hex), block scoping preferences

---

## End of Style Guide
