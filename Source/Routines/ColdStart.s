;;; ChaosFight - Source/Routines/ColdStart.bas
;;; Copyright © 2025 Bruce-Robert Pocock.
;;;
;;; DEPRECATED: Cold start procedure is now in Reset handler (BankSwitching.s)
;;; This file is kept for compatibility but is no longer the entry point.
;;; The cold start procedure must occur before any stack use, so it's now
;;; implemented directly in the Reset handler at $fff0.
;;;
;;; Cold start procedure (now in Reset handler):
;;; 1. CLD (Clear Decimal mode)
;;; 2. Set X to $FF, then txs (initialize stack pointer)
;;; 3. Check $80 for exactly $00 or $80 (7800 system detection flag)
;;; 4. If not, detect 7800 console and set $80 to $00 or $80
;;; 5. Jump to WarmStart
;;;
;;; Warm start procedure (now in ConsoleHandling.s):
;;; 1. Clear all memory from $81 to $FF, $F081 to $F0FF, and $F080
;;; 2. Clear TIA registers
;;; 3. Initialize PIA RIOT I/O ports
;;; 4. Perform input controller detection
;;; 5. Go to publisher prelude

ColdStart .proc
          ;; DEPRECATED: This is no longer the entry point
          ;; Cold start is now in Reset handler, warm start is in WarmStart
          ;; This stub exists for compatibility only
          ;; Should never be called - if reached, jump to WarmStart
          jmp WarmStart

.pend
