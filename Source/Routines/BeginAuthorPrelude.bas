          rem ChaosFight - Source/Routines/BeginAuthorPrelude.bas
          rem Setup routine for Author Preamble. Sets initial state
          rem   only.

BeginAuthorPrelude
          rem Initialize Author Preamble mode
          rem Set playfield resolution for admin screen
          const pfres = 32
          
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


