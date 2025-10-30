          rem ChaosFight - Source/Routines/ColdStart.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem Cold start initialization
          rem Detect console type FIRST before any other setup
          rem This must run before anything else that might modify $D0/$D1

ColdStart
          rem Detect if running on 7800 or 2600
          gosub DetectConsole
          
          rem Initialize TIA colors to safe defaults
          COLUBK = ColGrey(0)
          COLUPF = ColGrey(14)
          COLUP0 = ColBlue(14)
          COLUP1 = ColRed(14)

          AUDC0 = 0
          AUDV0 = 0
          AUDC1 = 0
          AUDV1 = 0
          
          rem Reset game state variables
          GameMode = ModePublisherPrelude
          
          rem (fall through to MainLoop)

