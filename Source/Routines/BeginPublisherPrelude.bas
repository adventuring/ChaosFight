BeginPublisherPrelude
          asm
BeginPublisherPrelude

end
          rem
          rem ChaosFight - Source/Routines/BeginPublisherPrelude.bas
          rem Copyright © 2025 Bruce-Robert Pocock.
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
          rem   - Window values for Publisher screen bitmaps
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
          rem Called Routines: StartMusic (bank15) - starts AtariToday
          rem music, SetPublisherWindowValues (bank14) - sets window values for bitmaps
          rem
          rem Constraints: Called from ChangeGameMode when transitioning
          rem to ModePublisherPrelude
          rem Initialize prelude timer
          let preambleTimer = 0

          rem Disable character parade (only active on title screen, not preludes)
          let titleParadeActive = 0

          rem Background: black (COLUBK starts black, no need to set)

          rem Start AtariToday music
          rem BeginPublisherPrelude calls SetPublisherWindowValues bank14 (cross-bank via BS_jsr)
          rem SetPublisherWindowValues returns with return otherbank (jmp BS_return)
          rem This means BeginPublisherPrelude MUST also return with return otherbank
          rem Even though BeginPublisherPrelude is called same-bank from SetupPublisherPrelude,
          rem the cross-bank call to SetPublisherWindowValues forces the entire chain to use far returns
          let temp1 = MusicAtariToday
          gosub StartMusic bank15

          rem Set window values for Publisher screen (AtariAge logo + AtariAge text)
          rem Window values are set once during setup, not every frame
          gosub SetPublisherWindowValues bank14

          return otherbank
