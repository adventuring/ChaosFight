          rem ChaosFight - Source/Routines/BudgetedHealthBars.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

BudgetedHealthBarUpdate
          rem Budget Health Bar Rendering
          rem Draw only one player health bar per frame (down from four) to cut pfpixel work by 75%.
          rem Uses framePhase (0-3) to determine which player health bar to refresh each frame.
          rem
          rem Input: framePhase (global) = frame phase counter (0-3)
          rem        controllerStatus (global) = controller detection state
          rem        playerCharacter[] (global array) = character selections
          rem        playerHealth[] (global array) = player health values
          rem        HealthBarMaxLength (constant) = maximum health bar length
          rem
          rem Output: One player health bar updated per frame, COLUPF/COLUP0/COLUP1 set to same color for score minikernel
          rem
          rem Mutates: temp6 (health bar length), COLUPF/COLUP0/COLUP1 (TIA registers)
          rem
          rem Called Routines: UpdateHealthBarPlayer0-3 (inline)
          rem
          rem Constraints: Must be colocated with CheckPlayer2HealthUpdate, DonePlayer2HealthUpdate,
          rem              CheckPlayer3HealthUpdate, DonePlayer3HealthUpdate,
          rem              UpdateHealthBarPlayer0-3 (all called via goto or gosub)
          rem Determine which player to update based on frame phase
          if framePhase = 0 then goto BudgetedHealthBarPlayer0
          if framePhase = 1 then goto BudgetedHealthBarPlayer1
          if framePhase = 2 then CheckPlayer2HealthUpdate
          goto CheckPlayer3HealthUpdate
BudgetedHealthBarPlayer0
          rem Local trampoline so branch stays in range; tail-calls target
          goto UpdateHealthBarPlayer0
BudgetedHealthBarPlayer1
          rem Local trampoline so branch stays in range; tail-calls target
          goto UpdateHealthBarPlayer1
CheckPlayer2HealthUpdate
          rem Check if Player 3 health bar should be updated (4-player mode, active player)
          rem
          rem Input: controllerStatus (global), playerCharacter[] (global array)
          rem
          rem Output: Player 3 health bar updated if conditions met
          rem
          rem Mutates: temp6, COLUPF, playfield data (via UpdateHealthBarPlayer2)
          rem
          rem Called Routines: (inlined UpdateHealthBarPlayer2)
          rem Constraints: Must be colocated with BudgetedHealthBarUpdate, DonePlayer2HealthUpdate
          if (controllerStatus & SetQuadtariDetected) = 0 then DonePlayer2HealthUpdate
          if playerCharacter[2] = NoCharacter then DonePlayer2HealthUpdate
          rem Update Player 3 health bar (inlined from UpdateHealthBarPlayer2)
          rem Input: playerHealth[] (global array) = player health values
          rem        HealthBarMaxLength (constant) = maximum health bar length
          rem Output: Score colors set for health digit display
          rem Mutates: temp6 (health bar length), COLUPF/COLUP0/COLUP1 (TIA registers)
          rem Use inline assembly for division by 12 (multiply by 21÷256 ≈ 1÷12)
          rem Algorithm: temp6 = (playerHealth[2] × 21) >> 8
          asm
            lda playerHealth+2
            sta temp6
            asl
            asl
            clc
            adc temp6
            asl
            asl
            clc
            adc temp6
            lsr
            lsr
            lsr
            lsr
            lsr
            lsr
            lsr
            lsr
            sta temp6
end
          if temp6 > HealthBarMaxLength then temp6 = HealthBarMaxLength
          return
DonePlayer2HealthUpdate
          rem Player 2 health update check complete (label only)
          rem
          rem Input: None (label only, no execution)
          rem
          rem Output: None (label only)
          rem
          rem Mutates: None
          rem
          rem Called Routines: None
          rem Constraints: Must be colocated with BudgetedHealthBarUpdate
          goto DonePlayer3HealthUpdate
CheckPlayer3HealthUpdate
          rem Check if Player 4 health bar should be updated (4-player mode, active player)
          rem
          rem Input: controllerStatus (global), playerCharacter[] (global array)
          rem
          rem Output: Player 4 health bar updated if conditions met
          rem
          rem Mutates: temp6, COLUPF, playfield data (via UpdateHealthBarPlayer3)
          rem
          rem Called Routines: (inlined UpdateHealthBarPlayer3)
          rem Constraints: Must be colocated with BudgetedHealthBarUpdate, DonePlayer3HealthUpdate
          if (controllerStatus & SetQuadtariDetected) = 0 then DonePlayer3HealthUpdate
          if playerCharacter[3] = NoCharacter then DonePlayer3HealthUpdate
          rem Update Player 4 health bar (inlined from UpdateHealthBarPlayer3)
          rem Input: playerHealth[] (global array) = player health values
          rem        HealthBarMaxLength (constant) = maximum health bar length
          rem Output: Score colors set for health digit display
          rem Mutates: temp6 (health bar length), COLUPF/COLUP0/COLUP1 (TIA registers)
          rem Use inline assembly for division by 12 (multiply by 21÷256 ≈ 1÷12)
          rem Algorithm: temp6 = (playerHealth[3] × 21) >> 8
          asm
            lda playerHealth+3
            sta temp6
            asl
            asl
            clc
            adc temp6
            asl
            asl
            clc
            adc temp6
            lsr
            lsr
            lsr
            lsr
            lsr
            lsr
            lsr
            lsr
            sta temp6
end
          if temp6 > HealthBarMaxLength then temp6 = HealthBarMaxLength
          COLUPF = ColGray(14)
          COLUP0 = ColGray(14)
          COLUP1 = ColGray(14)
          rem Score minikernel requires all three color registers set to same color
          rem Players 3/4 health displayed as digits in score area
          return
DonePlayer3HealthUpdate
          return
UpdateHealthBarPlayer0
          rem Update Player 1 health bar (framePhase 0)
          rem
          rem Input: playerHealth[] (global array) = player health values
          rem        HealthBarMaxLength (constant) = maximum health bar length
          rem
          rem Output: Score colors set for health bar display
          rem
          rem Mutates: temp6 (health bar length), COLUPF/COLUP0/COLUP1 (TIA registers)
          rem Constraints: None (note: actual maths is ÷ 12½ but 12 is easy enough to fake it)
          rem Use inline assembly for division by 12 (multiply by 21÷256 ≈ 1÷12)
          rem Algorithm: temp6 = (playerHealth[0] × 21) >> 8
          asm
            lda playerHealth+0
            sta temp6
            asl
            asl
            clc
            adc temp6
            asl
            asl
            clc
            adc temp6
            lsr
            lsr
            lsr
            lsr
            lsr
            lsr
            lsr
            lsr
            sta temp6
end
          if temp6 > HealthBarMaxLength then temp6 = HealthBarMaxLength
          COLUPF = ColGray(14)
          COLUP0 = ColGray(14)
          COLUP1 = ColGray(14)
          rem Score minikernel requires all three color registers set to same color
          rem Health bars for players 1/2 are displayed using score registers (pfscore/pfscore2)
          return

UpdateHealthBarPlayer1
          rem Update Player 2 health bar (framePhase 1)
          rem
          rem Input: playerHealth[] (global array) = player health values
          rem        HealthBarMaxLength (constant) = maximum health bar length
          rem
          rem Output: Score colors set for health bar display
          rem
          rem Mutates: temp6 (health bar length), COLUPF/COLUP0/COLUP1 (TIA registers)
          rem Constraints: None (note: actual maths is ÷ 12½ but 12 is easy enough to fake it)
          rem Use inline assembly for division by 12 (multiply by 21÷256 ≈ 1÷12)
          rem Algorithm: temp6 = (playerHealth[1] × 21) >> 8
          asm
            lda playerHealth+1
            sta temp6
            asl
            asl
            clc
            adc temp6
            asl
            asl
            clc
            adc temp6
            lsr
            lsr
            lsr
            lsr
            lsr
            lsr
            lsr
            lsr
            sta temp6
end
          if temp6 > HealthBarMaxLength then temp6 = HealthBarMaxLength
          COLUPF = ColGray(14)
          COLUP0 = ColGray(14)
          COLUP1 = ColGray(14)
          rem Score minikernel requires all three color registers set to same color
          rem Health bars for players 1/2 are displayed using score registers (pfscore/pfscore2)
          return



