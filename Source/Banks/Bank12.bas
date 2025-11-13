          rem ChaosFight - Source/Banks/Bank12.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem
          rem GENERAL CODE BANK (shared memory budget - 8 banks total)
          rem Character data system (definitions, cycles, fall damage) +
          rem Titlescreen graphics and kernel

          asm
Bank12DataEnds
end

          rem Titlescreen assets are in Bank 9 - this bank contains only logic

#include "Source/Routines/CharacterData.bas"
#include "Source/Routines/MissileSystem.bas"
#include "Source/Routines/CheckAllPlayerEliminations.bas"
#include "Source/Routines/CheckPlayerElimination.bas"
#include "Source/Routines/CountRemainingPlayers.bas"
#include "Source/Routines/DeactivatePlayerMissiles.bas"
#include "Source/Routines/FindLastEliminated.bas"
#include "Source/Routines/FindWinner.bas"
#include "Source/Routines/IsPlayerAlive.bas"
#include "Source/Routines/IsPlayerEliminated.bas"
#include "Source/Routines/TriggerEliminationEffects.bas"
#include "Source/Routines/UpdatePlayers34ActiveFlag.bas"
#include "Source/Routines/ArenaReloadUtils.bas"
#include "Source/Routines/BeginArenaSelect.bas"
#include "Source/Routines/MovePlayerToTarget.bas"
#include "Source/Routines/WinnerAnnouncement.bas"
#include "Source/Routines/BeginWinnerAnnouncement.bas"

          asm
Bank12CodeEnds
end
