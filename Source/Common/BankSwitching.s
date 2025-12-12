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
          ;; COLD START PROCEDURE - Must occur before any stack use
          ;; Step 1: Clear Decimal mode
          cld
          
          ;; Step 2: Set X to $FF, then transfer X to Stack Pointer
          ldx #$ff
          txs              ;;; Initialize stack pointer to $FF (top of stack at $01FF)
          
          ;; Step 3: Check $80 for exactly $00 or $80 (7800 system detection flag)
          lda console7800Detected
          cmp # $00
          beq ColdStartProceedToWarmStart
          cmp # $80
          beq ColdStartProceedToWarmStart
          
          ;; Step 4: $80 is not $00 or $80 - detect 7800 console and set $80 to $00 or $80
          ;; Detect 7800 console (must not use stack - inline detection)
          lda # 0
          sta console7800Detected          ;;; Initialize to $00 (2600)
          
          ;; Check $D0 for $2C (7800 indicator)
          lda $d0
          cmp # $2C                        ;;; ConsoleDetectD0 = $2C
          bne ColdStartDetected2600
          
          ;; Check $D1 for $A9 (7800 confirmation)
          lda $D1
          cmp # $A9                        ;;; ConsoleDetectD1 = $A9
          bne ColdStartDetected2600
          
          ;; 7800 detected: $D0=$2C and $D1=$A9
          lda # $80
          sta console7800Detected          ;;; Set $80 to $80 for 7800 console
          jmp ColdStartProceedToWarmStart
          
ColdStartDetected2600:
          ;; 2600 detected (or flashed game on 2600)
          ;; Check if both $D0 and $D1 are $00 (flashed to Harmony/Melody)
          lda $d0
          bne ColdStartProceedToWarmStart  ;;; Not flashed, confirmed 2600
          lda $D1
          bne ColdStartProceedToWarmStart  ;;; Not flashed, confirmed 2600
          
          ;; Both $D0 and $D1 are $00 - check if $80 was already set by CDFJ driver
          ;; (This would have been set before reset, so we check it)
          ;; Since we just initialized $80 to $00, if it was $80 before, it's lost
          ;; For flashed games, we'll detect on first warm start
          ;; For now, proceed with $00 (2600)
          
ColdStartProceedToWarmStart:
          ;; Step 5: Jump to warm start
          ;; Switch to Bank 12 where WarmStart is located
          ;; Bank 12 = $ffe0 + 12
          nop $ffec
          jmp WarmStart

Break:
          ;; Switch to Bank 12 where WarmStart is located
          ;; Bank 12 = $ffe0 + 12
          nop $ffec
          jmp WarmStart

          * = $fffc
          .word Reset                                  ; Reset vector
          .word Break                                  ; IRQ/BRK vector
