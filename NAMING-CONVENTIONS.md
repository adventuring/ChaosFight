# ChaosFight Naming Conventions

## Built-in batariBasic Identifiers (lowercase)

These are reserved by batariBasic and must remain **lowercase**.

**IMPORTANT**: Built-in variables **do NOT need `dim` statements** - they already exist!

### Temporary Variables
- `temp1`, `temp2`, `temp3`, `temp4`, `temp5`, `temp6` (some say `temp7` exists but avoid it)
- **Note**: These are obliterated (reset) when `drawscreen` is called
- **No dim needed** - these already exist in batariBasic

### Controller/Input Variables
- `qtcontroller` - Quadtari controller multiplexing state (0 or 1)
- `joy0up`, `joy0down`, `joy0left`, `joy0right`, `joy0fire`
- `joy1up`, `joy1down`, `joy1left`, `joy1right`, `joy1fire`
- **No dim needed** - these are built-in

### System Variables
- `frame` - Built-in frame counter
- **No dim needed** - this is built-in

### Display Registers (TIA)
- `player0x`, `player0y`, `player1x`, `player1y`
- `missile0x`, `missile0y`, `missile1x`, `missile1y`
- `ballx`, `bally`
- `COLUP0`, `COLUP1`, `COLUBK`, `COLUPF`
- `NUSIZ0`, `NUSIZ1`
- `REFP0`, `REFP1`
- `pf0`-`pf11` (playfield registers)
- `pfpixel`
- And all other TIA registers

### Keywords and Commands
- `dim`, `if`, `then`, `else`, `endif`
- `goto`, `gosub`, `return`
- `for`, `next`
- `data`, `end`
- `drawscreen`
- `bank`, `thisbank`
- `rand`
- And all other batariBasic keywords

## User-Defined Identifiers (PascalCase)

All variables, labels, and identifiers we create should use **PascalCase**:

### Our Program Variables
- `GameState` - not `gameState`
- `QuadtariDetected` - not `QuadtariDetected` or `quadtaridetected`
- `ReadyCount`
- `PlayerX`, `PlayerY`, `PlayerState`, `PlayerHealth`, etc.
- `SelectedChar1`, `SelectedChar2`, etc.
- `CharSelectAnimTimer`, `CharSelectAnimState`
- All other user-defined variables

### Our Program Labels
- `GameMainLoop` - not `game_main_loop` or `gamemainloop`
- `HandlePlayerInput`
- `CheckAllPlayersReady`
- `DrawCharacterSelect`
- All other user-defined labels

### Important Notes

**Do NOT dim built-in variables!**
```bataribasic
rem WRONG - do not do this:
dim temp1 = a         ❌
dim frame = f         ❌
dim qtcontroller = e  ❌

rem CORRECT - built-ins already exist, just use them:
temp1 = PlayerX[0]    ✓
if frame > 60 then    ✓
qtcontroller = 1      ✓

rem Our variables DO need dim:
dim GameState = g     ✓ Our variable - PascalCase
```

## Summary

**Rule of thumb:**
- If it's in the batariBasic documentation as a built-in feature → **lowercase**
- If we created it for our game → **PascalCase**

## References

- [batariBasic Commands Reference](https://www.randomterrain.com/atari-2600-memories-batari-basic-commands.html)
- batariBasic documentation states: "temp1 through temp6 as temporary storage"
- All built-in batariBasic identifiers are lowercase by convention

