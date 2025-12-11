;;; ChaosFight - Source/Routines/BudgetedHealthBars.bas
;;; Copyright © 2025 Bruce-Robert Pocock.


BudgetedHealthBarUpdate .proc
          ;; Budget Health Bar Rendering
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
          ;; UpdateHealthBarPlayer0-3 (all called via jmp or gosub)
          ;; Determine which player to update based on frame phase
          lda framePhase
          cmp # 0
          bne CheckPhase1

          jmp BudgetedHealthBarPlayer0

CheckPhase1:

          lda framePhase
          cmp # 1
          bne CheckPhase2

          jmp BudgetedHealthBarPlayer1

CheckPhase2:

          lda framePhase
          cmp # 2
          bne CheckPlayer3HealthUpdate

          jmp CheckPlayer2HealthUpdate

CheckPlayer3HealthUpdate:

          jmp CheckPlayer3HealthUpdate

.pend

BudgetedHealthBarPlayer0 .proc
          ;; Local trampoline so branch stays in range; tail-calls target
          ;; Update Player 0 health bar (inline from UpdatePlayer1HealthBar pattern)
          ;; Set temp6 = playerHealth[0]
          lda # 0
          asl
          tax
          lda playerHealth,x
          sta temp6
          lda temp6
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
          if temp6 > HealthBarMaxLength then let temp6 = HealthBarMaxLength
          rts

.pend

BudgetedHealthBarPlayer1 .proc
          ;; Local trampoline so branch stays in range; tail-calls target
          ;; Update Player 1 health bar (inline from UpdatePlayer1HealthBar pattern)
          ;; Set temp6 = playerHealth[1]
          lda 1
          asl
          tax
          lda playerHealth,x
          sta temp6
            lda temp6
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
                    if temp6 > HealthBarMaxLength then let temp6 = HealthBarMaxLength
          rts

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
          lda controllerStatus
          and # SetQuadtariDetected
          cmp # 0
          bne CheckPlayer2Character

          jmp DonePlayer2HealthUpdate
CheckPlayer2Character:


          ;; Update Player 3 health bar (inlined from UpdateHealthBarPlayer2)
                    if playerCharacter[2] = NoCharacter then DonePlayer2HealthUpdate

          ;; Input: playerHealth[] (global array) = player health values
          ;; HealthBarMaxLength (constant) = maximum health bar length
          ;; Output: Score colors set for health digit display
          ;; Mutates: temp6 (health bar length), COLUPF/COLUP0/COLUP1 (TIA registers)
          ;; Use inline assembly for division by 12 (multiply by 21 ÷ 256 ≈ 1 ÷ 12)
          ;; Algorithm: temp6 = (playerHealth[2] × 21) >> 8
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
                    if temp6 > HealthBarMaxLength then let temp6 = HealthBarMaxLength
          rts

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
          jmp DonePlayer3HealthUpdate

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
          lda controllerStatus
          and # SetQuadtariDetected
          cmp # 0
          bne CheckPlayer3Character

          jmp DonePlayer3HealthUpdate
CheckPlayer3Character:


          ;; Update Player 4 health bar (inlined from UpdateHealthBarPlayer3)
                    if playerCharacter[3] = NoCharacter then DonePlayer3HealthUpdate

          ;; Input: playerHealth[] (global array) = player health values
          ;; HealthBarMaxLength (constant) = maximum health bar length
          ;; Output: Score colors set for health digit display
          ;; Mutates: temp6 (health bar length), COLUPF/COLUP0/COLUP1 (TIA registers)
          ;; Use inline assembly for division by 12 (multiply by 21 ÷ 256 ≈ 1 ÷ 12)
          ;; Algorithm: temp6 = (playerHealth[3] × 21) >> 8
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
                    if temp6 > HealthBarMaxLength then let temp6 = HealthBarMaxLength
          lda temp6
          sec
          sbc HealthBarMaxLength
          bcc BudgetedHealthBarUpdateDone
          beq BudgetedHealthBarUpdateDone
          lda HealthBarMaxLength
          sta temp6
BudgetedHealthBarUpdateDone:
          rts

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

