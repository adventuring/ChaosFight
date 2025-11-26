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

          rem Background: black (COLUBK starts black, no need to set)

          rem Start Interworldly music
          let temp1 = MusicInterworldly
          gosub StartMusic bank15

          rem Set window values for Author screen (Interworldly only)
          gosub SetAuthorWindowValues bank14

          rem Note: Bitmap data is loaded automatically by titlescreen
          rem   kernel via includes
          rem BeginAuthorPrelude is called same-bank from SetupAuthorPrelude (both in bank14)
          rem SetupAuthorPrelude uses gosub (same-bank call, pushes 2 bytes), so return thisbank is correct
          rem SetupAuthorPrelude itself returns with return otherbank to handle the cross-bank call to ChangeGameMode
          return thisbank

