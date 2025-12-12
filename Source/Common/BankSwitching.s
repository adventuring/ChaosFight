;;; ChaosFight - Source/Common/BankSwitching.s
;;; Copyright © 2025 Bruce-Robert Pocock.
;;; EFSC 64k bankswitch code and vectors

          BS_length = $18    ; = 24 bytes
          .if * > $ffe0 - BS_length
          .error format("Bank %d overflow: $%04x > $%04x", current_bank, *, $ffe0 - BS_length)
          .fi

          * = $ffe0 - BS_length
BS_return:
          ;; Use temp7 (zero-page) instead of stack to avoid overflow
          tsx
          ;; Encoded return address (offset 2 = no A/X save)
          lda 2, x
          tay
          lsr a
          lsr a
          lsr a
          ;; Extract bank number from low nybble
          lsr a
          sta temp7
          tya
          ;; Restore to $Fx format
          ora #$f0
          sta 2, x
          ldx temp7

BS_jsr:
          ;; Bankswitch: $ffe0 + X where X is 0-based bank number
          nop $ffe0, x
          rts

          ;; Size check: verify bankswitch code ends before $FFE0
.if (($fff & *) > (($fff & bankswitch_hotspot) + 4))
.error "WARNING: size parameter in BankSwitching.s too small - the program probably will not work."
.error format("Change to %d and try again.", (($fff & *) - ($fff & bankswitch_hotspot)))
.fi

          ;; EFSC identification header at $ffe0-$ffef: "EFSC", 0, "BRPocock", 0, year, bank
          ;; File offset set by bank file’s .offs before including this file
          .enc "ascii"
          .cdef "A", "Z", $41
          .cdef "a", "z", $61
          .cdef "0", "9", $30
          * = $ffe0
EFSC_Header:
          .text "EFSC", 0
          .text "BRPocock", 0
          .byte 26, current_bank

          * = $fff0
Reset:
          ;; Reset vector entry point
          ;; Minimal handler: bankswitch to Bank 12 and jump to ColdStart
          ;; Cold Start procedure is in Bank 12 (ColdStart.s)
          ;; Bank 12 = $ffe0 + 12 = $ffec
          nop $ffec
          jmp ColdStart

Break:
          ;; Switch to Bank 12 where WarmStart is located
          ;; Bank 12 = $ffe0 + 12
          nop $ffec
          jmp WarmStart

          * = $fffc
          .word Reset                                  ; Reset vector
          .word Break                                  ; IRQ/BRK vector
