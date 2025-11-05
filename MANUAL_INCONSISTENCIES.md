# Manual vs Requirements vs Code Inconsistencies

## User Clarifications (Confirmed)

### 1. Dragon of Storms (Character 2) ✅ CONFIRMED
- **Attack Type**: RANGED
- **Details**: Fires ranged fireballs that slowly arc downwards. No melee. 2×2 missile.
- **Current Code**: `goto PerformMeleeAttack` ❌ WRONG
- **Action Needed**: Fix code to call `PerformRangedAttack`, fix comment

### 2. Fat Tony (Character 4) ✅ CONFIRMED
- **Attack Type**: RANGED
- **Details**: Magic ring lasers shoot across screen very quickly, pass through walls. Thin, wide missile.
- **Current Code**: `goto PerformRangedAttack` ✅ CORRECT
- **Action Needed**: Fix comment only (says "Melee Attack" but should say "Ranged Attack")

### 3. Megax (Character 5) ✅ CONFIRMED
- **Attack Type**: MELEE (with decorative missile)
- **Details**: Uses missile to decorate a melee attack (fire breath). Missile never moves.
- **Current Code**: `goto PerformMeleeAttack` ✅ CORRECT
- **Action Needed**: Fix data table (currently says RANGED, should be MELEE)

### 4. Knight Guy (Character 7) ✅ CONFIRMED
- **Attack Type**: MELEE (with decorative missile)
- **Details**: Uses missile to decorate a melee attack (sword). Missile slides away from/toward character slightly as if sword being "poked" out.
- **Current Code**: `goto PerformRangedAttack` ❌ WRONG
- **Action Needed**: Fix code to call `PerformMeleeAttack`, fix comment

### 5. Ninjish Guy (Character 10) ✅ CONFIRMED
- **Attack Type**: RANGED
- **Details**: Small shuriken, fast-moving, slight upward arc when tossed.
- **Current Code**: `goto PerformRangedAttack` ✅ CORRECT
- **Action Needed**: Fix data table (currently says MELEE, should be RANGED)

## Interview Questions - Remaining Characters

Please confirm the attack patterns for these characters:

### 0. Bernie ✅ Already Confirmed
- **Attack Type**: MELEE (Ground Thump AOE, both directions)
- **Status**: Code matches

### 1. Curler (Curling Sweeper)
- **Manual**: "Ranged" (curling stone)
- **Requirements**: "Ranged - 4×4 pixel wide, tall ground-based projectile"
- **Code**: `goto PerformRangedAttack` ✅
- **Question**: Confirm - Curler fires a curling stone projectile that slides along the ground? No melee?

### 3. Zoe Ryen
- **Manual**: Need to check
- **Requirements**: "Ranged - 4×1 pixel wide, low-height projectile" (laser blaster)
- **Code**: `goto PerformRangedAttack` ✅
- **Question**: Confirm - Zoe Ryen fires a horizontal laser that travels across screen? No melee?

### 6. Harpy
- **Manual**: "Ranged" (diagonal swoop)
- **Requirements**: "Ranged - No missile sprite (diagonal swoop attack - character movement IS the attack)"
- **Code**: Special swoop attack (no PerformRangedAttack/MeleeAttack call)
- **Question**: Confirm - Harpy's attack is a diagonal swoop where the character moves and hits during movement? No separate projectile?

### 8. Frooty
- **Manual**: "Ranged (magical sparkles)"
- **Requirements**: "Ranged - 1×1 pixel narrow projectile (magical sparkles)"
- **Code**: `goto PerformRangedAttack` ✅
- **Question**: Confirm - Frooty fires small magical sparkle projectiles? Any special properties?

### 9. Nefertem
- **Manual**: Need to check
- **Requirements**: "Melee attacks only (no projectiles)"
- **Code**: `goto PerformMeleeAttack` ✅
- **Question**: Confirm - Nefertem is pure melee, no projectiles?

### 11. Pork Chop
- **Manual**: Need to check
- **Requirements**: "Melee attacks only (no projectiles)"
- **Code**: `goto PerformMeleeAttack` ✅
- **Question**: Confirm - Pork Chop is pure melee, no projectiles?

### 12. Radish Goblin
- **Manual**: Need to check
- **Requirements**: "Melee (bouncing bite attacks)"
- **Code**: `goto PerformMeleeAttack` ✅
- **Question**: Confirm - Radish Goblin is melee with bouncing bite attacks? Any special mechanics?

### 13. Robo Tito
- **Manual**: "Melée"
- **Requirements**: "Melee attacks only (no projectiles)"
- **Code**: `goto PerformMeleeAttack` ✅
- **Question**: Confirm - RoboTito is pure melee, no projectiles?

### 14. Ursulo
- **Manual**: Need to check
- **Requirements**: "Melee (claw swipe)" - changed from ranged to melee
- **Code**: `goto PerformMeleeAttack` ✅
- **Question**: Confirm - Ursulo uses melee claw swipe attacks? Any decorative missile like Knight Guy?

### 15. Shamone
- **Manual**: Need to check
- **Requirements**: "Melee attacks only (no projectiles)"
- **Code**: `goto PerformMeleeAttack` ✅
- **Question**: Confirm - Shamone is pure melee, no projectiles? Any special mechanics with the upward attack/jump?

## Summary

**Confirmed Fixes Needed:**
1. Dragon of Storms - Change code to RANGED
2. Fat Tony - Fix comment only
3. Megax - Fix data table to MELEE
4. Knight Guy - Change code to MELEE
5. Ninjish Guy - Fix data table to RANGED

**Awaiting Confirmation:**
- Curler, Zoe Ryen, Harpy, Frooty, Nefertem, Pork Chop, Radish Goblin, RoboTito, Ursulo, Shamone

