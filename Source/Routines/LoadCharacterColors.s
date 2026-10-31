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
          ;; Output: playerColor = resulting color value for the active TV build

          ;;
          ;; Mutates: playerColor only (output)

          ;;
          ;; Called Routines: None

          ;;
          ;; Constraints: Must remain in bank14 (called from SetPlayerSprites bank2)



          ;; Guard state takes priority over hurt sta


          jmp BS_return



          ;; Hurt state handling

          ;; Hurt state - SECAM uses magenta, others use dimmed colors

          lda temp2
          bne ApplyHurtColor
          jmp NormalColorState
ApplyHurtColor:


          ;; Load player color - SECAM uses fixed magenta, NTSC/PAL use player-specific colors
          .if TVStandard == SECAM
          lda ColMagenta(12)
          sta playerColor_W
          .else
          ;; Set playerColor = PlayerColors6[currentPlayer]
          lda currentPlayer
          tax
          lda PlayerColors6,x
          sta playerColor_W
          .fi

          jmp BS_return



.pend

NormalColorState .proc

          ;; Normal color sta

          ;; Returns: Far (return otherbank)

          ;; playerColor = PlayerColors12[currentPlayer] (luminance $c)
          ;; Modified for flicker management: luminance $e when flickering, $a when not flickering
          lda currentPlayer
          tax
          lda PlayerColors12,x
          sta playerColor_W

          ;; Flicker management: check if partner player is present
          ;; Pair 1: players 0 and 2 (1/3 in 1-indexed)
          ;; Pair 2: players 1 and 3 (2/4 in 1-indexed)
          ;; If BOTH players in pair are present and alive → flicker (luminance $e)
          ;; If only ONE player in pair → no flicker (luminance $a)
          .if TVStandard != SECAM
          
          ;; Determine partner based on currentPlayer
          ;; currentPlayer 0→partner 2, 1→partner 3, 2→partner 0, 3→partner 1
          lda currentPlayer
          cmp # 2
          bcs Partner1Or3  ;; currentPlayer >= 2 (2 or 3)
          ;; currentPlayer 0 or 1
          clc
          adc # 2          ;; 0→2, 1→3
          jmp CheckPartner
Partner1Or3:
          sec
          sbc # 2          ;; 2→0, 3→1
CheckPartner:
          tax
          lda playerCharacter,x
          cmp # NoCharacter
          beq NoFlickerLum
          lda playerHealth,x
          beq NoFlickerLum
          ;; Partner is present and alive → flicker mode
          lda playerColor_R
          and #$F0
          ora #$E
          sta playerColor_W
          jmp ColorDone
NoFlickerLum:
          ;; Not flickering: luminance $a (10) - darker
          lda playerColor_R
          and #$F0
          ora #$A
          sta playerColor_W
ColorDone:
          .endif

          jmp BS_return

.pend

