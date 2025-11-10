          rem ChaosFight - Source/Banks/Bank12.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem
          rem GENERAL CODE BANK (shared memory budget - 8 banks total)
          rem Character data system (definitions, cycles, falling animation, fall damage) +
          rem Titlescreen graphics and kernel

          bank 12

          rem Titlescreen assets are in Bank 9 - this bank contains only logic

#include "Source/Routines/CharacterData.bas"
#include "Source/Routines/CharacterCycleUtils.bas"
#include "Source/Routines/FallingAnimation.bas"
#include "Source/Routines/BeginArenaSelect.bas"
#include "Source/Routines/ArenaSelect.bas"
#include "Source/Routines/BeginWinnerAnnouncement.bas"
#include "Source/Routines/WinnerAnnouncement.bas"
#include "Source/Routines/DisplayWinScreen.bas"
#include "Source/Common/CharacterDefinitions.bas"
#include "Source/Routines/TitlescreenWindowControl.bas"

#include "Source/Routines/BeginPublisherPrelude.bas"
#include "Source/Routines/PublisherPrelude.bas"
#include "Source/Routines/BeginAuthorPrelude.bas"
#include "Source/Routines/AuthorPrelude.bas"

