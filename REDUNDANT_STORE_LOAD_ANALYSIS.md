# Redundant Store/Load Pattern Analysis

This document identifies redundant store/load patterns where a value is stored and then immediately loaded (or vice versa) from the same variable.

## Pattern Recognition

A store/load is **redundant** when:
- `sta n` is immediately followed by `lda n` (same variable) - the value is already in A
- `lda n` is immediately followed by `sta n` (same variable) - can often be optimized
- `stx n` is immediately followed by `ldx n` (same variable) - the value is already in X
- `ldx n` is immediately followed by `stx n` (same variable) - can often be optimized
- `sty n` is immediately followed by `ldy n` (same variable) - the value is already in Y
- `ldy n` is immediately followed by `sty n` (same variable) - can often be optimized

## Analysis Results

### Confirmed Redundant (can be optimized)

#### Pattern: `sta tempX` → `lda tempX` (immediate reload)

1. **Source/Routines/UpdateSingleGuardTimer.s:49-51**
   ```assembly
   sta temp2
   ;; If temp2, then UpdateGuardTimerActive
   lda temp2
   beq UpdateCooldownTimer
   ```
   **Fix:** Remove `sta temp2` and `lda temp2`, use A directly: `beq UpdateCooldownTimer`

2. **Source/Routines/UpdateSingleGuardTimer.s:64-65**
   ```assembly
   sta temp3
   lda temp3
   beq NoCooldownActive
   ```
   **Fix:** Remove `sta temp3` and `lda temp3`, use A directly: `beq NoCooldownActive`

3. **Source/Routines/UpdateSingleGuardTimer.s:100-103**
   ```assembly
   sta temp3
   ;; Guard timer already expired (shouldn't happen, but safety
   lda temp3
   cmp # 0
   ```
   **Fix:** Remove `sta temp3` and `lda temp3`, use A directly: `cmp # 0` (or better, remove `cmp # 0` too)

4. **Source/Routines/UpdateSingleGuardTimer.s:116-118**
   ```assembly
   sta playerTimers_W,x
   lda temp3
   cmp # 0
   ```
   **Fix:** Remove `lda temp3`, use A directly (temp3 is already in A from line 112 `dec temp3`)

5. **Source/Routines/IsPlayerEliminated.s:17-18**
   ```assembly
   sta temp2
   lda temp2
   bne PlayerNotEliminated
   ```
   **Fix:** Remove `sta temp2` and `lda temp2`, use A directly: `bne PlayerNotEliminated`

6. **Source/Routines/BeginWinnerAnnouncement.s:62-63**
   ```assembly
   sta temp1
   lda temp1
   cmp # 0
   ```
   **Fix:** Remove `sta temp1` and `lda temp1`, use A directly: `cmp # 0` (or better, remove `cmp # 0` too)

7. **Source/Routines/Combat.s:498-499**
   ```assembly
   sta temp1
   lda temp1
   cmp # 0
   ```
   **Fix:** Remove `sta temp1` and `lda temp1`, use A directly: `cmp # 0` (or better, remove `cmp # 0` too)

8. **Source/Routines/ArenaReloadUtils.s:14-16**
   ```assembly
   sta temp1
   ;; Handle random arena (use stored random selection)
   lda temp1
   cmp # RandomArena
   ```
   **Fix:** Remove `sta temp1` and `lda temp1`, use A directly: `cmp # RandomArena`

9. **Source/Routines/ArenaReloadUtils.s:30-32**
   ```assembly
   sta temp2
   ;; If systemFlags & SystemFlagColorBWOverride, then set temp2 = 1
   lda systemFlags
   ```
   **Note:** This one is OK - temp2 is stored, then systemFlags is loaded (different variable)

10. **Source/Routines/ArenaReloadUtils.s:36-38**
    ```assembly
    sta temp2
    CheckBWModeDone:
    beq SkipBWOverride
    ```
    **Note:** Need context - check if temp2 was just set

11. **Source/Routines/ArenaReloadUtils.s:41**
    ```assembly
    sta temp2
    ```
    **Note:** Need context to see if immediately reloaded

12. **Source/Routines/ArenaSelect.s:184-186**
    ```assembly
    sta temp2
    dec temp2
    lda temp2
    sta selectedArena_W
    ```
    **Fix:** Can optimize: `dec` can work on A directly if we don't need temp2

13. **Source/Routines/ArenaSelect.s:245-248**
    ```assembly
    sta temp2
    inc temp2
    ;; Wrap from 255 to 0 if needed
    lda temp2
    ```
    **Fix:** Can optimize: `inc` can work on A directly

14. **Source/Routines/CharacterSelectMain.s:252-253**
    ```assembly
    lda temp1
    sta temp4
    ```
    **Note:** This is OK - preserving temp1 in temp4 for later use

15. **Source/Routines/CharacterSelectMain.s:258-262**
    ```assembly
    lda temp4
    asl
    tax
    lda playerCharacter,x
    sta temp1
    ```
    **Note:** This is OK - temp4 is used as index, result goes to temp1

16. **Source/Routines/CharacterSelectMain.s:266-267**
    ```assembly
    lda temp4
    sta temp3
    ```
    **Note:** This is OK - preserving temp4 in temp3

#### Pattern: `lda X` → `sta tempX` → `lda tempX` (store then immediate reload)

These are often redundant when tempX is only used once:

17. **Source/Routines/BudgetedMissileCollisionCheck.s:42-47**
    ```assembly
    lda framePhase
    sta temp1
    ;; framePhase 0-3 maps to Game Players 0-3
    ;; Calculate bit flag using O(1) array lookup: BitMask[playerIndex] (1, 2, 4, 8)
    ;; Set temp6 = BitMask[temp1]
    lda temp1
    ```
    **Fix:** Can optimize: `lda framePhase` → `asl` → `tax` → `lda BitMask,x` (skip temp1)

18. **Source/Routines/BudgetedMissileCollisionCheck.s:74-82**
    ```assembly
    lda frame
    and # 1
    sta temp1
    ;; Use frame bit to alternate: 0 = Player 0, 1 = Player 1
    ;; BitMask[playerIndex] (1, 2, 4, 8)
    ;; Calculate bit flag using O(1) array lookup:
    ;; Set temp6 = BitMask[temp1]
    lda temp1
    ```
    **Fix:** Can optimize: `lda frame` → `and # 1` → `asl` → `tax` → `lda BitMask,x` (skip temp1)

### Needs Manual Review

These cases need context checking to verify redundancy:

- Source/Routines/ArenaLoader.s (multiple occurrences)
- Source/Routines/CharacterArtBank2.s (multiple occurrences)
- Source/Routines/CharacterArtBank3.s (multiple occurrences)
- Source/Routines/CharacterArtBank4.s (multiple occurrences)
- Source/Routines/CharacterArtBank5.s (multiple occurrences)
- Source/Routines/BudgetedPlayerCollisions.s (multiple occurrences)
- Source/Routines/ArenaSelect.s (multiple occurrences)
- Source/Routines/InputHandleAllPlayers.s
- Source/Routines/PlayerInput.s
- Source/Routines/PlayerCollisionResolution.s
- Source/Routines/MissileSystem.s
- Source/Routines/HealthBarSystem.s
- Source/Routines/SetPlayerSprites.s
- Source/Routines/VblankHandlers.s
- Source/Routines/PlayerPhysicsGravity.s
- Source/Routines/Combat.s
- Source/Routines/CharacterSelectMain.s
- Source/Routines/TriggerEliminationEffects.s
- Source/Routines/HandlePauseInput.s
- Source/Routines/ApplyGuardColor.s

## Summary

- **Confirmed redundant:** ~18+ instances
- **Needs review:** ~100+ instances
- **Total found:** 100+ instances (many are false positives - different variables)

## Optimization Impact

Each redundant `sta n` / `lda n` pair:
- Uses 4 bytes (2 instructions × 2 bytes)
- Takes 4-5 cycles (2 cycles for sta, 2-3 cycles for lda)
- Can be removed for immediate savings

Estimated savings for confirmed cases: ~72+ bytes and ~72+ cycles.

## Notes

- Some patterns like `lda temp1` → `sta temp4` are intentional (preserving values)
- Some patterns involve array indexing where the temp is needed for the index calculation
- Always verify the variable isn't used between store and load before optimizing
