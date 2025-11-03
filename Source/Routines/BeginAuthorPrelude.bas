          rem ChaosFight - Source/Routines/BeginAuthorPrelude.bas
          rem Setup routine for Author Preamble. Sets initial state only.

BeginAuthorPrelude
          rem Initialize Author Preamble mode
          rem Set playfield resolution for admin screen
          const pfres = 32
          
          rem Initialize timer
          PreambleTimer = 0
          
          rem Set background color
          COLUBK = ColGray(0)
          
          rem Start "Interworldly" music
          rem MusicInterworldly constant should be defined in MusicSystem
          temp1 = 0
          rem TODO: Define MusicInterworldly constant
          rem temp1 = MusicInterworldly
          gosub bank16 StartMusic
          
          rem Note: Bitmap loading happens each frame in AuthorPreamble loop
          rem via LoadAuthorBitmap subroutine
          
          return


