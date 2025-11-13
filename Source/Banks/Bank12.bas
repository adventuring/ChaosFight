          rem ChaosFight - Source/Banks/Bank12.bas
Bank12DataEnds
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem
          rem GENERAL CODE BANK (shared memory budget - 8 banks total)
          rem Character data system (definitions, cycles, fall damage) +
          rem Titlescreen graphics and kernel


          rem Titlescreen assets are in Bank 9 - this bank contains only logic

#include "Source/Routines/CharacterData.bas"
#include "Source/Routines/MissileSystem.bas"
#include "Source/Routines/PlayerElimination.bas"
#include "Source/Routines/ArenaReloadUtils.bas"
#include "Source/Routines/BeginArenaSelect.bas"
#include "Source/Routines/MovePlayerToTarget.bas"
#include "Source/Routines/WinnerAnnouncement.bas"
#include "Source/Routines/BeginWinnerAnnouncement.bas"

Bank12CodeEnds
