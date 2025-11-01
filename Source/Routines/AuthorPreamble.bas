          rem ChaosFight - Source/Routines/AuthorPreamble.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem =================================================================
          rem AUTHOR PREAMBLE SCREEN
          rem =================================================================
          rem Displays the Interworldly author logo/artwork with music.
          rem This is the second screen shown at cold start.

          rem FLOW:
          rem   1. Load 32×32 playfield from Source/Art/Interworldly.xcf
          rem   2. Play "Interworldly" music
          rem   3. Wait for music completion + 0.5s OR button press
          rem   4. Transition to title screen

          rem PLAYFIELD CONFIGURATION:
          rem   - Size: 32×32 (pfres=32)
          rem   - Color-per-row for COLUPF
          rem   - Uses all 128 bytes SuperChip RAM

          rem AVAILABLE VARIABLES:
          rem   PreambleTimer - Frame counter for timing
          rem   MusicPlaying - Music state flag
          rem   QuadtariDetected - For checking all controllers
          rem =================================================================

AuthorPreamble
AuthorMainLoop
          rem Check for button press on any controller to skip
          rem Use skip-over pattern to avoid complex || operator issues
          if joy0fire then goto AuthorPreambleComplete
          if joy1fire then goto AuthorPreambleComplete
          if ControllerStatus & SetQuadtariDetected then goto AuthorCheckQuadtari
          goto AuthorSkipQuadtari
AuthorCheckQuadtari
          if !INPT0{7} then goto AuthorPreambleComplete
          if !INPT2{7} then goto AuthorPreambleComplete
AuthorSkipQuadtari
          
          rem Update music
          gosub bank16 UpdateMusic
          
          rem Auto-advance after music completes + 0.5s
          if PreambleTimer > 30 && ! MusicPlaying then goto AuthorPreambleComplete
          
          rem Increment timer
          let PreambleTimer = PreambleTimer + 1
          
          drawscreen
          goto AuthorMainLoop

AuthorPreambleComplete
          let GameMode = ModeTitle : gosub ChangeGameMode
          return

          rem =================================================================
          rem LOAD AUTHOR PLAYFIELD
          rem =================================================================
          rem Loads the Interworldly author artwork with color-per-row.
          rem Generated from Source/Art/Interworldly.xcf → Interworldly.png
          rem SkylineTool creates architecture-specific data files.

          rem uses pfcolors

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

