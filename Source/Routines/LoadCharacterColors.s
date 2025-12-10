;;; ChaosFight - Source/Routines/LoadCharacterColors.bas

;;; Copyright © 2025 Bruce-Robert Pocock.

;;; Player color loading function - colors are player-specific, not character-specific




LoadCharacterColors .proc




          ;; Load player colors based on guard and hurt sta

          ;; Returns: Far (return otherbank)

          ;; Player colors are fixed per player index:

          ;; Player 0 → Indigo, Player 1 → Red, Player 2 → Yellow, Player 3 → Turquoise.

          ;; Guarding always forces light cyan, regardless of TV mode.

          ;; Hurt state dims to luminance 6 (PlayerColors6) except SECAM, which uses magenta.

          ;; Color/B&W switch and pause overrides do not affect player colors.

          ;;
          ;; Input: currentPlayer (global) = player index (0-3)

          ;; temp2 = hurt state flag (0 = normal, non-zero = hurt/recovering)

          ;; temp3 = guard state flag (0 = normal, non-zero = guarding)

          ;;
          ;; Output: temp6 = resulting color value for the active TV build

          ;;
          ;; Mutates: temp6 only (output)

          ;;
          ;; Called Routines: None

          ;;
          ;; Constraints: Must remain in bank14 (called from SetPlayerSprites bank2)



          ;; Guard state takes priority over hurt sta


          jsr BS_return



          ;; Hurt state handling

          ;; Hurt state - SECAM uses magenta, others use dimmed colors

          lda temp2
          bne ApplyHurtColor
          jmp NormalColorState
ApplyHurtColor:


          ;; Load player color - SECAM uses fixed magenta, NTSC/PAL use player-specific colors
          .if TVStandard == SECAM
          lda ColMagenta(12)
          sta temp6
          .else
          ;; let temp6 = PlayerColors6[currentPlayer]         
          lda currentPlayer
          asl
          tax
          lda PlayerColors6,x
          sta temp6
          .fi

          jsr BS_return



.pend

NormalColorState .proc

          ;; Normal color sta

          ;; Returns: Far (return otherbank)

          ;; let temp6 = PlayerColors12[currentPlayer]         
          lda currentPlayer
          asl
          tax
          lda PlayerColors12,x
          sta temp6

          jsr BS_return

.pend

