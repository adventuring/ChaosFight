;;; ChaosFight - Source/Routines/ColdStart.bas
;;; Copyright © 2025 Bruce-Robert Pocock.


ColdStart:
.proc
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
          and cross-bank (from BeginGameLoop). Since it’s called cross-bank, it must
          ;; always use return otherbank. When called same-bank, specifying bank14 still
          ;; uses cross-bank mechanism, so the return otherbank matches.
          ;; Cross-bank call to InitializeSpritePointers in bank 14
          ;; For 64k banks: encode bank number (13, 0-based) in high byte of return address
          lda # >(sprite_init_return-1)
          pha
          lda # <(sprite_init_return-1)
          pha
          lda # >(InitializeSpritePointers-1)
          pha
          lda # <(InitializeSpritePointers-1)
          pha
          ldx # 13
          jmp BS_jsr

sprite_init_return:

          ;; Step 3: Initialize TIA color registers to safe defaults
          ;; Prevents undefined colors on cold start

          ;; Background: black (COLUBK starts black, no need to set)
          ;; Playfield: white
          ;; Player 1 (P0): indigo
          lda # $0E
          sta COLUPF
          ;; Player 2: bright red (multisprite kernel requires _COLUP1)
          lda # ColIndigo(12)
          sta COLUP0
          ;; Player 3: yellow
          lda # ColRed(12)
          sta _COLUP1
          ;; Player 4: green
          lda # ColYellow(12)
          sta COLUP2
          lda # ColGreen(12)
          sta COLUP3

          ;; Step 4: Initialize game state and transition to first mode
          ;; Set initial game mode (Publisher Prelude)
          lda # ModePublisherPrelude
          sta gameMode
          ;; OPTIMIZATION: Call BeginPublisherPrelude directly to save 4 bytes
          ;; (skip ChangeGameMode dispatcher overhead)
          ;; Cross-bank call to BeginPublisherPrelude in bank 14
          lda # >(AfterBeginPublisherPrelude-1)
          pha
          lda # <(AfterBeginPublisherPrelude-1)
          pha
          lda # >(BeginPublisherPrelude-1)
          pha
          lda # <(BeginPublisherPrelude-1)
          pha
          ldx # 13
          jmp BS_jsr

AfterBeginPublisherPrelude:

          ;; Step 5: Tail call to MainLoop
          jmp MainLoop

.pend

