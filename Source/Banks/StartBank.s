;;; ChaosFight - Source/Banks/StartBank.s
;;; Copyright © 2025-2026 Bruce-Robert Pocock.
;;;
;;; Common bank prologue for 64tass builds.
;;;
;;; Expects the caller to define BANK (0-15) before including this file. The
;;; first 256 bytes of every bank ($F000-$F0FF) are reserved for the SuperChip
;;; RAM window, so the bank's data/code image must begin at CPU address $F100.
;;; The .offs directive positions this bank's image at the correct file offset
;;; within the 64K ROM (each bank is $1000 bytes).

          .offs (BANK * $1000) - $f000
          * = $F000
          .rept 256
          .byte $ff
          .endrept
