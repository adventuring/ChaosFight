          rem ChaosFight - Source/Routines/BeginAuthorPrelude.bas
          rem Setup routine for Author Preamble. Sets initial state only.

BeginAuthorPrelude
          rem Initialize preamble
          let preambleTimer = 0
          COLUBK = ColGray(0)
          
          rem Load author artwork
          gosub LoadAuthorPlayfield
          
          rem Start "Interworldly" music
          let temp1 = MusicInterworldly
          gosub StartMusic

          return


