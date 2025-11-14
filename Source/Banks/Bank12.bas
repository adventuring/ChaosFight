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
Bank12AfterCharacterThemeSongIndices = .
end

          rem Titlescreen assets are in Bank 9 - this bank contains only logic

#include "Source/Routines/MissileSystem.bas"

          asm
Bank12AfterMissileSystem = .
end

          rem CheckRoboTitoStretchMissileCollisions moved to Bank 6 for ROM balance

          rem Character damage routine moved from Bank 8 for ROM balance
#include "Source/Routines/CharacterDamage.bas"

          asm
Bank12AfterCharacterDamage = .
end

#include "Source/Routines/DeactivatePlayerMissiles.bas"

          asm
Bank12AfterDeactivatePlayerMissiles = .
end

#include "Source/Routines/TriggerEliminationEffects.bas"

          asm
Bank12AfterTriggerEliminationEffects = .
end

#include "Source/Routines/UpdatePlayers34ActiveFlag.bas"

          asm
Bank12AfterUpdatePlayers34ActiveFlag = .
end

#include "Source/Routines/CountRemainingPlayers.bas"

          asm
Bank12AfterCountRemainingPlayers = .
end

#include "Source/Routines/FindLastEliminated.bas"

          asm
Bank12AfterFindLastEliminated = .
end

#include "Source/Routines/FindWinner.bas"

          asm
Bank12AfterFindWinner = .
end

#include "Source/Routines/CheckPlayerElimination.bas"

          asm
Bank12AfterCheckPlayerElimination = .
end

#include "Source/Routines/CheckAllPlayerEliminations.bas"

          asm
Bank12AfterCheckAllPlayerEliminations = .
end

#include "Source/Routines/ArenaReloadUtils.bas"

          asm
Bank12AfterArenaReloadUtils = .
end

#include "Source/Routines/BeginArenaSelect.bas"

          asm
Bank12AfterBeginArenaSelect = .
end

#include "Source/Routines/MovePlayerToTarget.bas"

          asm
Bank12AfterMovePlayerToTarget = .
end

#include "Source/Routines/WinnerAnnouncement.bas"

          asm
Bank12AfterWinnerAnnouncement = .
end

#include "Source/Routines/BeginWinnerAnnouncement.bas"

          asm
Bank12AfterBeginWinnerAnnouncement = .
end

          asm
Bank12CodeEnds
end
