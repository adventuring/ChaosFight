# Syntax Error and Variable Mutation Report

## Summary

This report documents:
1. **Violations**: Call sites using `temp1-temp6` directly instead of local aliases
2. **Mutated Variables**: Subroutines that mutate temp variables (return values and side effects)
3. **Documentation Gaps**: Missing remarks about mutated temp variables

---

## 1. CRITICAL: Using temp1-temp6 Instead of Local Aliases

### FallingAnimation.bas

**Subroutine**: `MovePlayerToTarget` defines:
- `MPTT_playerIndex = temp1`
- `MPTT_targetX = temp2`
- `MPTT_targetY = temp3`
- `MPTT_reached = temp4` (return value)

**Violations** (4 instances):
- **Line 48-50**: Using `temp1`, `temp2`, `temp3` instead of `MPTT_playerIndex`, `MPTT_targetX`, `MPTT_targetY`
- **Line 71-73**: Same violation
- **Line 87-89**: Same violation
- **Line 103-105**: Same violation

**Current Code**:
```basic
let temp1 = FA1_playerIndex
let temp2 = FA1_targetX
let temp3 = FA1_targetY
gosub MovePlayerToTarget
let FA1_reached = temp4
```

**Should Be**:
```basic
let MPTT_playerIndex = FA1_playerIndex
let MPTT_targetX = FA1_targetX
let MPTT_targetY = FA1_targetY
gosub MovePlayerToTarget
let FA1_reached = MPTT_reached
```

---

### MovementSystem.bas

**Subroutine**: `UpdatePlayerMovementSingle` defines:
- `UPS_playerIndex = temp1`

**Violations** (4 instances):
- **Line 41**: Using `temp1` instead of `UPS_playerIndex`
- **Line 45**: Same violation
- **Line 49**: Same violation
- **Line 52**: Same violation

**Current Code**:
```basic
let UPM_playerIndex = 0
let temp1 = UPM_playerIndex
gosub UpdatePlayerMovementSingle
```

**Should Be**:
```basic
let UPM_playerIndex = 0
let UPS_playerIndex = UPM_playerIndex
gosub UpdatePlayerMovementSingle
```

**Note**: This is a cross-subroutine call, so `UPS_playerIndex` is the called subroutine's alias.

---

**Subroutine**: `GetPlayerPosition` defines:
- `GPP_playerIndex = temp1` (input)
- `GPP_positionX = temp2` (output)
- `GPP_positionY = temp3` (output)

**Violations** (2 instances):
- **Line 174-175**: Assigning to `temp2`, `temp3` instead of aliases (though this is the return path, so may be acceptable)

**Current Code**:
```basic
let GPP_positionX = playerX[GPP_playerIndex]
let GPP_positionY = playerY[GPP_playerIndex]
let temp2 = GPP_positionX
let temp3 = GPP_positionY
return
```

**Should Be** (caller perspective):
Callers should read from `GPP_positionX` and `GPP_positionY` after the call, not from `temp2`/`temp3`.

---

**Subroutine**: `GetPlayerVelocity` defines:
- `GPV_playerIndex = temp1` (input)
- `GPV_velocityX = temp2` (output)
- `GPV_velocityY = temp3` (output)

**Violations** (2 instances):
- **Line 187-188**: Similar issue as GetPlayerPosition

---

**Subroutine**: `CheckPlayerCollision` defines:
- `CPC_player1Index = temp1` (input)
- `CPC_player2Index = temp2` (input)
- `CPC_collisionResult = temp3` (output)

**Violations** (2 instances):
- **Line 308**: Assigning to `temp3` instead of `CPC_collisionResult`
- **Line 313**: Same violation

**Current Code**:
```basic
let CPC_collisionResult = 1
let temp3 = CPC_collisionResult
return
```

**Should Be**: Callers should read from `CPC_collisionResult`, not `temp3`.

---

### SpriteLoader.bas

**Subroutine**: `LocateCharacterArt` (in bank10) expects:
- `temp1 = character index`
- `temp2 = animation frame`
- `temp3 = action`
- `temp4 = player number`

**Note**: This subroutine does NOT define local aliases, so using `temp1-temp4` is acceptable.

**However**, the calling code should still use meaningful names when setting up arguments:
- **Line 108-111**: Uses `temp1-temp4` directly (acceptable since LocateCharacterArt has no aliases)
- **Line 332**: Uses `temp1` directly (acceptable)

**Subroutine**: `LoadCharacterColors` defines:
- `LoadCharacterColors_isHurt = temp2` (input)
- `LoadCharacterColors_playerNumber = temp3` (input)
- `LoadCharacterColors_isFlashing = temp4` (input)
- `LoadCharacterColors_flashingMode = temp5` (input)
- `LoadCharacterColors_color = temp6` (internal, may be mutated)

**Violations**:
- **LevelSelect.bas Line 406-409**: Uses `temp2`, `temp3`, `temp4`, `temp5` directly instead of aliases
- **PlayerRendering.bas Line 371, 374-376**: Uses `temp2`, `temp4`, `temp5` directly instead of aliases (4 instances)

**Current Code** (PlayerRendering.bas):
```basic
let temp2 = SPS_isHurt
rem temp3 = player number (already set via SPS_playerNum alias)
rem temp4 = flashing state (0=not flashing)
let temp4 = 0
rem temp5 = flashing mode (not used when not flashing)
let temp5 = 0
gosub bank10 LoadCharacterColors
```

**Should Be**:
```basic
let LoadCharacterColors_isHurt = SPS_isHurt
rem LoadCharacterColors_playerNumber already set via SPS_playerNum
let LoadCharacterColors_isFlashing = 0
let LoadCharacterColors_flashingMode = 0
gosub bank10 LoadCharacterColors
```

---

### DisplayWinScreen.bas

**Subroutine**: `LoadCharacterSprite` defines:
- `LCS_characterIndex = temp1` (input)
- `LCS_animationFrame = temp2` (input)
- `LCS_playerNumber = temp3` (input)

**Violations** (multiple instances):
- **Line 119-122**: Using `temp1`, `temp2`, `temp3` directly instead of aliases
- **Line 136-138**: Same violation
- **Line 145-147**: Same violation
- **Line 164-166**: Same violation
- **Line 173-175**: Same violation
- **Line 186-188**: Same violation

**Current Code**:
```basic
let temp1 = playerChar[DWS_winnerIndex]
let temp2 = 0
rem Animation frame 0 (idle)
let temp3 = 0
rem Player 0
gosub bank10 LoadCharacterSprite
```

**Should Be**:
```basic
let LCS_characterIndex = playerChar[DWS_winnerIndex]
let LCS_animationFrame = 0
let LCS_playerNumber = 0
gosub bank10 LoadCharacterSprite
```

---

### PlayerElimination.bas

**Subroutine**: `CheckPlayerElimination` defines:
- `CPE_playerIndex = temp1` (input)
- `CPE_bitMask = temp6` (internal)
- `CPE_isEliminated = temp2` (internal, may be mutated)
- `CPE_health = temp2` (internal, reuses temp2)

**Violations** (4 instances):
- **Line 36**: Using `temp1` instead of `CPE_playerIndex`
- **Line 39**: Same violation
- **Line 42**: Same violation
- **Line 45**: Same violation

**Current Code**:
```basic
let CAPE_playerIndex = 0
let temp1 = CAPE_playerIndex
gosub CheckPlayerElimination
```

**Should Be**:
```basic
let CAPE_playerIndex = 0
let CPE_playerIndex = CAPE_playerIndex
gosub CheckPlayerElimination
```

---

## 2. Mutated Variables Documentation

### Subroutines That Mutate Temp Variables

#### MovePlayerToTarget (FallingAnimation.bas)
- **Mutates**: `temp4` → `MPTT_reached` (return value: 1 if reached target, 0 if still moving)
- **Mutates**: `temp5`, `temp6` → Used internally for calculations
- **Side Effects**: Modifies `playerX[temp1]`, `playerY[temp1]` toward target
- **WARNING**: Callers should not use `temp4`, `temp5`, `temp6` after calling this subroutine

#### GetPlayerPosition (MovementSystem.bas)
- **Mutates**: `temp2` → `GPP_positionX` (return value: X position)
- **Mutates**: `temp3` → `GPP_positionY` (return value: Y position)
- **WARNING**: Callers should read from `GPP_positionX`/`GPP_positionY` aliases, not `temp2`/`temp3`

#### GetPlayerVelocity (MovementSystem.bas)
- **Mutates**: `temp2` → `GPV_velocityX` (return value: X velocity)
- **Mutates**: `temp3` → `GPV_velocityY` (return value: Y velocity)
- **WARNING**: Callers should read from `GPV_velocityX`/`GPV_velocityY` aliases, not `temp2`/`temp3`

#### CheckPlayerCollision (MovementSystem.bas)
- **Mutates**: `temp3` → `CPC_collisionResult` (return value: 1 if collision, 0 if not)
- **Mutates**: `temp4-temp13` → Used internally for calculations
- **WARNING**: Callers should read from `CPC_collisionResult` alias, not `temp3`. All temp4-temp13 are mutated.

#### LoadCharacterColors (SpriteLoader.bas)
- **Mutates**: `temp6` → `LoadCharacterColors_color` (internal calculation, may be read by caller)
- **Side Effects**: Sets `COLUP0-3` or `_COLUP1` based on player number
- **WARNING**: `temp6` is mutated during execution

#### UpdatePlayerMovementSingle (MovementSystem.bas)
- **Mutates**: `temp2` → `UPS_subpixelSum` (internal calculation)
- **Mutates**: `temp4` → `UPS_subpixelXRead` (internal SCRAM read-modify-write)
- **Side Effects**: Modifies `playerX[]`, `playerY[]`, `playerSubpixelX_W[]`, `playerSubpixelY_W[]`
- **WARNING**: `temp2`, `temp4` are mutated during execution

#### CheckPlayerElimination (PlayerElimination.bas)
- **Mutates**: `temp2` → `CPE_isEliminated` / `CPE_health` (reused, internal)
- **Mutates**: `temp6` → `CPE_bitMask` (internal)
- **Side Effects**: Sets `playersEliminated` bit flags
- **WARNING**: `temp2`, `temp6` are mutated during execution

---

## 3. Documentation Gaps

### Missing "Mutated Variables" Remarks

The following subroutines need documentation about mutated temp variables:

1. **MovePlayerToTarget** (FallingAnimation.bas:153)
   - **Current**: Documents input/output but doesn't warn about temp4-temp6 mutation
   - **Needed**: Add warning about temp4-temp6 being mutated

2. **GetPlayerPosition** (MovementSystem.bas:168)
   - **Current**: Documents output as temp2/temp3
   - **Needed**: Document that callers should read from GPP_positionX/GPP_positionY aliases

3. **GetPlayerVelocity** (MovementSystem.bas:181)
   - **Current**: Documents output as temp2/temp3
   - **Needed**: Document that callers should read from GPV_velocityX/GPV_velocityY aliases

4. **CheckPlayerCollision** (MovementSystem.bas:241)
   - **Current**: Documents output as temp3
   - **Needed**: Warn that temp3-temp13 are mutated, use CPC_collisionResult alias

5. **UpdatePlayerMovementSingle** (MovementSystem.bas:61)
   - **Current**: Only documents input
   - **Needed**: Document that temp2, temp4 are mutated internally

6. **CheckPlayerElimination** (PlayerElimination.bas:60)
   - **Current**: Only documents input
   - **Needed**: Document that temp2, temp6 are mutated internally

7. **LoadCharacterColors** (SpriteLoader.bas:403)
   - **Current**: Documents inputs but not temp6 mutation
   - **Needed**: Document that temp6 is mutated during execution

---

## 4. Recommended Documentation Format

For each subroutine that mutates temp variables, add a section like:

```basic
          rem MUTATES:
          rem   temp4 = MPTT_reached (return value: 1 if reached, 0 if moving)
          rem   temp5, temp6 = Internal calculations (do not use after call)
          rem WARNING: Callers should read from MPTT_reached alias, not temp4
          rem   directly. Do not use temp5 or temp6 after calling this
          rem   subroutine.
```

---

## 5. Summary Statistics

- **Total Violations Found**: ~30+ instances of using temp1-temp6 instead of local aliases
- **Subroutines with Missing Mutation Documentation**: 7
- **Files Affected**: 6 (FallingAnimation.bas, MovementSystem.bas, SpriteLoader.bas, PlayerElimination.bas, PlayerRendering.bas, LevelSelect.bas, DisplayWinScreen.bas)

---

## Next Steps

1. Fix all violations to use local aliases instead of temp1-temp6
2. Add mutation documentation to all affected subroutines
3. Review all call sites to ensure they don't accidentally use mutated temp values
4. Consider adding a linting rule or code review checklist item for this pattern

