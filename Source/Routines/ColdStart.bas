          rem ChaosFight - Source/Routines/ColdStart.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem =================================================================
          rem COLD START INITIALIZATION
          rem =================================================================
          rem Proper cold start initialization sequence for batariBASIC.
          rem Called from Bank1 via "goto bank13 ColdStart" - this is the
          rem correct stanza format (Bank1 jumps to ColdStart in Bank13).
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
          rem =================================================================

ColdStart
          rem Step 1: Detect console hardware type (7800 vs 2600)
          rem This MUST run before any code modifies $D0/$D1 registers
          rem as those registers are used for hardware detection
          gosub bank14 ConsoleDetHW
          
          rem Step 2: Initialize TIA color registers to safe defaults
          rem Prevents undefined colors on cold start
          COLUBK = ColGray(0)
          rem Background: black
          COLUPF = ColGrey(14)
          rem Playfield: white
          COLUP0 = ColBlue(14)
          rem Player 0: bright blue
          _COLUP1 = ColRed(14)
          rem Player 1: bright red (multisprite kernel requires _COLUP1)

          rem Step 3: Initialize audio channels (silent on cold start)
          AUDC0 = 0
          AUDV0 = 0
          AUDC1 = 0
          AUDV1 = 0
          
          rem Step 4: Initialize game state and transition to first mode
          rem Set initial game mode (Publisher Preamble)
          gameMode = ModePublisherPreamble
          gosub bank13 ChangeGameMode
          rem ChangeGameMode calls SetupPublisherPreamble and sets up music
          
          rem Step 5: Fall through to MainLoop
          rem MainLoop will handle the game mode dispatch and frame rendering

