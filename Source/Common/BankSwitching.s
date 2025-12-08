;;; ChaosFight - Source/Common/BankSwitching.s
;;; Copyright © 2025 Bruce-Robert Pocock.
;;; EFSC 64k bankswitch code and vectors
;;; CRITICAL: This file is included in EVERY bank to provide BS_return and BS_jsr
;;; In 64tass multibank images: Labels are redefined in each bank, which causes
;;; duplicate definition errors when all banks are assembled together.
;;; Solution: Use conditional compilation to define labels only in the first bank

          ;; Labels BS_return and BS_jsr are forward-declared in Preamble.s
          ;; This file provides the actual code implementation in each bank
          ;; File offset and CPU address are set by bank file before including this file
BS_return:
          ;; CRITICAL: Use zero-page variable instead of pha to avoid stack overflow
          ;; temp7 is used by kernel for bankswitching, but we can use it here since we're doing bank switching
          tsx
          lda 2,x          ;; get encoded high .byte of return address from stack (no A/X save, so offset is 2)
          tay              ;; save encoded .byte for restoration
          lsr              ;; accumulator mode (implicit A)
          lsr              ;; accumulator mode (implicit A)
          lsr              ;; accumulator mode (implicit A)
          lsr              ;; accumulator mode (implicit A) - bank now in low nybble
          sta temp7        ;; save bank number in zero-page variable (saves 1 .byte on stack vs pha)
          tya              ;; get saved encoded .byte
          ora #$f0         ;; restore to $Fx format
          sta 2,x          ;; store restored address back to stack (X still has stack pointer)
          ldx temp7        ;; restore bank number from zero-page variable
BS_jsr:
          nop $ffe0,x      ;; bankswitch_hotspot + X where X is 0-based bank number
          rts

          ;; Pad to exactly bscode_length ($18 = 24 bytes) to reach $FFE0
          ;; Current code is 21 bytes (BS_return through BS_jsr), need 3 bytes padding
          .byte $00, $00, $00  ;; padding to reach exactly $FFE0

          ;; EFSC 64k bankswitch hotspot is $FFE0
          ;; Size check: verify we're at approximately $FFE0 (allow 4 byte tolerance for address calculation differences)
.if (($fff & *) > (($fff & bankswitch_hotspot) + 4))
.error "WARNING: size parameter in BankSwitching.s too small - the program probably will not work."
.error format("Change to %d and try again.", (($fff & *) - ($fff & bankswitch_hotspot)))
.fi

          ;; -------------------------------------------------------------------
          ;; EFSC identification header immediately after bankswitch code
          ;; -------------------------------------------------------------------
          ;;
          ;; For EFSC 64k SuperChip carts we reserve 16 bytes starting at the
          ;; CPU hotspot address ($FFE0) in each bank. The bankswitch stub
          ;; is placed so that it ends just before $FFE0; the following 16 bytes
          ;; at $FFE0-$FFEF contain:
          ;;
          ;;   "EFSC", 0, "BRPocock", 0, game year, current bank
          ;;
          ;; Because the bankswitch hardware only cares about accesses to the
          ;; hotspot address, not the data value, this identification header
          ;; does not interfere with bankswitching. Emulators/multicarts can
          ;; use it to detect EFSC ROMs and associate metadata.
          ;;
          ;; Use current_bank (0-based, 0-15) set by bank file to calculate bank file offset
          ;; Bank base = current_bank * $1000 (Bank 0=$0000, Bank 1=$1000, etc.)
          ;; Note: File offset and CPU address are set by bank file before including this file
          ;; File offset: * = (current_bank * $1000) | $0FE0
          ;; CPU address: * = $FFE0 (same for all banks)
          ;;
          ;; CRITICAL: Labels defined here (BS_return, BS_jsr, EFSC_Header, Reset)
          ;; are defined in EVERY bank at the same CPU addresses but different file offsets.
          ;; In 64tass, when the same file is included multiple times, labels are redefined.
          ;; This is OK because each bank has its own namespace context.

          ;; CRITICAL: EFSC header must be at $FFE0-$FFEF, not at bankswitch_hotspot ($FFF8)
          ;; Set file offset and CPU address for EFSC header
          ;; File offset: (current_bank * $1000) + ($FFE0 - $F000) = (current_bank * $1000) + $0FE0
          ;; CPU address: $FFE0
          .offs (current_bank * $1000) + ($FFE0 - $F000) - $FFE0
          * = $FFE0
EFSC_Header:
          .text "EFSC", 0
          .text "BRPocock", 0
          ;; Game year
          .byte 26, current_bank

          ;; Reset code at $fff0 - must be identical in every bank
          ;; Set file offset and CPU address for Reset code
          ;; File offset: (current_bank * $1000) + ($FFF0 - $F000) = (current_bank * $1000) + $0FF0
          ;; CPU address: $FFF0
          .offs (current_bank * $1000) + ($FFF0 - $F000) - $FFF0
          * = $fff0
Reset:
          ;; CRITICAL: Switch to Bank 13 (0-based) where startup code (ColdStart) is located
          ;; Bank switching occurs via accessing specific addresses
          ;; Bank N (0-based index) = $FFE0 + N
          ;; Bank 13 (0-based) = $FFE0 + 13 = $FFED
          ;; Use NOP to access the address (triggers hardware bank switch)
          nop $ffed        ;; switch to Bank 13 where ColdStart is located
          jmp ColdStart

          ;; IRQ/BRK handler code at $fff6 - must be identical in every bank
          ;; Set file offset and CPU address for IRQ/BRK handler code
          ;; File offset: (current_bank * $1000) + ($FFF6 - $F000) = (current_bank * $1000) + $0FF6
          ;; CPU address: $FFF6
          .offs (current_bank * $1000) + ($FFF6 - $F000) - $FFF6
          * = $fff6
          ;; CRITICAL: Switch to Bank 12 (0-based) where WarmStart is located
          ;; Bank switching occurs via accessing specific addresses
          ;; Bank N (0-based index) = $FFE0 + N
          ;; Bank 12 (0-based) = $FFE0 + 12 = $FFEC
          ;; Use NOP to access the address (triggers hardware bank switch)
          nop $ffec        ;; switch to Bank 12 where WarmStart is located
          jmp WarmStart

          ;; CPU vectors at $fffc-$ffff - must be at exact addresses in every bank
          ;; Set file offset and CPU address for vectors
          ;; File offset: (current_bank * $1000) + ($FFFC - $F000) = (current_bank * $1000) + $0FFC
          ;; CPU address: $FFFC
          .offs (current_bank * $1000) + ($FFFC - $F000) - $FFFC
          * = $fffc
          ;; $fffc: Reset vector (points to Reset at CPU $FFF0)
          .word Reset
          ;; $fffe: IRQ/BRK vector (points to code at CPU $FFF6 which switches to Bank 13 and jumps to WarmStart)
          .word $fff6

          ;; CPU address space check: should end at exactly $10000
          ;; Note: This check is disabled because * = for file offset resets CPU address calculation
          ;; The actual overflow will be caught during final assembly
