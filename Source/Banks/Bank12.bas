          rem ChaosFight - Source/Banks/Bank12.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          bank 12
 
#include "Source/Data/WinnerScreen.bas"
#include "Source/Data/CharacterThemeSongIndices.bas"
          rem Data tables for winner screen layouts and theme mapping

#include "Source/Routines/BeginFallingAnimation.bas"
#include "Source/Routines/FallingAnimation.bas"
#include "Source/Routines/BeginArenaSelect.bas"
#include "Source/Routines/ArenaSelect.bas"
#include "Source/Routines/BeginWinnerAnnouncement.bas"
#include "Source/Routines/WinnerAnnouncement.bas"
#include "Source/Routines/DisplayWinScreen.bas"
          rem DisplayWinScreen function for winner screen with fixed
          rem   playfield and 1-3 characters
#include "Source/Routines/TitlescreenWindowControl.bas"
          rem Titlescreen kernel window control for per-screen bitmap
          rem   display
