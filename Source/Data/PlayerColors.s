;;; ChaosFight - Source/Data/PlayerColors.bas
;;; Copyright © 2025 Bruce-Robert Pocock.

          ;; Player color tables for indexed lookup (P1..P4)
          ;; Bright (luminance 12) and dim (luminance 6)
PlayerColors12:

          .byte $7C, $4C, $1C, $9C

PlayerColors12_end:

.if TVStandard == SECAM
PlayerColors6:

          .byte $58, $58, $58, $58

PlayerColors6_end:

.else
PlayerColors6:

          .byte $76, $46, $16, $96

PlayerColors6_end:

.fi


