          rem ChaosFight - Source/Banks/Bank12.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          bank 12

          rem Include Arenas.bas for WinnerScreenPlayfield data
          #include "Source/Data/Arenas.bas"

          #include "Source/Routines/BeginFallingAnimation.bas"
          #include "Source/Routines/FallingAnimation.bas"
          #include "Source/Routines/BeginLevelSelect.bas"
          #include "Source/Routines/LevelSelect.bas"
          #include "Source/Data/CharacterThemeSongIndices.bas"
          rem Character-to-theme-song mapping table for winner
          rem   announcements
          #include "Source/Routines/BeginWinnerAnnouncement.bas"
          #include "Source/Routines/WinnerAnnouncement.bas"
          #include "Source/Routines/DisplayWinScreen.bas"
          rem DisplayWinScreen function for winner screen with fixed
          rem   playfield and 1-3 characters
          #include "Source/Routines/FontRendering.bas"
          rem Font rendering for arena number display ( 1-32/??)
          #include "Source/Routines/TitlescreenWindowControl.bas"
          rem Titlescreen kernel window control for per-screen bitmap
          rem   display
