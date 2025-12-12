;;; ChaosFight - Source/Routines/ColdStart.s
;;; Copyright © 2025 Bruce-Robert Pocock.
;;;
;;; Cold Start Procedure
;;; Called from Reset handler in BankSwitching.s after bankswitch to Bank 12
;;; Must occur before any stack use (stack is initialized here)
;;;
;;; Cold start procedure:
;;; 1. CLD (Clear Decimal mode)
;;; 2. Set X to $FF, then txs (initialize stack pointer)
;;; 3. Check $80 for exactly $00 or $80 (7800 system detection flag)
;;; 4. If not, detect 7800 console and set $80 to $00 or $80
;;; 5. Jump to WarmStart
;;;
;;; Warm start procedure (in ConsoleHandling.s):
;;; 1. Clear all memory from $81 to $FF, $F081 to $F0FF, and $F080
;;; 2. Clear TIA registers
;;; 3. Initialize PIA RIOT I/O ports
;;; 4. Perform input controller detection
;;; 5. Go to publisher prelude

ColdStart .proc
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
          ;; Step 5: Jump to warm start (same bank - Bank 12)
          jmp WarmStart

.pend
