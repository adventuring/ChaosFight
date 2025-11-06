          rem ChaosFight - Source/Routines/BeginAuthorPrelude.bas
          rem Setup routine for Author Preamble. Sets initial state
          rem   only.

BeginAuthorPrelude
          rem Initialize Author Preamble mode
          rem Note: pfres is defined globally in AssemblyConfig.s
          
          rem Initialize timer
          let preambleTimer = 0
          
          rem Set background color
          COLUBK = ColGray(0)
          
          rem Start "Interworldly" music
          temp1 = MusicInterworldly
          gosub bank16 StartMusic
          
          rem Set window values for Author screen (Interworldly only)
          gosub bank12 SetAuthorWindowValues
          
          rem Note: Bitmap data is loaded automatically by titlescreen
          rem   kernel via includes
          
          return


