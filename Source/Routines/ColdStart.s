;;; ChaosFight - Source/Routines/ColdStart.bas
;;; Copyright © 2025 Bruce-Robert Pocock.


ColdStart .proc
          ;; Cold Start Initialization
          ;; Returns: Far (return otherbank)
          ;;
          ;; Proper cold start initialization sequence for batariBASIC.
          ;; Called from Reset handler (BankSwitching.s) - Reset handler
          ;; in every bank switches to Bank 14 and jumps to ColdStart.
          ;;
          ;; This routine handles game-specific initialization:
          ;; 1. Hardware detection (console type)
          ;; 2. TIA register initialization (colors, audio)
          ;; 3. Game state initialization
          ;; 4. Transition to first game mode
          ;; Step 1: Detect console hardware type (7800 vs 2600)
          ;; This MUST run before any code modifies $D0/$D1 registers
          ;; as those registers are used for hardware detection
          ;;
          ;; Input: None (cold start entry point)
          ;;
          ;; Output: Console type detected, sprite pointers
          ;; initialized,
          ;; TIA registers initialized, gameMode set,
          ;; transitions to MainLoop
          ;;
          ;; Mutates: Console detection state (via ConsoleDetHW),
          ;; Sprite pointer state (via
          ;; InitializeSpritePointers),
          ;; COLUBK, COLUPF, COLUP0, _COLUP1, AUDC0, AUDV0,
          ;; AUDC1, AUDV1,
          ;; gameMode (global)
          ;;
          ;; Called Routines: ConsoleDetHW (bank1) - accesses $D0/$D1
          ;; hardware registers,
          ;; InitializeSpritePointers (bank14) - sets sprite pointer
          ;; addresses,
          ;; ChangeGameMode (bank1) - sets up initial game mode
          ;;
          ;; Constraints: Must be entry point for cold start (called
          ;; from Bank1)
          ;;
          ;; CRITICAL: Console detection MUST run inline (not as subroutine)
          ;; because the stack is not yet initialized. It must execute
          ;; before any code modifies $D0/$D1 registers.
.include "Source/Routines/ConsoleDetection.s"
          ;; After console detection, we need to initialize:
          ;; - RAM clearing (all RAM set to 0)
          ;; - Stack initialization (SP = $FF)
          ;; - Register initialization (A = × = Y = 0)
          ;; - Decimal mode disabled (CLD)
          ;; This routine is designed to be included directly
          ;; here and will fall through to continue.

.include "Source/Common/Startup.s"
          ;; Step 2: Initialize sprite pointers to RAM addresses
          ;; Must be done before any sprite loading to ensure pointers
          ;; point to SCRAM buffers instead of ROM
          ;; CRITICAL: InitializeSpritePointers is called both same-bank (from ColdStart)
          ;; and cross-bank (from BeginGameLoop). Since it’s called cross-bank, it must
          ;; always use return otherbank. When called same-bank, specifying bank14 still
          ;; uses cross-bank mechanism, so the return otherbank matches.
          ;; Cross-bank call to InitializeSpritePointers in bank 14
          ;; For 64k banks: encode bank number (13, 0-based) in high byte of return address
          lda # (((>(return_point-1)) & $0F) | $D0)  ;;; Bank 14 (0-based 13) = $D0
          pha
          lda # <(return_point-1)
          pha
          lda # >(InitializeSpritePointers-1)
          pha
          lda # <(InitializeSpritePointers-1)
          pha
          ldx # 13  ;;; Target bank 14 (0-based index 13)
          jmp BS_jsr
return_point:


          ;; Step 3: Initialize TIA color registers to safe defaults
          ;; Prevents undefined colors on cold sta

          ;; Background: black (COLUBK starts black, no need to set)
          ;; Playfield: white
          ;; Player 1 (P0): indigo
          COLUPF = $0E(14)
          ;; Player 2: bright red (multisprite kernel requires _COLUP1)
          COLUP0 = ColIndigo(12)
          ;; Player 3: yellow
          _COLUP1 = ColRed(12)
          ;; Player 4: green
          COLUP2 = ColYellow(12)
          COLUP3 = ColGreen(12)

          ;; Step 5: Initialize game state and transition to first mode
          ;; Set initial game mode (Publisher Prelude)
          ;; lda ModePublisherPrelude (duplicate)
          sta gameMode
          ;; OPTIMIZATION: Call BeginPublisherPrelude directly to save 4 bytes
          ;; (skip ChangeGameMode dispatcher overhead)
          ;; Cross-bank call to BeginPublisherPrelude in bank 14
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(BeginPublisherPrelude-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(BeginPublisherPrelude-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 13 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)

          ;; Step 6: Tail call to MainLoop
          ;; jmp MainLoop (duplicate)

.pend

