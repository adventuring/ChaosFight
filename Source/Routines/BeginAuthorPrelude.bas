BeginAuthorPrelude
          asm
BeginAuthorPrelude

end
          rem ChaosFight - Source/Routines/BeginAuthorPrelude.bas
          rem Setup routine for Author Prelude. Sets initial state
          rem   only.
          rem Setup routine for Author Prelude - sets initial state only
          rem
          rem Input: None (called from ChangeGameMode)
          rem
          rem Output: preambleTimer initialized, COLUBK set, music
          rem started, window values set
          rem
          rem Mutates: preambleTimer (set to 0), COLUBK (TIA register),
          rem temp1 (passed to StartMusic)
          rem
          rem Called Routines: StartMusic (bank1) - starts Interworldly
          rem music,
          rem   SetAuthorWindowValues (bank14) - sets window values
          rem
          rem Constraints: Called from ChangeGameMode when transitioning
          rem to ModeAuthorPrelude
          rem Initialize Author Prelude mode
          rem Note: pfres is defined globally in AssemblyConfig.bas

          rem Initialize timer
          let preambleTimer = 0

          rem Disable character parade (only active on title screen, not preludes)
          let titleParadeActive = 0

          rem Background: black (COLUBK starts black, no need to set)

          rem Start Interworldly music
          let temp1 = MusicInterworldly
          gosub StartMusic bank15

          rem Set window values for Author screen (Interworldly only)
          rem OPTIMIZATION: Same-bank call to save 2 bytes on stack
          gosub SetAuthorWindowValues

          rem Note: Bitmap data is loaded automatically by titlescreen
          rem   kernel via includes
          rem BeginAuthorPrelude is called cross-bank from SetupAuthorPrelude
          rem (gosub BeginAuthorPrelude bank14 forces BS_jsr even though same bank)
          rem so it must return with return otherbank to match
          return otherbank
