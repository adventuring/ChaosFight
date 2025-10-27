          rem ChaosFight - Source/Routines/AuthorPreamble.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem =================================================================
          rem AUTHOR PREAMBLE SCREEN
          rem =================================================================
          rem Displays the Interworldly author logo/artwork with music.
          rem This is the second screen shown at cold start.
          rem
          rem FLOW:
          rem   1. Load 32×32 playfield from Source/Art/Interworldly.xcf
          rem   2. Play "Interworldly" music
          rem   3. Wait for music completion + 0.5s OR button press
          rem   4. Transition to title screen
          rem
          rem PLAYFIELD CONFIGURATION:
          rem   - Size: 32×32 (pfres=32)
          rem   - Color-per-row for COLUPF and COLUBK
          rem   - Uses all 128 bytes SuperChip RAM
          rem
          rem AVAILABLE VARIABLES:
          rem   PreambleTimer - Frame counter for timing
          rem   MusicPlaying - Music state flag
          rem   QuadtariDetected - For checking all controllers
          rem =================================================================

AuthorPreamble
          rem Initialize preamble
          const pfres = 32
          PreambleTimer = 0
          COLUBK = ColBlack(0)
          
          rem Load author artwork
          gosub LoadAuthorPlayfield
          
          rem TODO: Start "Interworldly" music
          rem gosub PlayMusicInterworldly
          
AuthorPreambleLoop
          rem Check for button press on any controller
          if joy0fire || joy1fire then goto AuthorPreambleComplete
          if QuadtariDetected then
                    if joy2fire || joy3fire then goto AuthorPreambleComplete
          endif
          
          rem TODO: Update music
          rem gosub UpdateMusic
          
          rem Check timing: music complete + 30 frames (0.5s)
          rem TODO: Check if MusicPlaying = 0
          rem if PreambleTimer > 30 && !MusicPlaying then goto AuthorPreambleComplete
          
          rem Increment timer
          PreambleTimer = PreambleTimer + 1
          
          rem Temporary: auto-advance after 5 seconds (300 frames)
          if PreambleTimer > 300 then goto AuthorPreambleComplete
          
          drawscreen
          goto AuthorPreambleLoop

AuthorPreambleComplete
          return

          rem =================================================================
          rem LOAD AUTHOR PLAYFIELD
          rem =================================================================
          rem Loads the Interworldly author artwork with color-per-row.
          rem Generated from Source/Art/Interworldly.xcf → Interworldly.png
          rem SkylineTool creates architecture-specific data files.
          rem
          rem USES COLOR-PER-ROW:
          rem   Each row sets COLUPF and COLUBK individually
          rem   Allows gradient effects, multi-color artwork
          rem
          rem GENERATED FILES:
          rem   - Source/Generated/Playfield.Interworldly.NTSC.bas
          rem   - Source/Generated/Playfield.Interworldly.PAL.bas
          rem   - Source/Generated/Playfield.Interworldly.SECAM.bas
LoadAuthorPlayfield
          rem Load architecture-specific playfield data
          #ifdef TV_NTSC
          #include "Source/Generated/Playfield.Interworldly.NTSC.bas"
          #endif
          #ifdef TV_PAL
          #include "Source/Generated/Playfield.Interworldly.PAL.bas"
          #endif
          #ifdef TV_SECAM
          #include "Source/Generated/Playfield.Interworldly.SECAM.bas"
          #endif
          
          return

