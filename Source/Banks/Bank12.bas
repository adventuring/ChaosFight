          rem ChaosFight - Source/Banks/Bank12.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem
          rem GENERAL CODE BANK (shared memory budget - 8 banks total)
          rem Character data system (definitions, cycles, fall damage) +
          rem Titlescreen graphics and kernel

          bank 12

          rem Character data tables
#include "Source/Data/CharacterThemeSongIndices.bas"

          asm
Bank12DataEnds
end

          rem Titlescreen assets are in Bank 9 - this bank contains only logic

#include "Source/Routines/MissileSystem.bas"

          rem Health display routines (DisplayHealth only - HealthBarSystem moved to Bank 8)
#include "Source/Routines/DisplayHealth.bas"

          rem Character damage routine moved from Bank 8 for ROM balance
#include "Source/Routines/CharacterDamage.bas"

          rem Attack cooldown routine moved back to Bank 11 for ROM balance (Bank 12 too full)

          rem Player position/velocity helpers moved to Bank 7 for ROM balance

          rem Physics helper moved to Bank 7 for ROM balance

          rem Character attack type helpers moved back to Bank 13 for ROM balance (Bank 12 too full)

          rem Player state helpers moved back to Bank 13 for ROM balance (Bank 12 too full)

          rem Character attack routines moved back to Bank 10 for ROM balance (Bank 12 too full)

#include "Source/Routines/DeactivatePlayerMissiles.bas"
#include "Source/Routines/TriggerEliminationEffects.bas"
#include "Source/Routines/UpdatePlayers34ActiveFlag.bas"
#include "Source/Routines/CountRemainingPlayers.bas"
#include "Source/Routines/FindLastEliminated.bas"
#include "Source/Routines/FindWinner.bas"
#include "Source/Routines/CheckPlayerElimination.bas"
#include "Source/Routines/CheckAllPlayerEliminations.bas"
#include "Source/Routines/ArenaReloadUtils.bas"
#include "Source/Routines/BeginArenaSelect.bas"
#include "Source/Routines/MovePlayerToTarget.bas"
#include "Source/Routines/WinnerAnnouncement.bas"
#include "Source/Routines/BeginWinnerAnnouncement.bas"

          asm
Bank12CodeEnds
end
