# Redundant Compare Analysis

This document identifies `cmp # 0` / `cpx # 0` / `cpy # 0` instructions that are redundant because the Z flag is already set by a previous operation.

## Pattern Recognition

A compare to zero is **redundant** when immediately preceded by an instruction that sets the Z flag:
- `lda` - Load Accumulator sets Z flag
- `ldx` / `ldy` - Load X/Y sets Z flag  
- `adc` / `sbc` - Add/Subtract with carry set Z flag
- `and` / `ora` / `eor` - Logical operations set Z flag
- `tax` / `tay` / `txa` / `tya` - Transfer operations set Z flag
- `asl` / `lsr` / `rol` / `ror` - Shift operations set Z flag
- `dec` / `inc` - Decrement/Increment set Z flag
- `bit` - Bit test sets Z flag

## Analysis Results

### Confirmed Redundant (can be removed)

#### Pattern: `lda X` → `cmp # 0` → `beq/bne`

1. **Source/Routines/CharacterSelectFire.s:57**
   ```assembly
   lda temp1
   cmp # 0
   bne CheckPlayer2Joy
   ```
   **Fix:** Remove `cmp # 0`, use `bne CheckPlayer2Joy` directly

2. **Source/Routines/InputHandleAllPlayers.s:80**
   ```assembly
   lda temp2
   cmp # 0
   bne CheckPlayer0State
   ```
   **Fix:** Remove `cmp # 0`

3. **Source/Routines/InputHandleAllPlayers.s:123**
   ```assembly
   lda temp2
   cmp # 0
   bne CheckPlayer1State
   ```
   **Fix:** Remove `cmp # 0`

4. **Source/Routines/InputHandleAllPlayers.s:263**
   ```assembly
   lda temp2
   cmp # 0
   bne CheckPlayer3State
   ```
   **Fix:** Remove `cmp # 0`

5. **Source/Routines/Combat.s:500**
   ```assembly
   lda temp1
   cmp # 0
   bne CheckProjectileHitbox
   ```
   **Fix:** Remove `cmp # 0`

6. **Source/Routines/FrootyAttack.s:76**
   ```assembly
   lda temp2
   cmp # 0
   bne CheckJoy1Fire
   ```
   **Fix:** Remove `cmp # 0`

7. **Source/Routines/BeginWinnerAnnouncement.s:64**
   ```assembly
   lda temp1
   cmp # 0
   bne CheckPlayer1Character
   ```
   **Fix:** Remove `cmp # 0`

8. **Source/Routines/CharacterSelect.s:425**
   ```assembly
   lda temp1
   cmp # 0
   bne CheckPlayer2Joy0
   ```
   **Fix:** Remove `cmp # 0`

9. **Source/Routines/HealthBarSystem.s:645**
   ```assembly
   lda temp1
   cmp # 0
   bne P3ConvertHealth
   ```
   **Fix:** Remove `cmp # 0`

10. **Source/Routines/HealthBarSystem.s:708**
    ```assembly
    lda temp2
    cmp # 0
    ```
    **Fix:** Check context - likely redundant

11. **Source/Routines/CharacterAttacksDispatch.s:231**
    ```assembly
    lda currentPlayer
    cmp # 0
    bne CheckPlayer1Enhanced
    ```
    **Fix:** Remove `cmp # 0`

12. **Source/Routines/UpdateSingleGuardTimer.s:104**
    ```assembly
    lda temp3
    cmp # 0
    bne SkipExpiredCheck
    ```
    **Fix:** Remove `cmp # 0`

13. **Source/Routines/UpdateSingleGuardTimer.s:119**
    ```assembly
    lda temp3
    cmp # 0
    bne GuardTimerStillActive
    ```
    **Fix:** Remove `cmp # 0`

#### Pattern: `and # X` → `cmp # 0` → `beq/bne`

14. **Source/Routines/InputHandleAllPlayers.s:242**
    ```assembly
    lda controllerStatus
    and # SetQuadtariDetected
    cmp # 0
    bne CheckPlayer3Character
    ```
    **Fix:** Remove `cmp # 0` (and sets Z flag)

15. **Source/Routines/InputHandleAllPlayers.s:297**
    ```assembly
    lda controllerStatus
    and # SetQuadtariDetected
    cmp # 0
    ```
    **Fix:** Remove `cmp # 0`

16. **Source/Routines/ApplyMomentumAndRecovery.s:57**
    ```assembly
    lda controllerStatus
    and # SetQuadtariDetected
    cmp # 0
    bne CheckPlayer2NoCharacter
    ```
    **Fix:** Remove `cmp # 0`

17. **Source/Routines/GameLoopMain.s:230**
    ```assembly
    lda controllerStatus
    and # SetQuadtariDetected
    cmp # 0
    bne FrootyChargeUpdate
    ```
    **Fix:** Remove `cmp # 0`

18. **Source/Routines/HealthBarSystem.s:614**
    ```assembly
    lda controllerStatus
    and # SetQuadtariDetected
    cmp # 0
    bne UpdatePlayer34Health
    ```
    **Fix:** Remove `cmp # 0`

19. **Source/Routines/BeginFallingAnimation.s:144**
    ```assembly
    lda controllerStatus
    and # SetQuadtariDetected
    cmp # 0
    bne CheckPlayer3Character
    ```
    **Fix:** Remove `cmp # 0`

20. **Source/Routines/BeginFallingAnimation.s:190**
    ```assembly
    lda controllerStatus
    and # SetQuadtariDetected
    cmp # 0
    bne CheckPlayer4Character
    ```
    **Fix:** Remove `cmp # 0`

21. **Source/Routines/CharacterAttacksDispatch.s:298**
    ```assembly
    lda controllerStatus
    and # 4
    cmp # 0
    bne CEJB_ReadButton2Label
    ```
    **Fix:** Remove `cmp # 0`

22. **Source/Routines/CharacterAttacksDispatch.s:329**
    ```assembly
    lda controllerStatus
    and # 8
    cmp # 0
    bne CEJB_ReadButton2Label2
    ```
    **Fix:** Remove `cmp # 0`

23. **Source/Routines/FallingAnimation.s:248**
    ```assembly
    lda controllerStatus
    and # SetQuadtariDetected
    cmp # 0
    bne MovePlayer3
    ```
    **Fix:** Remove `cmp # 0`

24. **Source/Routines/FallingAnimation.s:305**
    ```assembly
    lda controllerStatus
    and # SetQuadtariDetected
    cmp # 0
    bne MovePlayer4
    ```
    **Fix:** Remove `cmp # 0`

25. **Source/Routines/ArenaSelect.s:865**
    ```assembly
    lda controllerStatus
    and # SetQuadtariDetected
    cmp # 0
    bne CheckPlayer3Character
    ```
    **Fix:** Remove `cmp # 0`

26. **Source/Routines/BudgetedMissileCollisions.s:22**
    ```assembly
    lda controllerStatus
    and # SetQuadtariDetected
    cmp # 0
    bne Use4PlayerMode
    ```
    **Fix:** Remove `cmp # 0`

#### Pattern: `and # X` (bit test) → `cmp # 0` → `beq/bne`

27. **Source/Routines/CharacterControlsDown.s:735**
    ```assembly
    lda characterStateFlags_R[temp1]
    and 1
    cmp # 0
    bne RoboTitoInitiateDrop
    ```
    **Fix:** Remove `cmp # 0`

28. **Source/Routines/CharacterDownHandlers.s:726**
    ```assembly
    lda characterStateFlags_R[temp1]
    and 1
    cmp # 0
    bne RoboTitoInitiateDrop
    ```
    **Fix:** Remove `cmp # 0`

#### Pattern: `INPTX and # 128` → `cmp # 0` → `beq/bne`

29. **Source/Routines/GameLoopMain.s:58**
    ```assembly
    lda INPT2
    and # 128
    cmp # 0
    bne ReadEnhancedButtonsDone
    ```
    **Fix:** Remove `cmp # 0`

30. **Source/Routines/CharacterAttacksDispatch.s:310**
    ```assembly
    lda INPT2
    and # 128
    cmp # 0
    bne CEJB_DonePlayer2
    ```
    **Fix:** Remove `cmp # 0`

#### Pattern: `lda X` → `cmp # 0` → `beq` (check for zero)

31. **Source/Routines/CheckPlayerCollision.s:34**
    ```assembly
    lda temp3
    cmp # 0
    beq CPC_Done
    ```
    **Fix:** Remove `cmp # 0`, use `beq CPC_Done` directly

32. **Source/Routines/BudgetedHealthBars.s:28**
    ```assembly
    lda framePhase
    cmp # 0
    bne CheckPhase1
    ```
    **Fix:** Remove `cmp # 0`

33. **Source/Routines/BudgetedPlayerCollisions.s:44**
    ```assembly
    lda framePhase
    cmp # 0
    bne BPC_CheckPhase0
    ```
    **Fix:** Remove `cmp # 0`

34. **Source/Routines/ArenaSelect.s:167**
    ```assembly
    lda selectedArena_R
    cmp # 0
    bne CheckRandomArenaLeft
    ```
    **Fix:** Remove `cmp # 0`

### Needs Manual Review

These cases need context checking to verify redundancy:

- Source/Routines/MissileSystem.s (multiple occurrences)
- Source/Routines/PlayerInput.s (multiple occurrences)
- Source/Routines/PlayerCollisionResolution.s (multiple occurrences)
- Source/Routines/PlayerPhysicsGravity.s (multiple occurrences)
- Source/Routines/VblankHandlers.s (multiple occurrences)
- Source/Routines/SetSpritePositions.s (multiple occurrences)
- Source/Routines/SetPlayerSprites.s (multiple occurrences)
- Source/Routines/MissileCollision.s (multiple occurrences)
- Source/Routines/HealthBarSystem.s (multiple occurrences)
- Source/Routines/HandleFlyingCharacterMovement.s (multiple occurrences)
- Source/Routines/CharacterSelectMain.s (multiple occurrences)
- Source/Routines/TriggerEliminationEffects.s (multiple occurrences)
- Source/Routines/StandardGuard.s
- Source/Routines/UpdateAttackCooldowns.s
- Source/Routines/TitleScreenRender.s
- Source/Routines/RadishGoblinMovement.s
- Source/Routines/ProcessUpAction.s
- Source/Routines/ProcessJumpInput.s
- Source/Routines/MusicSystem.s
- Source/Routines/MusicBankHelpers15.s
- Source/Routines/MissileCharacterHandlers.s
- Source/Routines/FallDamage.s
- Source/Routines/BeginWinnerAnnouncement.s

## Summary

- **Confirmed redundant:** ~34+ instances
- **Needs review:** ~87+ instances
- **Total found:** 121 instances

## Optimization Impact

Each redundant `cmp # 0` instruction:
- Uses 2 bytes
- Takes 2 cycles
- Can be removed for immediate savings

Estimated savings: ~68+ bytes and ~136+ cycles for confirmed cases alone.
