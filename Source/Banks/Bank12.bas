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

#include "Source/Routines/UpdateAttackCooldowns.bas"
          asm
Bank12AfterUpdateAttackCooldowns
end
#include "Source/Routines/CharacterDamage.bas"
          asm
Bank12AfterCharacterDamage
end
#include "Source/Routines/HandleFlyingCharacterMovement.bas"
          asm
Bank12AfterHandleFlyingCharacterMovement
end
#include "Source/Routines/CharacterControlsJump.bas"
          asm
Bank12AfterCharacterControlsJump
end
#include "Source/Routines/AnimationSystem.bas"
          asm
Bank12AfterAnimationSystem
end
#include "Source/Routines/DeactivatePlayerMissiles.bas"
          asm
Bank12AfterDeactivatePlayerMissiles
end

          asm
Bank12CodeEnds
          if Bank12CodeEnds > ($FFE0 - bscode_length - 32)
           echo "Bank 12 file sizes (compiled code bytes):"
           echo "  UpdateAttackCooldowns: ", [Bank12AfterUpdateAttackCooldowns - Bank12DataEnds]d, " bytes"
           echo "  CharacterDamage: ", [Bank12AfterCharacterDamage - Bank12AfterUpdateAttackCooldowns]d, " bytes"
           echo "  HandleFlyingCharacterMovement: ", [Bank12AfterHandleFlyingCharacterMovement - Bank12AfterCharacterDamage]d, " bytes"
           echo "  CharacterControlsJump: ", [Bank12AfterCharacterControlsJump - Bank12AfterHandleFlyingCharacterMovement]d, " bytes"
           echo "  AnimationSystem: ", [Bank12AfterAnimationSystem - Bank12AfterCharacterControlsJump]d, " bytes"
           echo "  DeactivatePlayerMissiles: ", [Bank12AfterDeactivatePlayerMissiles - Bank12AfterAnimationSystem]d, " bytes"
          else
           echo "Bank 12 file sizes (compiled code bytes):"
           echo "  UpdateAttackCooldowns: ", [Bank12AfterUpdateAttackCooldowns - Bank12DataEnds]d, " bytes"
           echo "  CharacterDamage: ", [Bank12AfterCharacterDamage - Bank12AfterUpdateAttackCooldowns]d, " bytes"
           echo "  HandleFlyingCharacterMovement: ", [Bank12AfterHandleFlyingCharacterMovement - Bank12AfterCharacterDamage]d, " bytes"
           echo "  CharacterControlsJump: ", [Bank12AfterCharacterControlsJump - Bank12AfterHandleFlyingCharacterMovement]d, " bytes"
           echo "  AnimationSystem: ", [Bank12AfterAnimationSystem - Bank12AfterCharacterControlsJump]d, " bytes"
           echo "  DeactivatePlayerMissiles: ", [Bank12AfterDeactivatePlayerMissiles - Bank12AfterAnimationSystem]d, " bytes"
          endif
end
