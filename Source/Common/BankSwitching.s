;;; ChaosFight - Source/Common/BankSwitching.s
;;; Copyright © 2025 Bruce-Robert Pocock.
;;; EFSC 64k bankswitch code and vectors

          BS_length = $18    ; = 24 bytes
          .if * > $ffe0 - BS_length
          .error format("Bank %d overflow: $%04x > $%04x", current_bank, *, $ffe0 - BS_length)
          .fi

          * = $ffe0 - BS_length
BS_return:
          ;; STACK PICTURE: [SP+1: encoded ret hi] [SP+0: encoded ret lo]
          ;; Expected: 2 bytes on stack (encoded return address with bank info in low nybble of high byte)
          ;; After BS_jsr's RTS consumed the target address, only the encoded return address remains
          ;; Use temp7 (zero-page) instead of stack to avoid overflow
          tsx
          ;; Encoded return address (offset 1 = high byte contains bank info in low nybble)
          lda 1, x
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
          sta 1, x
          ;; DO NOT pop the encoded return address - leave it on stack for RTS
          ;; RTS will pop the decoded return address and jump to it
          ldx temp7
          ;; STACK PICTURE: [SP+1: decoded ret hi] [SP+0: decoded ret lo] (encoded return decoded in place)
          ;; Bankswitch: $ffe0 + X where X is 0-based bank number
          nop $ffe0, x
          ;; STACK PICTURE: [SP+1: decoded ret hi] [SP+0: decoded ret lo] (bankswitch doesn't affect stack)
          ;; RTS will pop 2 bytes (decoded return address) and jump to caller
          rts

BS_jsr:
          ;; STACK PICTURE: [SP+3: target hi] [SP+2: target lo] [SP+1: return hi] [SP+0: return lo]
          ;; Expected: 4 bytes on stack (2-byte target address + 2-byte return address)
          ;; Bankswitch: $ffe0 + X where X is 0-based bank number
          nop $ffe0, x
          ;; STACK PICTURE: [SP+1: return hi] [SP+0: return lo] (target address consumed by bankswitch)
          ;; RTS will pop 2 bytes (return address) and jump to caller
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
