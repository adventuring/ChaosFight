          rem ChaosFight - Source/Routines/ColdStart.bas
          rem Copyright © 2025 Bruce-Robert Pocock.

ColdStart
          rem Returns: Far (return otherbank)
          asm
ColdStart
end
          rem Cold Start Initialization
          rem Returns: Far (return otherbank)
          rem
          rem Proper cold start initialization sequence for batariBASIC.
          rem Called from Reset handler (BankSwitching.s) - Reset handler
          rem   in every bank switches to Bank 14 and jumps to ColdStart.
          rem
          rem This routine handles game-specific initialization:
          rem   1. Hardware detection (console type)
          rem   2. TIA register initialization (colors, audio)
          rem   3. Game state initialization
          rem   4. Transition to first game mode
          rem Step 1: Detect console hardware type (7800 vs 2600)
          rem This MUST run before any code modifies $D0/$D1 registers
          rem as those registers are used for hardware detection
          rem
          rem Input: None (cold start entry point)
          rem
          rem Output: Console type detected, sprite pointers
          rem initialized,
          rem         TIA registers initialized, gameMode set,
          rem         transitions to MainLoop
          rem
          rem Mutates: Console detection state (via ConsoleDetHW),
          rem         Sprite pointer state (via
          rem         InitializeSpritePointers),
          rem         COLUBK, COLUPF, COLUP0, _COLUP1, AUDC0, AUDV0,
          rem         AUDC1, AUDV1,
          rem         gameMode (global)
          rem
          rem Called Routines: ConsoleDetHW (bank1) - accesses $D0/$D1
          rem hardware registers,
          rem   InitializeSpritePointers (bank14) - sets sprite pointer
          rem   addresses,
          rem   ChangeGameMode (bank1) - sets up initial game mode
          rem
          rem Constraints: Must be entry point for cold start (called
          rem from Bank1)
          rem
          rem CRITICAL: Console detection MUST run inline (not as subroutine)
          rem because the stack is not yet initialized. It must execute
          rem before any code modifies $D0/$D1 registers.
#include "Source/Routines/ConsoleDetection.bas"
          rem After console detection, we need to initialize:
          rem   - RAM clearing (all RAM set to 0)
          rem   - Stack initialization (SP = $FF)
          rem   - Register initialization (A = X = Y = 0)
          rem   - Decimal mode disabled (CLD)
          rem This routine is designed to be included directly
          rem here and will fall through to continue.

          asm
#include "Source/Common/Startup.s"
end
          rem Step 2: Initialize sprite pointers to RAM addresses
          rem Must be done before any sprite loading to ensure pointers
          rem   point to SCRAM buffers instead of ROM
          rem CRITICAL: InitializeSpritePointers is called both same-bank (from ColdStart)
          rem and cross-bank (from BeginGameLoop). Since it’s called cross-bank, it must
          rem always use return otherbank. When called same-bank, specifying bank14 still
          rem uses cross-bank mechanism, so the return otherbank matches.
          gosub InitializeSpritePointers bank14

          rem Step 3: Initialize TIA color registers to safe defaults
          rem Prevents undefined colors on cold start
          rem Background: black (COLUBK starts black, no need to set)
          rem Playfield: white
          rem Player 1 (P0): indigo
          COLUPF = ColGrey(14)
          rem Player 2: bright red (multisprite kernel requires _COLUP1)
          COLUP0 = ColIndigo(12)
          rem Player 3: yellow
          _COLUP1 = ColRed(12)
          rem Player 4: green
          COLUP2 = ColYellow(12)
          COLUP3 = ColGreen(12)


          rem Step 5: Initialize game state and transition to first mode
          rem Set initial game mode (Publisher Prelude)
          rem ChangeGameMode calls SetupPublisherPrelude and sets up
          let gameMode = ModePublisherPrelude
          rem   music
          gosub ChangeGameMode bank14

          rem Step 6: Jump to MainLoop (in Bank 16)
          rem MainLoop will handle the game mode dispatch and frame
          rem   rendering
          goto MainLoop bank16

