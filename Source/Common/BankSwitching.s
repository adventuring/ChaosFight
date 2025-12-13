;;; ChaosFight - Source/Common/BankSwitching.s
;;; Copyright © 2025 Bruce-Robert Pocock.
;;; EFSC 64k bankswitch code and vectors

          ;; Calculate actual size: BS_return (21 bytes) + BS_jsr (4 bytes) = 25 bytes ($19)
          ;; BS_return: tsx(1) + lda 2,x(2) + tay(1) + lsr*4(4) + sta temp7(2) + tya(1) + ora #$f0(2) + sta 2,x(2) + ldx temp7(2) + nop $ffe0,x(3) + rts(1) = 21 bytes
          ;; BS_jsr: nop $ffe0,x(3) + rts(1) = 4 bytes
          BS_length = $19    ; = 25 bytes (BS_return: 21 bytes, BS_jsr: 4 bytes)
          .if * > $ffe0 - BS_length
          .error format("Bank %d overflow: $%04x > $%04x", current_bank, *, $ffe0 - BS_length)
          .fi

          * = $ffe0 - BS_length
BS_return:
          ;; STABLE VERSION - DO NOT ALTER
          ;; This routine has been verified and must remain unchanged.
          ;; Any bugs should be fixed at their source, not by modifying this routine.
          ;;
          ;; STACK PICTURE: [SP+1: encoded ret lo] [SP+2: encoded ret hi]
          ;; Expected: 2 bytes on stack (encoded return address with bank info in high nybble of high byte)
          ;; After BS_jsr's RTS consumed the target address, only the encoded return address remains
          ;; On little-endian 6502: if X = SP (from tsx), SP points to next byte to be pushed
          ;; Top of stack (most recently pushed byte) is at offset 1 = low byte
          ;; High byte is at offset 2 (pushed before low byte)
          ;; Use temp7 (zero-page) instead of stack to avoid overflow
          tsx
          ;; Encoded return address (offset 2 = high byte contains bank info in high nybble)
          ;; High byte is at $0100+X+2 (offset 2 relative to X)
          lda 2, x
          tay
          lsr a
          lsr a
          lsr a
          ;; Extract bank number from high nybble
          lsr a
          sta temp7
          tya
          ;; Restore to $fx format (address in CPU space)
          ora #$f0
          sta 2, x
          ;; DO NOT pop the encoded return address - leave it on stack for RTS
          ;; RTS will pop the decoded return address and jump to it
          ldx temp7
          ;; STACK PICTURE: [SP+1: decoded ret lo] [SP+2: decoded ret hi] (encoded return decoded in place)
          ;; Bankswitch: $ffe0 + X where X is 0-based bank number
          nop $ffe0, x
          ;; STACK PICTURE: [SP+1: decoded ret lo] [SP+2: decoded ret hi] (bankswitch doesn't affect stack)
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
.if (($fff & *) > ($fff & $ffe0))
.error "WARNING: size parameter in BankSwitching.s too small - the program probably will not work."
.error format("Change by %d and try again.", (($fff & *) - ($fff & $ffe0)))
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
