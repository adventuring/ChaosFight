# ChaosFight DASM → 64tass Port Notes

Research/decisions gathered while making the tree assemble cleanly under 64tass.
Preserved because these 64tass behaviours are non-obvious and cost real time to
discover.

## Build invocation

Run from `Object/`:

```
64tass -Wall -Wno-branch-page -C -a --m6502 -b --ascii \
  -I.. -I. -I../Source -I../Source/Common -I../Source/Routines \
  -I../Source/Data -I../Source/Generated -I../Source/Banks \
  -o test.a26 ../Source/Generated/ChaosFight26.NTSC.s
```

The trailing `-I` directories (`Data`, `Generated`, `Banks`) are required; the
generated top-level file includes from those roots.

Output is a **64 KiB** image: 16 banks × 4 KiB, each assembled at `$F000` with
`.offs (BANK*$1000)-$f000`. Stella detects bankswitching as
`F0 (Dynacom Megaboy)`; the ROM carries an `EFSC` header at `$FFE0`
(`.text "EFSC", 0 / .text "BRPocock", 0 / .byte 26, current_bank`).

Reset vector `$FFFC` = `$FFF0`, matching `Reset:` in `Bank15.s`.

## 64tass semantics discovered (important)

1. **`-C` / `--case-sensitive` applies to mnemonics, not just labels.**
   Uppercase opcodes such as `JMP` become a syntax error under `-C`
   (`error: general syntax`), because the mnemonic table becomes case
   sensitive and `JMP` is no longer a known instruction. The port keeps `-C`
   (needed for camelCase migration) so **all mnemonics must be lowercase**.

2. **Leading-underscore names are *local* symbols.** A name beginning with `_`
   is scoped to the current local-label region ("searched in this object
   only"). They cannot be referenced across scopes. `_COLUP1` / `_NUSIZ1` were
   therefore unusable as globals; references were repointed to
   `NewCOLUP1` / `newNUSIZ`.

3. **`.proc` allows duplicate label definitions (last one wins) — no error.**
   Verified: two identical labels inside one `.proc` assemble silently. This is
   why many auto-translated routines full of duplicated bB blocks still
   assemble. It is also a correctness hazard: a `jmp`/`branch` to a label that
   is defined twice inside a proc resolves to the *last* definition
   (64tass reports these as `warning: shadow definition '...' [-Wshadow]`,
   27 of them in this tree as of this port).

4. **Undefined symbols error only where a value is required.** A truly
   undefined symbol referenced in a constant-folding context (`#`, `.byte`,
   `.if`, `sta`/`lda` needing the address) errors with `not defined symbol`.
   Names are not silently treated as external.

5. **`@w` forces word (absolute) addressing**; e.g. `cpy @w p0Top` assembles as
   absolute `CC xx xx`. The DASM `.w` suffix must be written `@w`.

6. **The program counter is `*`, not `.`.** `bmi .-3` is a syntax error;
   `bmi *-3` works.

7. **`.byte $24` replaces the DASM pseudo-op `.BitSkipOne`** (bit-zero-skip of
   the following byte).

8. **Macro parameters must be referenced with `\name`.** A bare `service` /
   `bank` inside a macro body is resolved as a (missing) global, not the
   parameter. `FarJMP`/`FarJSR` were fixed to use `\service` / `\bank`.

9. **`.block <Name> ... .bend`** creates the namespace used by the kernel
   (`MultiSpriteKernel.drawscreen`), and `.proc ... .pend` scopes routine
   labels.

10. `.rept`/`.endrept`, `.fill`, `.offs`, `* =`, `.error`, `.warn format(...)`,
    `.cdef` are all understood by 64tass.

## Fixes applied to reach a clean build

- Restored missing equates/enums (`MissileFlagCurlerFull`, `MeleeAttack`,
  `RangedAttack`, `AreaAttack`, `GPL_playerIndex`, `UCA_quadtariActive`,
  `characterSelectPlayerAnimationTimer_R/_W`, `C6E_stateFlags`) and added
  camelCase ZP aliases in `MultiSpriteSuperChip.s`.
- Added `current_bank = 0` in `Bank0.s` (`BankSwitching.s` reads it).
- Lowercased the one uppercase mnemonic, fixed macro params in `Macros.s`,
  fixed `bmi *-3`, split garbled multi-instruction lines, qualified
  cross-`.proc` references in `VblankHandlers.s`.
- Kernel: `MultiSpriteKernel` wrapping, `drawscreen:` entry, HEAD overscan,
  vblank/minikernel guards, `FontData` score font, `.w`→`@w`.
- Title screen: generated art does not emit per-bitmap `_PF1`/`_PF2`/
  `_background` bytes, so they are defined `= 0` in `Bank8.s` (feature off)
  instead of leaving the kernel `.if` guards referencing undefined symbols.

## Known residual issues (not build blockers)

- Auto-translated routines contain **duplicated instruction blocks** (the same
  op sequence emitted twice) and 27 **shadow label** definitions. These
  assemble but can be semantically wrong (double-applied updates; last-wins
  label resolution).
- `FontData` (score font, 16 bytes/glyph in `Source/Generated/Numbers.s`) is
  **not page-aligned**, while the kernel's `scorepointerset` uses
  `#>FontData`/`#<FontData` pointer math that assumes page alignment.
- `Bank15.s`'s `EFSC` header writes `current_bank = 15`; verify the intended
  boot bank if the header is meant to advertise the power-on bank.
- Stella 8.0 has no `-maxframes`; automated smoke test is
  `timeout 15 stella rom` (exit 124 == ran until killed). The
  `free(): invalid pointer` on exit is a Stella/SDL teardown issue, not the ROM.

## Verification

- `64tass ...` → **exit 0, 0 errors** (851 warnings).
- `stella test.a26` → loads, detects scheme/controllers, emulates continuously
  (renders frames) until killed; no ROM-level fault.

## Multisprite kernel cycle review

`Source/Common/MultiSpriteKernel.s` now carries a per-instruction cycle
annotation, tagged `;c=N`, using the standard NMOS 6502 table. The annotation
was added mechanically (script) and **verified byte-neutral**: the assembled
`.a26` is md5-identical to the pre-annotation build, so only comments changed.

Convention:

| marker | meaning |
|--------|---------|
| `N`    | fixed cycle cost |
| `2/3`  | relative branch: 2 not taken / 3 taken (+1 on page cross) |
| `N+1*` | read op that costs +1 on a page crossing |
| `.Sleep N` | exactly N cycles (see `Source/Common/Macros.s`) |

Findings:

- The port's `.Sleep` values **match batari Basic's
  `includes/multisprite_kernel.asm` exactly** (SLEEP 7 / 2 / 6 / 4 / 12/6, …),
  so the port introduced **no timing regression**.
- The legacy `;␉NN` / `;+N␉NN` position comments were copied verbatim from
  upstream and are **known to be wrong**. The upstream author and the
  AtariAge thread "Modifying the Multisprite Kernel … its complex for sure"
  (2024-03) both state the cycle comments in this kernel are off; at least one
  cleaned-up fork (splendidnut/bB-multicolorsprite-kernel) exists specifically
  because of it. Reference:
  https://forums.atariage.com/topic/362717-modifying-the-multisprite-kernel-its-complex-for-sure
- On the no-page-cross, no-reposition path the main loop body
  (`KernelLoopa` → next `KernelLoopa`) is **exactly 152 cycles = 2 scanlines**.
  This means sprite data and the `player0Pointer` / `p1Display` /
  `PF1pointer` / `PF2pointer` tables must be aligned so that no `(zp),y` read
  crosses a page — otherwise each crossing adds 2 cycles and the 2-scanline
  lock is lost. (The upstream `align 256` before the RepoKernel section is
  commented out; worth revisiting if vertical jitter appears.)
- Corrected positions for reference (upstream said 50/54): `KernelLoopa` is at
  cycle 40, `KernelLoopb` at cycle 47, relative to `KernelRoutine` entry.

Useful cross-check when editing the kernel: reassemble and diff the `.a26`
against a saved baseline — any byte change means the edit was not comment-only.

## Diagnostic: "branch too far" + "duplicate definition" together

A routine file that is **missing its `.block <RoutineName>` wrapper** produced a
very misleading pair of 64tass errors:

```
BeginFallingAnimation.s:144: error: branch too far by -1150 bytes
      bne CheckPlayer3Character
BeginFallingAnimation.s:147: error: duplicate definition 'CheckPlayer3Character'
PlayerPhysicsGravity.s:61:1: note: original definition was here
```

Root cause: all 16 banks assemble in *one* pass with a shared symbol table, so
auto-translated bB idioms like `CheckPlayer3Character` / `DonePlayer3Init` are
global unless the file opens a namespace. `PlayerPhysicsGravity.s` legitimately
defines its own `CheckPlayer3Character` at file scope; the un-wrapped
`BeginFallingAnimation.s` therefore (a) collided with it and (b) had its `bne`
resolved against *that* bank-relative definition 1150 bytes away — hence the
bogus "branch too far" even though the intended target was 3 bytes ahead. Both
errors vanish once the routine is wrapped (`BeginFallingAnimation .block` …
`.bend`), because inner labels then resolve block-locally.

Notes for future fixes:

- `.block NAME` *does* define `NAME` as a global label at the block start
  (verified: `BeginFallingAnimation= $f000` in the `.sym`), so cross-bank
  callers (`ChangeGameMode.s` uses `<(BeginFallingAnimation-1)`) keep working.
- Wrapping in a block is byte-neutral: no instruction is added, so bank sizes
  and the `.a26` are unchanged; only the symbol scopes move.
- If an inner label shadows an existing global, 64tass emits
  `warning: shadow definition '...' [-Wshadow]` (non-fatal, but the tree
  currently has **zero** such warnings — prefer renaming with a routine prefix,
  e.g. the `BPC_`, `CAPE_`, `PCR_`, `CEJB_` style, if a shadow warning appears).
- Verify a suspicious branch by assembling the single routine against a tiny
  stub harness in `/tmp` and reading the `-L` listing; the operand of an
  in-range `bne` shows the resolved target (e.g. `d0 03  bne $f059`).
