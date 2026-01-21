;;; ChaosFight - Source/Routines/ApplyGuardColor.bas
;;; Copyright © 2025 Bruce-Robert Pocock.


ApplyGuardColor .proc
          ;; Apply guard color effect (light cyan for NTSC/PAL, cyan for SECAM)
          ;; while a player is actively guarding.
          ;;
          ;; Input: temp1 = player index (0-3)
          ;; playerState[] (global) = player state flags (bit 1 = guarding)
          ;;
          ;; Output: Player color forced to 12 while guarding
          ;; Mutates: temp1-temp2, COLUP0, _COLUP1, colup2, colup3
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: Must remain colocated with GuardColor0-GuardColor3 jump table
          ;; Check if player is guarding
          ;; Set temp2 = playerState[temp1] & 2
          lda temp1
          asl
          tax
          lda playerState,x
          sta temp2
          ;; Not guarding
          lda temp2
          bne PlayerIsGuarding

PlayerIsGuarding:

          ;; set light cyan color
          ;; Optimized: Apply guard color with computed assignment
          jmp GuardColor0

.pend

GuardColor0:
          lda # 12
          sta player0color
          rts

GuardColor1:
          lda # 12
          sta newCOLUP1
          rts

GuardColor2:
          lda # 12
          sta colup2
          rts

GuardColor3:
          lda # 12
          sta colup3
          rts

