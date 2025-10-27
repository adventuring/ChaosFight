          rem ChaosFight - Source/Routines/PublisherPreamble.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem =================================================================
          rem PUBLISHER PREAMBLE SCREEN
          rem =================================================================
          rem Displays the AtariAge publisher logo/artwork with music.
          rem This is the first screen shown at cold start.
          rem
          rem FLOW:
          rem   1. Load 32×32 playfield from Source/Art/AtariAge.xcf
          rem   2. Play "AtariToday" jingle
          rem   3. Wait for jingle completion + 0.5s OR button press
          rem   4. Transition to author preamble
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

PublisherPreamble
          rem Initialize preamble
          const pfres = 32
          PreambleTimer = 0
          COLUBK = ColBlack(0)
          
          rem Load publisher artwork
          gosub LoadPublisherPlayfield
          
          rem TODO: Start "AtariToday" music
          rem gosub PlayMusicAtariToday
          
PublisherPreambleLoop
          rem Check for button press on any controller
          if joy0fire || joy1fire then goto PublisherPreambleComplete
          if QuadtariDetected then
                    if joy2fire || joy3fire then goto PublisherPreambleComplete
          endif
          
          rem TODO: Update music
          rem gosub UpdateMusic
          
          rem Check timing: music complete + 30 frames (0.5s)
          rem TODO: Check if MusicPlaying = 0
          rem if PreambleTimer > 30 && !MusicPlaying then goto PublisherPreambleComplete
          
          rem Increment timer
          PreambleTimer = PreambleTimer + 1
          
          rem Temporary: auto-advance after 5 seconds (300 frames)
          if PreambleTimer > 300 then goto PublisherPreambleComplete
          
          drawscreen
          goto PublisherPreambleLoop

PublisherPreambleComplete
          return

          rem =================================================================
          rem LOAD PUBLISHER PLAYFIELD
          rem =================================================================
          rem Loads the AtariAge publisher artwork with color-per-row.
          rem Generated from Source/Art/AtariAge.xcf → AtariAge.png
          rem SkylineTool creates architecture-specific data files.
          rem
          rem USES COLOR-PER-ROW:
          rem   Each row sets COLUPF and COLUBK individually
          rem   Allows gradient effects, multi-color artwork
          rem
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

