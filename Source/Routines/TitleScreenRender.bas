          rem ChaosFight - Source/Routines/TitleScreenRender.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem =================================================================
          rem TITLE SCREEN RENDERING
          rem =================================================================
          rem Renders the title screen using a 32×32 playfield image.
          rem The playfield data is generated from Source/Art/TitleScreen.png
          rem by SkylineTool and included as Source/Generated/Playfield.TitleScreen.bas
          rem
          rem PLAYFIELD CONFIGURATION:
          rem   - Size: 32 pixels wide × 32 rows high
          rem   - Uses pfres=32 (maximum height with SuperChip)
          rem   - Consumes all 128 bytes of SuperChip RAM (32 rows × 4 bytes/row)
          rem   - Mirrored display (32px playfield → 160px visible width)
          rem
          rem AVAILABLE VARIABLES:
          rem   TitleParadeActive - Whether to draw parade character
          rem   COLUBK - Background color
          rem   COLUPF - Playfield color
          rem =================================================================

          rem Main draw routine for title screen
DrawTitleScreen
          rem Set playfield resolution for title screen
          const pfres = 32
          
          rem Clear sprites first
          player0x = 0
          player0y = 0
          player1x = 0
          player1y = 0
          
          rem Load title screen playfield data
          gosub LoadTitlePlayfield
          
          rem Draw character parade if active
          if TitleParadeActive then
                    gosub DrawParadeCharacter
          endif
          
          return

          rem =================================================================
          rem LOAD TITLE PLAYFIELD
          rem =================================================================
          rem Loads the title screen playfield image into SuperChip RAM.
          rem This is a 32×32 pixel playfield generated from Source/Art/ChaosFight.xcf
          rem The generated files are architecture-specific:
          rem   - Source/Generated/Playfield.ChaosFight.NTSC.bas
          rem   - Source/Generated/Playfield.ChaosFight.PAL.bas
          rem   - Source/Generated/Playfield.ChaosFight.SECAM.bas
          rem
          rem USES:
          rem   pfpixel commands to set playfield pixels
          rem   COLUPF - Playfield color
LoadTitlePlayfield
          rem Set playfield color
          COLUPF = ColCyan(14)
          
          rem Load architecture-specific playfield data
          rem This is included from Generated/Playfield.ChaosFight.*.bas
          rem which is compiled via CPP preprocessing based on platform
          #ifdef TV_NTSC
          #include "Source/Generated/Playfield.ChaosFight.NTSC.bas"
          #endif
          #ifdef TV_PAL
          #include "Source/Generated/Playfield.ChaosFight.PAL.bas"
          #endif
          #ifdef TV_SECAM
          #include "Source/Generated/Playfield.ChaosFight.SECAM.bas"
          #endif
          
          return

