BeginAuthorPrelude
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
          rem Called Routines: StartMusic (bank16) - starts Interworldly
          rem music,
          rem   SetAuthorWindowValues (bank12) - sets window values
          rem
          rem Constraints: Called from ChangeGameMode when transitioning
          rem to ModeAuthorPrelude
          rem Initialize Author Prelude mode
          rem Note: pfres is defined globally in AssemblyConfig.bas
          
          let preambleTimer = 0 : rem Initialize timer
          
          rem Set background color
          COLUBK = ColGray(0)
          
          rem Start Interworldly music
          temp1 = MusicInterworldly
          gosub StartMusic bank16
          
          gosub SetAuthorWindowValues bank12 : rem Set window values for Author screen (Interworldly only)
          
          rem Note: Bitmap data is loaded automatically by titlescreen
          rem   kernel via includes
          
          return


