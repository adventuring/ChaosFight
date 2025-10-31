          rem ChaosFight - Source/Routines/PublisherPreamble.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem =================================================================
          rem PUBLISHER PREAMBLE SCREEN
          rem =================================================================
          rem Displays the AtariAge publisher logo/artwork with music.
          rem This is the first screen shown at cold start.

          rem FLOW:
          rem   1. Load 32×32 playfield from Source/Art/AtariAge.xcf
          rem   2. Play "AtariToday" jingle
          rem   3. Wait for jingle completion + 0.5s OR button press
          rem   4. Transition to author preamble

          rem PLAYFIELD CONFIGURATION:
          rem   - Size: 32×32 (pfres=32)
          rem   - Color-per-row for COLUPF and COLUBK
          rem   - Uses all 128 bytes SuperChip RAM

          rem AVAILABLE VARIABLES:
          rem   PreambleTimer - Frame counter for timing
          rem   MusicPlaying - Music state flag
          rem   QuadtariDetected - For checking all controllers
          rem =================================================================

PublisherPreamble
          rem Check for button press on any controller to skip
          if joy0fire || joy1fire then goto PublisherPreambleComplete
          
          if ControllerStatus & SetQuadtariDetected then goto PubCheckQuad

          goto PubSkipQuad

PubCheckQuad
          if !INPT0{7} then goto PublisherPreambleComplete
          if !INPT2{7} then goto PublisherPreambleComplete
PubSkipQuad
          gosub UpdateMusic

          rem Auto-advance after music completes + 0.5s
         if PreambleTimer > 30 && MusicPlaying = 0 then goto PublisherPreambleComplete

          PreambleTimer = PreambleTimer + 1

          return

PublisherPreambleComplete
          GameMode = ModeAuthorPreamble : gosub ChangeGameMode
          return


