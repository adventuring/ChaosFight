          rem ChaosFight - Source/Routines/BeginPublisherPrelude.bas
          rem Setup routine for Publisher Preamble. Sets initial state only.

BeginPublisherPrelude
          rem Initialize preamble
          const pfres = 32
          PreambleTimer = 0
          COLUBK = ColGray(0)
          
          rem Load publisher artwork
          gosub LoadPublisherPlayfield
          
          rem Start "AtariToday" music
          temp1 = MusicAtariToday
          gosub StartMusic
          
          return

          rem =================================================================
          rem LOAD PUBLISHER PLAYFIELD
          rem =================================================================
          rem Loads the AtariAge publisher artwork with color-per-row.
          rem Generated from Source/Art/AtariAge.xcf → AtariAge.png
          rem SkylineTool creates architecture-specific data files.

          rem GENERATED FILES:
          rem   - Source/Generated/Playfield.AtariAge.NTSC.bas
          rem   - Source/Generated/Playfield.AtariAge.PAL.bas
          rem   - Source/Generated/Playfield.AtariAge.SECAM.bas
LoadPublisherPlayfield
          rem Load architecture-specific playfield data
          #ifdef TV_NTSC
          #include "Source/Generated/Playfield.AtariAge.NTSC.bas"
          #endif
          #ifdef TV_PAL
          #include "Source/Generated/Playfield.AtariAge.PAL.bas"
          #endif
          #ifdef TV_SECAM
          #include "Source/Generated/Playfield.AtariAge.SECAM.bas"
          #endif
          
          return




