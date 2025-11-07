AttractMode
          rem
          rem ChaosFight - Source/Routines/AttractMode.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem ATTRACT MODE LOOP - Called From Mainloop Each Frame
          rem
          rem This is the main loop that runs each frame during Attract
          rem   mode.
          rem Called repeatedly from MainLoop dispatcher.
          rem Setup is handled by BeginAttractMode (called from
          rem   ChangeGameMode).
          rem Attract mode automatically transitions back to Publisher
          rem   Prelude
          rem to restart the title sequence after 3 minutes of
          rem   inactivity.
          rem Attract mode automatically loops back to Publisher Prelude
          rem No user interaction - just transition immediately
          rem This creates a continuous attract loop: Publisher → Author
          rem   → Title → Attract → (repeat)
          rem Input: None (called from MainLoop)
          rem Output: gameMode set to ModePublisherPrelude,
          rem ChangeGameMode called
          rem Mutates: gameMode (global)
          rem Called Routines: ChangeGameMode (bank14) - accesses game
          rem mode state
          rem Constraints: Entry point for attract mode (called from
          rem MainLoop)
          let gameMode = ModePublisherPrelude : gosub ChangeGameMode bank14 : rem Only reachable via gosub from MainLoop
          return

