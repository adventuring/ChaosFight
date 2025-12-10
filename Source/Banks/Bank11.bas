          rem ChaosFight - Source/Banks/Bank11.bas
          rem Copyright © 2025 Bruce-Robert Pocock.
          rem
          rem GENERAL CODE BANK (shared memory budget - 8 banks total)
          rem Character data system (definitions, cycles, fall damage) +
          rem Titlescreen graphics and kernel
          bank 11
          rem Character data tables
#include "Source/Data/CharacterThemeSongIndices.bas"

          asm
Bank12DataEnds
end

#include "Source/Routines/UpdateAttackCooldowns.bas"
          asm
Bank12AfterUpdateAttackCooldowns
end
#include "Source/Routines/HandleFlyingCharacterMovement.bas"
          asm
Bank12AfterHandleFlyingCharacterMovement
end
#include "Source/Routines/HandleGuardInput.bas"
          asm
Bank12AfterHandleGuardInput
end
#include "Source/Routines/StandardGuard.bas"
          asm
Bank12AfterStandardGuard
end
#include "Source/Routines/RadishGoblinMovement.bas"
          asm
Bank12AfterRadishGoblinMovement
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
           echo "// Bank 11: ", [Bank12AfterUpdateAttackCooldowns - Bank12DataEnds]d, " bytes = UpdateAttackCooldowns"
           echo "// Bank 11: ", [Bank12AfterHandleFlyingCharacterMovement - Bank12AfterUpdateAttackCooldowns]d, " bytes = HandleFlyingCharacterMovement"
           echo "// Bank 11: ", [Bank12AfterHandleGuardInput - Bank12AfterHandleFlyingCharacterMovement]d, " bytes = HandleGuardInput"
           echo "// Bank 11: ", [Bank12AfterStandardGuard - Bank12AfterHandleGuardInput]d, " bytes = StandardGuard"
           echo "// Bank 11: ", [Bank12AfterRadishGoblinMovement - Bank12AfterStandardGuard]d, " bytes = RadishGoblinMovement"
           echo "// Bank 11: ", [Bank12AfterCharacterControlsJump - Bank12AfterRadishGoblinMovement]d, " bytes = CharacterControlsJump"
           echo "// Bank 11: ", [Bank12AfterAnimationSystem - Bank12AfterCharacterControlsJump]d, " bytes = AnimationSystem"
           echo "// Bank 11: ", [Bank12AfterDeactivatePlayerMissiles - Bank12AfterAnimationSystem]d, " bytes = DeactivatePlayerMissiles"
end
