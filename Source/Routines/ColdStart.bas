          rem ChaosFight - Source/Routines/ColdStart.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem Cold start initialization
          rem Detect console type FIRST before any other setup
          rem This must run before anything else that might modify $D0/$D1

ColdStart
          rem Detect if running on 7800 or 2600
          gosub DetectConsole
          
          rem Initialize game state
          COLUBK = ColBlack(0)
          
          return
