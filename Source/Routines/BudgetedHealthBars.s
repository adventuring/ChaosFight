;;; ChaosFight - Source/Routines/BudgetedHealthBars.bas
;;; Copyright © 2025 Bruce-Robert Pocock.


BudgetedHealthBarUpdate .proc
;;; Budget Health Bar Rendering
          ;; Draw only one player health bar per frame (down from four) to cut pfpixel work by 75%.
          ;; Uses framePhase (0-3) to determine which player health bar to refresh each frame.
          ;;
          ;; Input: framePhase (global) = frame phase counter (0-3)
          ;; controllerStatus (global) = controller detection sta

          ;; playerCharacter[] (global array) = character selections
          ;; playerHealth[] (global array) = player health values
          ;; HealthBarMaxLength (constant) = maximum health bar length
          ;;
          ;; Output: One player health bar updated per frame, COLUPF/COLUP0/COLUP1 set to same color for score minikernel
          ;;
          ;; Mutates: temp6 (health bar length), COLUPF/COLUP0/COLUP1 (TIA registers)
          ;;
          ;; Called Routines: UpdateHealthBarPlayer0-3 (inline)
          ;;
          ;; Constraints: Must be colocated with CheckPlayer2HealthUpdate, DonePlayer2HealthUpdate,
          ;; CheckPlayer3HealthUpdate, DonePlayer3HealthUpdate,
          ;; UpdateHealthBarPlayer0-3 (all called via goto or gosub)
          ;; Determine which player to update based on frame phase
          lda framePhase
          cmp # 0
          bne skip_6563
          jmp BudgetedHealthBarPlayer0
skip_6563:


          ;; lda framePhase (duplicate)
          ;; cmp # 1 (duplicate)
          ;; bne skip_1623 (duplicate)
          ;; jmp BudgetedHealthBarPlayer1 (duplicate)
skip_1623:


          ;; lda framePhase (duplicate)
          ;; cmp # 2 (duplicate)
          ;; bne skip_6642 (duplicate)
          ;; TODO: CheckPlayer2HealthUpdate
skip_6642:


          ;; jmp CheckPlayer3HealthUpdate (duplicate)

.pend

BudgetedHealthBarPlayer0 .proc
          ;; Local trampoline so branch stays in range; tail-calls target
          ;; Update Player 0 health bar (inline from UpdatePlayer1HealthBar pattern)
                    ;; let temp6 = playerHealth[0]         
          ;; lda 0 (duplicate)
          asl
          tax
          ;; lda playerHealth,x (duplicate)
          sta temp6
            ;; lda temp6 (duplicate)
            ;; sta temp6 (duplicate)
            ;; asl (duplicate)
            ;; asl (duplicate)
            clc
            adc temp6
            ;; asl (duplicate)
            ;; asl (duplicate)
            ;; clc (duplicate)
            ;; adc temp6 (duplicate)
            lsr
            ;; lsr (duplicate)
            ;; lsr (duplicate)
            ;; lsr (duplicate)
            ;; lsr (duplicate)
            ;; lsr (duplicate)
            ;; lsr (duplicate)
            ;; lsr (duplicate)
            ;; sta temp6 (duplicate)
                    ;; if temp6 > HealthBarMaxLength then let temp6 = HealthBarMaxLength
          rts

.pend

BudgetedHealthBarPlayer1 .proc
          ;; Local trampoline so branch stays in range; tail-calls target
          ;; Update Player 1 health bar (inline from UpdatePlayer1HealthBar pattern)
                    ;; let temp6 = playerHealth[1]         
          ;; lda 1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerHealth,x (duplicate)
          ;; sta temp6 (duplicate)
            ;; lda temp6 (duplicate)
            ;; sta temp6 (duplicate)
            ;; asl (duplicate)
            ;; asl (duplicate)
            ;; clc (duplicate)
            ;; adc temp6 (duplicate)
            ;; asl (duplicate)
            ;; asl (duplicate)
            ;; clc (duplicate)
            ;; adc temp6 (duplicate)
            ;; lsr (duplicate)
            ;; lsr (duplicate)
            ;; lsr (duplicate)
            ;; lsr (duplicate)
            ;; lsr (duplicate)
            ;; lsr (duplicate)
            ;; lsr (duplicate)
            ;; lsr (duplicate)
            ;; sta temp6 (duplicate)
                    ;; if temp6 > HealthBarMaxLength then let temp6 = HealthBarMaxLength
          ;; rts (duplicate)

.pend

CheckPlayer2HealthUpdate .proc
          ;; Check if Player 3 health bar should be updated (4-player mode, active player)
          ;;
          ;; Input: controllerStatus (global), playerCharacter[] (global array)
          ;;
          ;; Output: Player 3 health bar updated if conditions met
          ;;
          ;; Mutates: temp6, COLUPF, playfield data (via UpdateHealthBarPlayer2)
          ;;
          ;; Called Routines: (inlined UpdateHealthBarPlayer2)
          ;; Constraints: Must be colocated with BudgetedHealthBarUpdate, DonePlayer2HealthUpdate
          ;; lda controllerStatus (duplicate)
          and SetQuadtariDetected
          ;; cmp # 0 (duplicate)
          ;; bne skip_5407 (duplicate)
skip_5407:


          ;; Update Player 3 health bar (inlined from UpdateHealthBarPlayer2)
                    ;; if playerCharacter[2] = NoCharacter then DonePlayer2HealthUpdate

          ;; Input: playerHealth[] (global array) = player health values
          ;; HealthBarMaxLength (constant) = maximum health bar length
          ;; Output: Score colors set for health digit display
          ;; Mutates: temp6 (health bar length), COLUPF/COLUP0/COLUP1 (TIA registers)
          ;; Use inline assembly for division by 12 (multiply by 21 ÷ 256 ≈ 1 ÷ 12)
          ;; Algorithm: temp6 = (playerHealth[2] × 21) >> 8
          ;; lda playerHealth+2 (duplicate)
            ;; sta temp6 (duplicate)
            ;; asl (duplicate)
            ;; asl (duplicate)
            ;; clc (duplicate)
            ;; adc temp6 (duplicate)
            ;; asl (duplicate)
            ;; asl (duplicate)
            ;; clc (duplicate)
            ;; adc temp6 (duplicate)
            ;; lsr (duplicate)
            ;; lsr (duplicate)
            ;; lsr (duplicate)
            ;; lsr (duplicate)
            ;; lsr (duplicate)
            ;; lsr (duplicate)
            ;; lsr (duplicate)
            ;; lsr (duplicate)
            ;; sta temp6 (duplicate)
                    ;; if temp6 > HealthBarMaxLength then let temp6 = HealthBarMaxLength
          ;; rts (duplicate)

DonePlayer2HealthUpdate
          ;; Player 2 health update check complete (label only)
          ;;
          ;; Input: None (label only, no execution)
          ;;
          ;; Output: None (label only)
          ;;
          ;; Mutates: None
          ;;
          ;; Called Routines: None
          ;; Constraints: Must be colocated with BudgetedHealthBarUpdate
          ;; jmp DonePlayer3HealthUpdate (duplicate)

.pend

CheckPlayer3HealthUpdate .proc
          ;; Check if Player 4 health bar should be updated (4-player mode, active player)
          ;;
          ;; Input: controllerStatus (global), playerCharacter[] (global array)
          ;;
          ;; Output: Player 4 health bar updated if conditions met
          ;;
          ;; Mutates: temp6, COLUPF, playfield data (via UpdateHealthBarPlayer3)
          ;;
          ;; Called Routines: (inlined UpdateHealthBarPlayer3)
          ;; Constraints: Must be colocated with BudgetedHealthBarUpdate, DonePlayer3HealthUpdate
          ;; lda controllerStatus (duplicate)
          ;; and SetQuadtariDetected (duplicate)
          ;; cmp # 0 (duplicate)
          ;; bne skip_9191 (duplicate)
skip_9191:


          ;; Update Player 4 health bar (inlined from UpdateHealthBarPlayer3)
                    ;; if playerCharacter[3] = NoCharacter then DonePlayer3HealthUpdate

          ;; Input: playerHealth[] (global array) = player health values
          ;; HealthBarMaxLength (constant) = maximum health bar length
          ;; Output: Score colors set for health digit display
          ;; Mutates: temp6 (health bar length), COLUPF/COLUP0/COLUP1 (TIA registers)
          ;; Use inline assembly for division by 12 (multiply by 21 ÷ 256 ≈ 1 ÷ 12)
          ;; Algorithm: temp6 = (playerHealth[3] × 21) >> 8
          ;; lda playerHealth+3 (duplicate)
            ;; sta temp6 (duplicate)
            ;; asl (duplicate)
            ;; asl (duplicate)
            ;; clc (duplicate)
            ;; adc temp6 (duplicate)
            ;; asl (duplicate)
            ;; asl (duplicate)
            ;; clc (duplicate)
            ;; adc temp6 (duplicate)
            ;; lsr (duplicate)
            ;; lsr (duplicate)
            ;; lsr (duplicate)
            ;; lsr (duplicate)
            ;; lsr (duplicate)
            ;; lsr (duplicate)
            ;; lsr (duplicate)
            ;; lsr (duplicate)
            ;; sta temp6 (duplicate)
                    ;; if temp6 > HealthBarMaxLength then let temp6 = HealthBarMaxLength
          ;; lda temp6 (duplicate)
          sec
          sbc HealthBarMaxLength
          bcc skip_1486
          beq skip_1486
          ;; lda HealthBarMaxLength (duplicate)
          ;; sta temp6 (duplicate)
skip_1486:
          ;; rts (duplicate)

DonePlayer3HealthUpdate
          ;; Player 3 health update check complete (label only)
          ;;
          ;; Input: None (label only, no execution)
          ;;
          ;; Output: None (label only)
          ;;
          ;; Mutates: None
          ;;
          ;; Called Routines: None
          ;; Constraints: Must be colocated with BudgetedHealthBarUpdate

.pend

