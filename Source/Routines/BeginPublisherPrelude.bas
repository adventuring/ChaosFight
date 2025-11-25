BeginPublisherPrelude
          asm
BeginPublisherPrelude

end
          rem
          rem ChaosFight - Source/Routines/BeginPublisherPrelude.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem Begin Publisher Prelude - Setup Routine
          rem
          rem Initializes state for Publisher Prelude screen (gameMode
          rem   0).
          rem Called from ChangeGameMode when transitioning to Publisher
          rem   Prelude.
          rem
          rem Sets up:
          rem   - Timer initialization
          rem   - Background color
          rem   - Music playback start
          rem Bitmap data is loaded automatically by titlescreen kernel
          rem   via includes.
          rem No explicit loading needed - titlescreen kernel handles
          rem   bitmap display.
          rem Initializes state for Publisher Prelude screen (gameMode
          rem 0)
          rem
          rem Input: None (called from ChangeGameMode)
          rem
          rem Output: preambleTimer initialized, COLUBK set, music
          rem started
          rem
          rem Mutates: preambleTimer (set to 0), COLUBK (TIA register),
          rem temp1 (passed to StartMusic)
          rem
          rem Called Routines: StartMusic (bank1) - starts AtariToday
          rem music
          rem
          rem Constraints: Called from ChangeGameMode when transitioning
          rem to ModePublisherPrelude
          let preambleTimer = 0
          rem Initialize prelude timer

          rem Background: black (COLUBK starts black, no need to set)

          rem Start AtariToday music
          let temp1 = MusicAtariToday
          gosub StartMusic bank15
          return




