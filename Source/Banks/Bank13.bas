          rem ChaosFight - Source/Banks/Bank13.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem
          rem GENERAL CODE BANK (shared memory budget - 8 banks total)
          rem Input system (movement, player input, guard effects)

          bank 13

          asm
Bank13DataEnds = .
end

          rem Character attack type routines (back from Bank 12 - rebalancing)
#include "Source/Routines/GetCharacterAttackType.bas"
#include "Source/Routines/IsCharacterRanged.bas"
#include "Source/Routines/IsCharacterMelee.bas"

          rem Player state routines (back from Bank 12 - rebalancing)
#include "Source/Routines/IsPlayerEliminated.bas"
#include "Source/Routines/IsPlayerAlive.bas"

          rem Physics/collision routines moved from Bank 8 for ROM balance
#include "Source/Routines/CheckPlayerCollision.bas"

          rem Movement/physics routines moved from Bank 8 to make room for FallDamage
          rem Large routines moved to Bank 10/11 to prevent Bank 13 overflow
#include "Source/Routines/GetPlayerAnimationStateFunction.bas"
#include "Source/Routines/ConstrainToScreen.bas"
#include "Source/Routines/AddVelocitySubpixelY.bas"
#include "Source/Routines/HandlePauseInput.bas"

          rem Movement routines moved from Banks 12/14/11 to prevent overflow
          rem Physics moved to Bank 14 to prevent Bank 13 overflow
#include "Source/Routines/ProcessStandardMovement.bas"

          rem Player state routines moved to Bank 12 for ROM balance (elimination-related)

#include "Source/Routines/CharacterControlsDown.bas"
#include "Source/Routines/ConsoleHandling.bas"
#include "Source/Routines/CharacterControlsJump.bas"

          asm
Bank13CodeEnds = .
end
