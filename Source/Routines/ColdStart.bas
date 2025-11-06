          rem ChaosFight - Source/Routines/ColdStart.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem ==========================================================
          rem COLD START INITIALIZATION
          rem ==========================================================
          rem Proper cold start initialization sequence for batariBASIC.
          rem Called from Bank1 via goto ColdStart bank13 - this is
          rem   the
          rem correct stanza format (Bank1 jumps to ColdStart in
          rem   Bank13).
          rem
          rem batariBASIC’s startup.asm include handles:
          rem   - RAM clearing (all RAM set to 0)
          rem   - Stack initialization (SP = $FF)
          rem   - Register initialization (A = X = Y = 0)
          rem   - Decimal mode disabled (CLD)
          rem
          rem This routine handles game-specific initialization:
          rem   1. Hardware detection (console type)
          rem   2. TIA register initialization (colors, audio)
          rem   3. Game state initialization
          rem   4. Transition to first game mode
          rem ==========================================================

ColdStart
          rem Step 1: Detect console hardware type (7800 vs 2600)
          rem This MUST run before any code modifies $D0/$D1 registers
          rem as those registers are used for hardware detection
          gosub ConsoleDetHW bank1
          
          rem Step 2: Initialize sprite pointers to RAM addresses
          rem Must be done before any sprite loading to ensure pointers
          rem   point to SCRAM buffers instead of ROM
          gosub InitializeSpritePointers bank10
          
          rem Step 3: Initialize TIA color registers to safe defaults
          rem Prevents undefined colors on cold start
          COLUBK = ColGray(0)
          rem Background: black
          COLUPF = ColGrey(14)
          rem Playfield: white
          COLUP0 = ColBlue(14)
          rem Player 0: bright blue
          _COLUP1 = ColRed(14)
          rem Player 1: bright red (multisprite kernel requires _COLUP1)

          rem Step 4: Initialize audio channels (silent on cold start)
          AUDC0 = 0
          AUDV0 = 0
          AUDC1 = 0
          AUDV1 = 0
          
          rem Step 5: Initialize game state and transition to first mode
          rem Set initial game mode (Publisher Prelude)
          let gameMode = ModePublisherPrelude
          gosub ChangeGameMode bank1
          rem ChangeGameMode calls SetupPublisherPrelude and sets up
          rem   music
          
          rem Step 6: Jump to MainLoop (in Bank 1)
          rem MainLoop will handle the game mode dispatch and frame
          rem   rendering
          goto MainLoop bank1

