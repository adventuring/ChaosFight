          rem ChaosFight - Source/Routines/BeginAuthorPrelude.bas
          rem Setup routine for Author Prelude. Sets initial state
          rem   only.

BeginAuthorPrelude
          rem Initialize Author Prelude mode
          rem Note: pfres is defined globally in AssemblyConfig.bas
          
          rem Initialize timer
          let preambleTimer = 0
          
          rem Set background color
          COLUBK = ColGray(0)
          
          rem Start Interworldly music
          temp1 = MusicInterworldly
          gosub StartMusic bank16
          
          rem Set window values for Author screen (Interworldly only)
          gosub SetAuthorWindowValues bank12
          
          rem Note: Bitmap data is loaded automatically by titlescreen
          rem   kernel via includes
          
          return


