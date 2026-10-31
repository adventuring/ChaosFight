# ChaosFight 6507 Assembly Programming Guide

## Overview

This skill file provides critical guidance for 6507 assembly-language programming in the Chaos Fight Atari 2600 project. It covers TIA timing requirements, 2600 architecture, and project-specific implementation rules based on the game's documentation and code standards.

## Core Programming Concepts

### INVIOLABLE DISPLAY TIMING

**262 / 312 SCANLINE DISPLAY IS INVIOLABLE — ANY VARIATION WILL CAUSE PICTURE DROP-OUTS.**

- **NTSC (Standard)**: **262 scanlines** total per frame
- **PAL (European)**: **312 scanlines** total per frame
- **SECAM**: Same timing rules apply

This total frame count includes VSYNC (3 lines), VBLANK (variable), visible scanlines (192 standard), and overscan. Deviating from the exact 262/312 scanline count will cause the TV/display to lose vertical sync, resulting in visible rolling, flickering, or complete picture drop-out.

The Chaos Fight project uses the standard NTSC timing (262 lines) unless explicitly configured for PAL or SECAM (each 312 lines) via the platform files (`Source/Platform/NTSC.s`, `PAL.s`, `SECAM.s`). All kernel timing calculations assume this total scanline budget.

### TIA Timing Fundamentals

The Chaos Fight project uses the **MultiSpriteKernel.s** as its primary timing reference. Key timing metrics:

#### Critical Timing Requirements:
- **Main scanline loop body (KernelLoopb -> KernelLoopa)**: **152 cycles** per 2 scanlines
- **PositionASpriteSubroutine**: Must be called with **>=11 cycles remaining** in scanline, returns **9 cycles** into next scanline
- **Interrupt timing**: INTIM check takes **3 cycles** (BMI not-taken branch: 2 cycles, taken: 3 cycles)
- **WSYNC timing**: Each WSYNC consumes **3 cycles** of visible scanline time
- **VDEL timing**: Player sprites can only be enabled within 6-8 pixels of HMOVE due to TIA latching

#### Scanline Timing Budget (Sample):
```assembly
; WaitForOverscanEnd (3-4 scanlines)
lda INTIM ;c=3
bmi WaitForOverscanEnd ;c=2/3

; VSYNC setup (2 scanlines)
lda # 2 ;c=2
stx WSYNC ;c=3
sta VSYNC ;c=3
stx WSYNC ;c=3
stx WSYNC ;c=3

; Per-scanline budget (approx 76 cycles available for game logic)
KernelLoopb -> KernelLoopa = 152 cycles = 2 scanlines
```

### TIA Register Write Windows

#### Critical Write Timing:
1. **HMOVE effects**: Must write HMPx/RESPx, THEN HMOVE within one scanline
2. **VDELPx timing**: Enable player deletion before VSYNC period
3. **WSYNC synchronization**: Use to split timing between TIA operations and CPU code
4. **HMCLR timing**: Must be written to clear horizontal movement latches

#### Positional Timing Constraints:
```assembly
PositionASpriteSubroutine:
    sec ;c=2
    stx WSYNC ;c=3 ;begin line 1
    sta @w HMCLR ;c=4 ;+4 4
    ; ... 58 cycles of divide-by-15 loop ...
    sta HMP0, x ;c=4 ;+4 19/24/...69
    sta RESP0, x ;c=4 ;+4 23/28/33/38/43/48/53/58/63/68/73
    stx WSYNC ;c=3 ; + 3 0 begin line 2
    sta HMOVE ;c=3 ; + 3
    rts ;c=6 ;+6 9
```

### 2600 Memory Architecture

#### Bank Switching System:
- **Bank window**: CPU sees $F000-$FFFF (16 banks x 4KB each)
- **Bank 14**: Character themes (songs 0-6) + sound effects + music helper routines
- **Bank 15**: Music system (songs 6-28, StartMusic/PlayMusic, build info), main loop
- **Bank 16**: MainLoop, drawscreen (hot loop requirement), ArenaLoader, SetPlayerGlyphFromFont, game entry point
- **Banks 2-5**: Character graphics (4 banks for 32 characters)
- **Bank 0**: Sound pointer tables + songs 0-5

#### Zero-Page Usage:
- **var0-var47**: $A4-$D3 range (standard RAM)
- **Performance-critical workspace** ($CB-$D0): Use descriptive names (`spriteIndex`, `animationFrame`) instead of legacy `temp1`/`temp2`
- **Built-in registers**: TIA ($D000-$DFFF), RIOT ($E000-$EFFF)

#### SCRAM (SuperChip RAM) Rules:

**CRITICAL SCRAM SPECIFICATIONS**:
```assembly
; SCRAM access via $d0xx page (preferred)
; Write ports: $d000-$d07f
; Read ports: $d080-$d0ff  = write ports + $80

; Examples with $d0 preferred mapping:
selectedArena_W = $d014    ; SCRAM write port (preferred)
selectedArena_R = selectedArena_W | $80 = $d094    ; SCRAM read port

; NEVER use raw $f0/$f8 addresses:
;   selectedArena_W = $F00E  ; WRONG - not preferred
;   selectedArena_R = $F08E  ; WRONG - should be | $80
```

**SCRAM Variable Declaration Rules**:
1. **Always use `_R` and `_W` suffixes**
2. **Use good, descriptive names** (no `w014` aliases)
3. **If aliasing is required**: guarantee no simultaneous use
4. **Read port = write port | $80** (e.g., `r014 = w014 | $80`)

**Valid Examples**:
```assembly
; Correct: descriptive names with SCRAM ports
selectedArena_W = $d014
selectedArena_R = selectedArena_W | $80

animationCounter_W = $d077
animationCounter_R = animationCounter_W | $80
```

**Forbidden Examples**:
```assembly
; Wrong: raw port numbers or convenience aliases
dim selectedArena = $d014    ; WRONG: no _R/_W variants
dim arena = w014             ; WRONG: alias not permitted
```

### Programming Standards

#### Naming Conventions:
**Variables (lowerFirstCamelCase)**:
- User-defined: `playerX`, `gameState`, `playerCharacter[0]`, `playerHealth`
- Built-in: `qtcontroller`, `frame` (use descriptive names for new variables; avoid `temp1`-`temp6`)
- SCRAM: `selectedArena_W`, `animationCounter_R` (good names only)

**Routines/Labels (CapitalFirstPascalCase)**:
- `LoadCharacterSprite`, `ApplyDamage`, `CheckPlayerElimination`
- `PositionASpriteSubroutine`, `KernelSetupSubroutine`, `MultiSpriteKernel`

#### Critical Syntax Rules:
1. **Variable assignments**: Use `LET` for user-defined, `=` for built-ins
2. **Comments**: Use typographic apostrophes (U+2019) - never straight apostrophes (') in comments
3. **Immediate values**: `# 15` (space after #), `#$80` (no space before $)
4. **Indentation**: Exactly 10 spaces for code blocks
5. **Blank lines**: Exactly one after branch/jump/rts, none elsewhere

### Cross-Bank Calling Conventions

#### Far Call Rules (CRITICAL):
1. **Cross-bank calls**: Use `BS_jsr` at caller, `jmp BS_return` at callee
2. **Same-bank calls**: Use `jsr`/`rts`
3. **Mixed conventions**: PROHIBITED - causes stack corruption
4. **20-byte rule**: Routines <20 bytes should be inlined or made local

#### Example Correct Far Call:
```assembly
; Caller (bank switch)
           lda #Bank10
           sta currentBank
           jmp BS_jsr          ; Push 4-byte return, switch banks
           ; ... work in bank 10 ...
           jmp BS_return       ; Decode return, switch back

; Callee (must use jmp BS_return)
CharacterRoutine:
. . .
            jmp BS_return       ; CRITICAL: jmp NOT jsr
. . .
```

### Music Data Structures

#### Song Pointer Tables:
```assembly
; Bank 14 (SongPointers2) - Character themes (IDs 0-6):
SongPointers2L:
           .byte <Song_Bernie_Voice0, <Song_OCascadia_Voice0, <Song_Revontuli_Voice0, <Song_EXO_Voice0, <SoundJump0, <Song_Grizzlies_Voice0, <Song_MagicalFairyForce_Voice0, <Song_Bolero_Voice0
SongPointers2H:
           .byte >Song_Bernie_Voice0, >Song_OCascadia_Voice0, >Song_Revontuli_Voice0, >Song_EXO_Voice0, >Song_Grizzlies_Voice0, >Song_MagicalFairyForce_Voice0, >Song_Bolero_Voice0

; Bank 0 (SongPointers1) - Extended songs (IDs Bank0MinSongID-28):
SongPointers1L:
           .byte <Song_LowRes_Voice0, <Song_RoboTito_Voice0, <Song_SongOfTheBear_Voice0, ...
SongPointers1H:
           .byte >Song_LowRes_Voice0, >Song_RoboTito_Voice0, >Song_SongOfTheBear_Voice0, ...
```

#### Sound Effect Pointer Tables:
```assembly
SoundPointersL:
           .byte <Sound_SoundAttackHit, <Sound_SoundGuardBlock, <Sound_SoundJump, <Sound_SoundPlayerEliminated, <Sound_SoundMenuNavigate, <Sound_SoundMenuSelect, <Sound_SoundSpecialMove, <Sound_SoundPowerup, <Sound_SoundLandingSafe, <Sound_SoundLandingDamage
SoundPointersH:
           .byte >Sound_SoundAttackHit, >Sound_SoundGuardBlock, >Sound_SoundJump, >Sound_SoundPlayerEliminated, >Sound_SoundMenuNavigate, >Sound_SoundMenuSelect, >Sound_SoundSpecialMove, >Sound_SoundPowerup, >Sound_SoundLandingSafe, >Sound_SoundLandingDamage
```

#### Music Playback Rules:
1. **StartMusic**: Called with `jmp PlayMusic` (tail call with bank switch to Bank 1)
2. **PlayMusic**: Runs in Bank 1, updates dual voice streams each frame
3. **VBlank handler**: `VblankHandlerTrampoline` in Bank 15 calls music update
4. **No background music during gameplay** - only SFX (attack, guard, jump, elimination, landing)
5. **Winner screen**: Plays winner's character theme (Bank 14 songs 0-6)
6. **Title screen**: "Chaotica" (Song 19) repeats; Publisher Prelude plays "AtariToday" (Song 20); Author Prelude plays "Interworldly" (Song 21)

### Project-Specific Requirements

#### Chaos Fight Game Flow:
1. **Cold Start**: Console detection (2600 vs 7800) → WarmStart initialization → Controller detection (Mega Drive/Genesis, Joy2b+, Quadtari)
2. **Game Mode**: 60 FPS physics + 10 FPS animation systems (8-frame sequences)
3. **Modes**: Publisher Prelude → Author Prelude → Title Screen → Character Select → Arena Select → Game Mode → Winner Screen → Attract Mode loop back to Publisher
4. **Controller Support**: 2-player standard + 4-player Quadtari (frame-multiplexed) + Artendo NES adapter (natively maps A/B=Fire, SELECT=Jump, START=Defend, D-Pad=joystick; all buttons pass through Quadtari; no detection required)

#### Critical Game Systems:
- **Character weights**: Bernie (5) to Dragon of Storms (100) - affects jumps, movement speed, knockback resistance
- **Missile system**: Multiplexed in 4-player mode (even/odd frames: missile0/1 shared)
- **Sound**: No background music during gameplay, only SFX
- **Health system**: 100% normal, 75% handicap (Down + Fire), instant death on 0 HP

#### Console Switch Handling:
- **Game Reset**: Instant hard reboot (WarmStart), 7800 pause button also triggers
- **Game Select**: Toggles pause in Game Mode; returns to Character Select in Arena Select
- **Color/BW**: In Color position, per-row pfcolor; in B/W position, white playfield only
- **7800 Pause**: Momentary toggle of colorBWOverride variable

#### Character System Details:
- **16 characters** (0-14 + Shamone as 15)
- **Character 15 (Shamone)**: Form-switching to Meth Hound (character 31) via UP button
- **Flying characters**: Dragon of Storms and Frooty ignore gravity (full flight control)
- **Bernie special case**: Screen wrap from bottom to top, fall damage immunity

#### Collision and Combat:
- **Hit detection**: AABB (axis-aligned bounding box) collision
- **Damage application**: 3-step process - hurt animation with knockback, recovery frames (damage / 2, clamped 10-30 frames), color dimming
- **Instant death**: Health < damage amount
- **Missile multiplexing**: P1/P3 on even frames, P2/P4 on odd frames

#### 20-Byte Rule (Far-Call Optimization):
Routines smaller than 20 bytes should NOT be far-called across banks. Far calls add 15-20 bytes of overhead (BS_jsr, BS_return), often exceeding the routine size itself.

**Rule**: Routines <20 bytes should be:
- **Inlined** at call sites if trivial (one-liner helpers)
- **Made local** by creating copies in each consumer bank

### Advanced TIA Timing

#### 6502 Scanline Cycle Budget (76 cycles/scanline):
- **HMOVE clock**: 6 cycles of horizontal blank (256 color clocks = 64 usecs = 76 cycles)
- **640x clock**: 6502 runs at ~1.19MHz (NTSC) or ~1.18MHz (PAL)
- **Visible line**: 227 color clocks (57 cycles) active display + 68 cycles HBLANK + 37 HMOVE clocks

#### Fine Adjustment System:
- **FineAdjustTableBegin/End**: Provides sub-pixel horizontal positioning adjustments
- Range: -6 to +15 pixels relative to REFPx coarse positioning
- Must align with WSYNC boundary after RESPx

#### VBlank/Vsync Budget:
- NTSC: 3 scanlines VSYNC + 37 scanlines VBLANK (40 lines total before visible)
- PAL: 3 scanlines VSYNC + 72 scanlines VBLANK
- Total: 262 (NTSC) / 312 (PAL) scanlines per frame

### Debugging and Verification

#### Key Verification Points:
1. **Stack depth**: Never exceed 3 nested subroutines
2. **Label ordering**: Constants/tables/labels defined before use (except procedures)
3. **PROC/PEND blocks**: Every routine wrapped in `.proc`/`.pend`
4. **Blank line rules**: Exactly one after `rts`, none elsewhere
5. **SCRAM usage**: Verify all SCRAM variables have both `_R` and `_W` variants

#### Debug Tools:
- **Stella emulator**: For visual timing verification
- **Disassembly**: Check bank boundaries at $N000 offsets
- **Cycle counting**: Use `;c=` annotations in MultiSpriteKernel.s as reference

### Stella Debugging Protocol (Trace/Breakpoint/Compare)

#### Start Stella with Tracing Enabled (Headless / Log Mode)
```bash
# Headless with debug enabled, break at first instruction in Bank 13
stella -nosound -novideo -debug /home/brpocock/Projects/ChaosFight/Dist/ChaosFight26.NTSC.a26 \
  -break 0xf174 -trace /tmp/chaos_trace.log 2>&1 | tee /tmp/stella_run.log

# Verify ROM loaded (check MD5 from .lst / .pro file)
md5sum /home/brpocock/Projects/ChaosFight/Dist/ChaosFight26.NTSC.a26
# Expected: 82e5f27f84bbe9d644b1b31269ebaeea
```

#### Trace-to-Listing Comparison Workflow
1. **Identify crash address from trace** (e.g., `PC $217b`, `PC $0649` — garbage means `BS_return` decoded wrong bank/stack).
2. **Find exact label in `.lst`** using line numbers from build output:
```bash
grep -n "PublisherPreludeMain\|PublisherPreludeComplete\|AfterBeginAuthorPrelude" \
  /home/brpocock/Projects/ChaosFight/Dist/ChaosFight26.NTSC.lst | head -20
```
3. **Compare stack picture comments** in source (`PublisherPrelude.s` lines 55-191, `BeginAuthorPrelude.s` lines 40-58) to `.lst` disassembly at matching bank offset (`.a98e`, `.f174`, `.f11a`).
4. **Check push order** — must be `return_hi`, `return_lo`, `target_hi`, `target_lo` (return FIRST, target LAST for RTS to pop target correctly). If `.lst` shows wrong byte sequence, edit source and rebuild.

#### Debug Checklist (Cross-Bank Crash at $217b / $0649)
- Confirm `controllerStatus ($E3)` non-zero (`$01`, `$04`, or `$01|$04` for Genesis; `$80` for Quadtari). If `$00`, `ControllerDetection.s` (timer `bne *-3`, Genesis `bmi`) failed — rebuild required.
- Confirm `fireEdgeState ($9E)` bit 7 (`$80`) latches on fire hold. If stays `$00`, `ConsolidatedPlayerInput.s` (`line 53-207`) isn't refreshing `player0Input`/`player1Input` from `INPT4`/`INPT5`.
- Confirm `BS_jsr` (`BankSwitching.s`, line 48) pushes 4 bytes before `nop $ffe0,x`; `BS_return` (`line 11`) reads `2,x` for encoded return hi with bank in high nybble.
- Confirm `StartMusic` (`MusicSystem.s`, line 238) ends with `jmp BS_return` (not `rts`). Confirm `AfterStartMusicAuthorPrelude` (`BeginAuthorPrelude.s`, line 60) does `jmp BS_return` after setting windows.
- Confirm `MainLoopModePublisherPrelude` (`MainLoop.s`, line 239) pushes return FIRST then target LAST, matching `.lst` lines 250-265 (`.f733` = `jmp BS_jsr`).

### Final Notes for 6507 Agent

**CRITICAL SUMMARY**:
- **262/312 scanlines is INVIOLABLE** - picture drop-outs otherwise
- **Use `$d0xx` page for SCRAM** (not `$f0xx`) with `port_R = port_W | $80`
- **`temp1`-`temp6` are legacy** - use descriptive names like `spriteIndex`, `animationFrame`
- **Never mix** `jmp BS_return` and `jsr BS_return` - stack corruption guaranteed
- **76-cycle budget per scanline** - optimize aggressively
- **Bank 15 = hot loop requirement** for MainLoop, drawscreen
- **Music uses dual voice streams** (Voice0 + Voice1) for richer sound
- **Sound effects are theme-independent** - used across all characters

- **Never "make clean"** without explicit permission - this removes generated files, temporary build artifacts, and can destroy work-in-progress state
- **Never assume anything is "fixed" or "ready"** until confirmed by human QA - apparent fixes may mask underlying bugs, and "complete" states may miss edge cases

This skill file covers all critical aspects of Chaos Fight programming for the 6507 assembly agent.

---

*This skill file is maintained as part of the Chaos Fight project and reflects the current programming standards as of version 0.1.*

**For the 6507 assembly agent**: Focus on adhering to these timing constraints and coding standards. The TIA's strict timing requirements are the primary constraint in 2600 programming, and Chaos Fight's complexity demands rigorous adherence to these specifications.