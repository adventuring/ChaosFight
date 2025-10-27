# Variable Memory Conflicts - FIXED

## Critical Issue Discovered

During gameplay with `pfres=8`, the playfield occupies SuperChip RAM from `var24` to `var95` (72 bytes). This means **only var0-var23 are available** for game variables during gameplay!

## Problems Found

### ❌ BEFORE (Broken):
```bataribasic
dim PlayerMomentumX = var24, var25, var26, var27  ❌ Conflicts with playfield!
dim Missile1X = var32                              ❌ Conflicts with playfield!
dim Missile2X = var39                              ❌ Conflicts with playfield!
```

These variables would **corrupt the playfield graphics** during gameplay!

## Solutions Implemented

### ✅ AFTER (Fixed):

1. **Moved PlayerMomentumX to var20-var23** (within safe range)
2. **Removed PlayerDamage** array (calculate on-the-fly from character data)
3. **Removed PlayerTimers** (attack cooldown) - use frame-based checks instead
4. **Moved Missile system to Standard RAM** - reuse character select variables (w-z) during gameplay

### Variable Reuse Strategy

**Character Select Variables (w, x, y, z):**
- During character select: Used for animation state
- During gameplay: Reused for missile positions

**ReadyCount (i):**
- During character select: Counts how many players are ready
- During gameplay: Reused as `MissilePackedData` for missile flags

This is safe because these contexts never overlap!

## Memory Layout Summary

### Standard RAM (a-z): 26 bytes - Always Available
```
a-d   = temp1-temp4 (built-in)
e     = qtcontroller (built-in)
f     = frame (built-in)
g     = GameState
h     = QuadtariDetected
i     = ReadyCount / MissilePackedData (context-dependent)
j-m   = PlayerChar[0-3]
n-q   = PlayerLocked[0-3]
r-v   = SelectedChar1-4, SelectedLevel
w-z   = CharSelectAnim* / Missile positions (context-dependent)
```

### SuperChip RAM During Gameplay (pfres=8)
```
var0-3    = PlayerX[0-3]              ✓ SAFE
var4-7    = PlayerY[0-3]              ✓ SAFE
var8-11   = PlayerState[0-3]          ✓ SAFE
var12-15  = PlayerHealth[0-3]         ✓ SAFE
var16-19  = PlayerRecoveryFrames[0-3] ✓ SAFE
var20-23  = PlayerMomentumX[0-3]      ✓ SAFE (moved from var24-27)
var24-95  = PLAYFIELD DATA            ⚠️ DO NOT USE!
```

### SuperChip RAM During Title/Preambles (pfres=12 or pfres=32)
```
var0-47   = Available for variables   ✓ SAFE
var28-31  = TitleParade* variables    ✓ SAFE (only used on title screen)
var48+    = PLAYFIELD DATA            ⚠️ DO NOT USE!
```

## Rules to Prevent Future Conflicts

1. **Never use var24+ during gameplay** (pfres=8 active)
2. **Never use var48+ during title screens** (pfres=12 or pfres=32 active)
3. **Document all variable reuse** with clear comments about context
4. **Check pfres settings** before allocating SuperChip variables
5. **Prefer standard RAM (a-z)** for frequently-accessed variables

## Verification Commands

Check for conflicts:
```bash
# Find any var24+ usage during gameplay
grep -rn "var2[4-9]\|var[3-9][0-9]" Source/Routines/Game*.bas Source/Routines/Combat.bas

# Find any var48+ usage during title screens
grep -rn "var[4-9][8-9]" Source/Routines/Title*.bas Source/Routines/*Preamble.bas
```

## References

- [batariBasic SuperChip Variables Documentation](https://www.randomterrain.com/atari-2600-memories-batari-basic-commands.html#superchip_variables)
- batariBasic documentation states: "With pfres=8, you have var0-var23 available"
- ChaosFight uses pfres=8 for gameplay, pfres=32 for title screens

