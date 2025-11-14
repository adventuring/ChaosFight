          rem ChaosFight - Source/Banks/Bank13.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem
          rem GENERAL CODE BANK (shared memory budget - 8 banks total)
          rem Input system (movement, player input, guard effects)

          bank 13

          asm
Bank13DataEnds
end

          rem Character attack type routines moved from Bank 12 for ROM balance
#include "Source/Routines/GetCharacterAttackType.bas"
#include "Source/Routines/IsCharacterRanged.bas"
#include "Source/Routines/IsCharacterMelee.bas"

          rem Physics/collision routines moved from Bank 8 for ROM balance
#include "Source/Routines/CheckPlayerCollision.bas"
#include "Source/Routines/ConstrainToScreen.bas"
#include "Source/Routines/FallDamage.bas"

          rem Player state routines moved from Bank 12 for ROM balance
#include "Source/Routines/IsPlayerEliminated.bas"
#include "Source/Routines/IsPlayerAlive.bas"
          rem DeactivatePlayerMissiles moved from Bank 12 for ROM balance (Bank 12 overflow)
#include "Source/Routines/DeactivatePlayerMissiles.bas"
          rem CountRemainingPlayers moved from Bank 12 for ROM balance (Bank 12 overflow)
#include "Source/Routines/CountRemainingPlayers.bas"

#include "Source/Routines/CharacterControlsDown.bas"
#include "Source/Routines/ConsoleHandling.bas"
#include "Source/Routines/CharacterControlsJump.bas"

          asm
Bank13CodeEnds
end
