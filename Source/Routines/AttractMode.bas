          rem ChaosFight - Source/Routines/AttractMode.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem ==========================================================
          rem ATTRACT MODE LOOP - Called from MainLoop each frame
          rem ==========================================================
          rem This is the main loop that runs each frame during Attract
          rem   mode.
          rem Called repeatedly from MainLoop dispatcher.
          rem Setup is handled by BeginAttractMode (called from
          rem   ChangeGameMode).
          rem
          rem Attract mode automatically transitions back to Publisher
          rem   Prelude
          rem to restart the title sequence after 3 minutes of
          rem   inactivity.

AttractMode
          rem Attract mode automatically loops back to Publisher Prelude
          rem No user interaction - just transition immediately
          rem This creates a continuous attract loop: Publisher → Author
          rem   → Title → Attract → (repeat)
          let gameMode = ModePublisherPrelude : gosub ChangeGameMode bank1
          return

