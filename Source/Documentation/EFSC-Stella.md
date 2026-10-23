# EFSC / Stella for ChaosFight

- ROM: `Dist/ChaosFight26.NTSC.a26`, bank switching EFSC (64K). Stella: `-bs EFSC -dev.settings 1 -debug`.
- Frame = 262 NTSC scanlines (3 VSYNC + 37 VBLANK + 192 display + 30 overscan).
- Title screens (modes 0-2) use the title kernel (no vblank hook); consolidated player input is refreshed in `MainLoop` overscan for all modes.
- Music pointers in zero page `$F0-$F5` (songPointer, musicVoice0Pointer, musicVoice1Pointer). `musicPlaying` at `$F6`. `playerCharacter` at `$F7-$FA`. Consolidated input at `$FB-$FE` (player0Input..player3Input). `titleParadeTimer` at `$FF`.
- 6502 `bit INPTx` is broken for input testing (ANDs with A); use `lda INPTx` and branch on N/Z as appropriate.
- Stella debugger: `print <expr>` evaluates; `print *<addr>` reads memory. `$XX`/`XX` both work. `ram` dumps zero page. `trap` sets read/write traps. `break`/`breakIf`/`clearTraps`. Symbol file may not be loaded; use raw hex addresses.
- `make game` builds the ROM; `make clean` removes `Dist/`.
